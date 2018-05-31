SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


   CREATE PROCEDURE	[tescosubscription].[CustomerSubscriptionsDueRenewalGet2] 
	(
		--INPUT PARAMETERS HERE--
		@BatchSize INT
		,@PackageExecutionHistoryID BIGINT
	)
	AS
	/*  Author:			Robin
		Date created:	2 May 2014
		Purpose:		To fetch batches of Subscriptions to be renewed and initiate the payment transactions
		Behaviour:		Fetches a batch of renewal customers, initiates the payment and retrieves the data as needed by the web service to process the payment.
		Usage:			Often in batch
		Called by:		DataFlow task in RenewCustomerSubscriptions [SSIS Package]
	

		--Modifications History--
		Changed On		Changed By		Defect Ref		Change Description
        23-Apr-2014     Saritha Kommineni		       Added logic to fetch recors with InProgressPaymentProcessStatus		
		25-Jun-2014		Deepmala Trivedi				Reverted the logic for InProgressPaymentProcessStatus
	
	*/

	BEGIN
		SET NOCOUNT ON
		-- Declare a table variable to get the desired customer subscriptions

		DECLARE	@Subs		TABLE
		(
			 CustomerSubscriptionID	BIGINT UNIQUE
			,CustomerID				BIGINT
			,Region					CHAR(2)		
			,PaymentToken			NVARCHAR(44)
			,PlanAmount				SMALLMONEY
			,CustomerPaymentID		BIGINT
			,IsFirstPaymentDue      BIT
			,CurrentPlanId			INT
			,OldPlanId				INT
			,NewPlanId				INT
			,PackageExecutionHistoryID	BIGINT	
			,IsSwitchedToday			BIT		
		)       

		DECLARE @EndOfDay DATETIME
				,@CurrentUTCDate DATETIME	
				,@SuccessPaymentProcessStatus TINYINT 
				,@InProgressPaymentProcessStatus TINYINT
				,@ActiveSubscriptionStatus TINYINT
				,@PendingStopSubscriptionStatus TINYINT
				,@WebChannel VARCHAR(20)
				,@RecurringChannel VARCHAR(20)
				,@WebChannelID TINYINT
				,@RecurringChannelID	TINYINT
				,@CreatedDate Datetime
				,@RenewalInProgressAttempts  SMALLINT

	 
		SELECT
		        @EndOfDay = CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 101) + ' 23:59:59') 	 -- Set today's date with time set to end of day.
			   ,@CurrentUTCDate = GETUTCDATE()	
			 -- Below Assigned values are status Id reference data from status master table
			   ,@SuccessPaymentProcessStatus = 6 	
			   ,@InProgressPaymentProcessStatus = 5
			   ,@ActiveSubscriptionStatus = 8
			   ,@PendingStopSubscriptionStatus = 11
			   ,@WebChannelID = 1	-- channel id for first time payment for a particular card through scheduler
			   ,@RecurringChannelID = 2	  -- channel id for recurring payment through scheduler
			   ,@CreatedDate = GETDATE()
               
               
		   
		SELECT @WebChannel = ChannelName FROM tescosubscription.ChannelMaster WITH (NOLOCK) WHERE ChannelID =  @WebChannelID
	
		SELECT @RecurringChannel = ChannelName FROM tescosubscription.ChannelMaster WITH (NOLOCK) WHERE ChannelID =  @RecurringChannelID
             
        SELECT @RenewalInProgressAttempts = SettingValue FROM [tescosubscription].[ConfigurationSettings] WHERE SettingName = 'RenewalInProgressAttempts'
		
		--	hard coded values are stored in variables for ease of future changes if any.
		--Below query is to get the upfront processing records only.
	
		INSERT INTO @Subs
		(
			CustomerSubscriptionID	
			,CustomerID			
			,Region								
			,PaymentToken	
			,PlanAmount	
			,CustomerPaymentID	
			,IsFirstPaymentDue	
			,CurrentPlanId
			,OldPlanId
			,NewPlanId
			,PackageExecutionHistoryID	
			,IsSwitchedToday		
		)
		SELECT TOP (@BatchSize) 
			CS.[CustomerSubscriptionID]
			,CS.CustomerID
			,CCM.CountryCode
			,CP.[PaymentToken]
			,SP.[PlanAmount]  
			,CP.CustomerPaymentID
			,IsFirstPaymentDue
			,CS.SubscriptionPlanId--In case of switch it would return the new plan
			,case when CS.SwitchCustomerSubscriptionId is not null 
				then Source_CS.SubscriptionPlanId--(Select SubscriptionPlanId from tescosubscription.CustomerSubscription where CustomerSubscriptionId = SwitchCustomerSubscriptionId)
				else 0 end as OldPlanId
			,IsNull(CS.SwitchTo, 0) as NewPlanId
			,@PackageExecutionHistoryID	
			,(case when convert(varchar,CS.CustomerPlanStartDate,112) = convert(varchar,getdate(),112) then 1 else 0 end) as IsSwitchedToday--For notification purpose (SwitchSuccess email)
		FROM tescosubscription.CustomerSubscription CS
			LEFT JOIN tescosubscription.CustomerSubscription Source_CS  ON  CS.SwitchCustomerSubscriptionID =Source_CS.CustomerSubscriptionID		
			JOIN tescosubscription.Customerpayment CP		ON  CP.CustomerID	=	CS.CustomerID
															AND CP.PaymentModeID=1
															AND CP.IsActive = 1															
														    AND CS.PaymentProcessStatus = @SuccessPaymentProcessStatus
															AND CS.NextRenewalDate <= @EndOfDay 
                                                            AND CS.NextRenewalDate <  CONVERT(VARCHAR(10),CS.CustomerPlanEndDate,101)
															AND CS.SubscriptionStatus = @ActiveSubscriptionStatus
            JOIN tescosubscription.SubscriptionPlan SP		ON CS.SubscriptionPlanID =	SP.SubscriptionPlanID
			                                                AND SP.PaymentInstallmentID = 1	
			JOIN tescosubscription.CountryCurrencyMap CCM	ON CCM.CountryCurrencyID = SP.CountryCurrencyID

       UNION ALL
 
       --Below query is to process the monthly payment and renewal for monthly payment plans records only.
       SELECT TOP (@BatchSize) 
			CS.[CustomerSubscriptionID]
			,CS.CustomerID
			,CCM.CountryCode
			,CP.[PaymentToken]
			,ROUND(SP.[PlanAmount],2) PlanAmount--ROUND(SP.[PlanAmount]/SP.PlanTenure,2)  * InstallmentTenure PlanAmount
			,CP.CustomerPaymentID
			,IsFirstPaymentDue
			,CS.SubscriptionPlanId--In case of switch it would return the new plan
			,case when CS.SwitchCustomerSubscriptionId is not null 
				then Source_CS.SubscriptionPlanId--(Select SubscriptionPlanId from tescosubscription.CustomerSubscription where CustomerSubscriptionId = SwitchCustomerSubscriptionId)
				else 0 end as OldPlanId
			,IsNull(CS.SwitchTo, 0) as NewPlanId
			,@PackageExecutionHistoryID			
			,(case when convert(varchar,CS.CustomerPlanStartDate,112) = convert(varchar,getdate(),112) then 1 else 0 end) as IsSwitchedToday --For notification purpose (SwitchSuccess email)
		FROM tescosubscription.CustomerSubscription CS
			LEFT JOIN tescosubscription.CustomerSubscription Source_CS  ON  CS.SwitchCustomerSubscriptionID =Source_CS.CustomerSubscriptionID		
			JOIN tescosubscription.Customerpayment CP		ON  CP.CustomerID	=	CS.CustomerID
															AND CP.PaymentModeID=1
															AND CP.IsActive = 1
															AND CS.PaymentProcessStatus = @SuccessPaymentProcessStatus															
															AND CS.NextPaymentDate <= @EndOfDay
                                                            AND CS.NextPaymentDate < CONVERT(VARCHAR(10),CS.CustomerPlanEndDate,101)
															AND (CS.SubscriptionStatus = @ActiveSubscriptionStatus or CS.SubscriptionStatus = @PendingStopSubscriptionStatus)
			JOIN tescosubscription.SubscriptionPlan SP		ON CS.SubscriptionPlanID =	SP.SubscriptionPlanID
			                                                 AND SP.PaymentInstallmentID <> 1
			JOIN tescosubscription.CountryCurrencyMap CCM	ON CCM.CountryCurrencyID =	SP.CountryCurrencyID
            JOIN tescoSubscription.PaymentInstallment IP    ON SP.PaymentInstallmentID = IP.PaymentInstallmentID                                                            


			
		UPDATE	CS
			SET		CS.PaymentProcessStatus =	@InProgressPaymentProcessStatus  -- Update the status to be in progress
					,CS.UTCUpdatedDateTime	=	@CurrentUTCDate
		FROM @Subs Subs  
			INNER JOIN	tescosubscription.CustomerSubscription CS ON Subs.CustomerSubscriptionID = CS.CustomerSubscriptionID
	

	--The following details are sent to the Scheduler Service	
		SELECT
			-- CustomerPaymentHistoryID
			[CustomerID]
			,[Region]
			,[PaymentToken]
			,[PlanAmount]
			-- For cards whose first payment is due, 'Web' is used as the Channel to accomodate RONo requirements.
			-- But in the CustomerPaymentHistory, 'Subscriptions' is recorded as the channel after the payment.
			,CASE	
					WHEN	IsFirstPaymentDue = 1	THEN @WebChannel
					ELSE	@RecurringChannel END AS 'Channel'
			,CurrentPlanId
			,OldPlanId
			,NewPlanId
			,PackageExecutionHistoryID
			,CustomerPaymentId
			,CustomerSubscriptionId
			,IsSwitchedToday
		FROM	@Subs Subs 
	
	END

GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionsDueRenewalGet2] TO [SubsUser]
GO
