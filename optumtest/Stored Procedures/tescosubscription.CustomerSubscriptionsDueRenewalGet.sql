SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	CREATE	PROCEDURE	[tescosubscription].[CustomerSubscriptionsDueRenewalGet] 
	(
		--INPUT PARAMETERS HERE--
		@BatchSize INT
		,@PackageExecutionHistoryID BIGINT
	)
	AS
	/*  Author:			Rajendra Singh
		Date created:	21 Jun 2011
		Purpose:		To fetch batches of Subscriptions to be renewed and initiate the payment transactions
		Behaviour:		Fetches a batch of renewal customers, initiates the payment and retrieves the data as needed by the web service to process the payment.
		Usage:			Often in batch
		Called by:		DataFlow task in RenewCustomerSubscriptions [SSIS Package]
	

		--Modifications History--
		Changed On		Changed By		Defect Ref		Change Description
		<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
		15 Sep 2011		Thulasi							Remove hard coding of Channel name, 
														Removed Business. Business and Language is configurable in the SSIS config file.
		16 Sep 2011		<Thulasi>						<Channel type changed from char(3) to varchar(20)>
		19 Sep 2011		Manjunathan R					Introduced Insert to log table
		06 Jan	2012	Manjunathan Raman				Added join to new table - payment history response
	
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
		)

		DECLARE @EndOfDay DATETIME
				,@CurrentUTCDate DATETIME	
				,@SuccessPaymentProcessStatus TINYINT 
				,@InProgressPaymentProcessStatus TINYINT
				,@ActiveSubscriptionStatus TINYINT
				,@WebChannel VARCHAR(20)
				,@RecurringChannel VARCHAR(20)
				,@WebChannelID TINYINT
				,@RecurringChannelID	TINYINT
				,@CreatedDate Datetime

	 
		SELECT
		        @EndOfDay = CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 101) + ' 23:59:59') 	 -- Set today's date with time set to end of day.
			   ,@CurrentUTCDate = GETUTCDATE()	
			 -- Below Assigned values are status Id reference data from status master table
			   ,@SuccessPaymentProcessStatus = 6 	
			   ,@InProgressPaymentProcessStatus = 5
			   ,@ActiveSubscriptionStatus = 8
			   ,@WebChannelID = 1	-- channel id for first time payment for a particular card through scheduler
			   ,@RecurringChannelID = 2	  -- channel id for recurring payment through scheduler
			   ,@CreatedDate = GETDATE()
		   
		SELECT @WebChannel = ChannelName FROM tescosubscription.ChannelMaster WITH (NOLOCK) WHERE ChannelID =  @WebChannelID
	
		SELECT @RecurringChannel = ChannelName FROM tescosubscription.ChannelMaster WITH (NOLOCK) WHERE ChannelID =  @RecurringChannelID
	

	 --	hard coded values are stored in variables for ease of future changes if any.
   
	
		INSERT INTO @Subs
		(
			CustomerSubscriptionID	
			,CustomerID			
			,Region								
			,PaymentToken	
			,PlanAmount	
			,CustomerPaymentID	
			,IsFirstPaymentDue	
		)
		SELECT TOP (@BatchSize)
			   CS.[CustomerSubscriptionID]
			  ,CS.CustomerID
			  ,CCM.CountryCode
			  ,CP.[PaymentToken]
			  ,SP.[PlanAmount]	
			  ,CP.CustomerPaymentID
			  ,IsFirstPaymentDue
		FROM tescosubscription.CustomerSubscription CS
			JOIN tescosubscription.Customerpayment CP		ON  CP.CustomerID	=	CS.CustomerID
															AND CP.PaymentModeID=1
															AND CP.IsActive = 1
															AND CS.PaymentProcessStatus = @SuccessPaymentProcessStatus
															AND CS.NextRenewalDate <= @EndOfDay
															AND CS.NextRenewalDate <  CS.CustomerPlanEndDate
															AND CS.SubscriptionStatus = @ActiveSubscriptionStatus
			JOIN tescosubscription.SubscriptionPlan SP		ON CS.SubscriptionPlanID		=	SP.SubscriptionPlanID
			JOIN tescosubscription.CountryCurrencyMap CCM	ON CCM.CountryCurrencyID		=	SP.CountryCurrencyID

		--Insert INTO CustomerPaymentHistory table
		INSERT INTO [Tescosubscription].[CustomerPaymentHistory]
			   (CustomerPaymentID
				,CustomerSubscriptionID
				,PaymentDate
				,PaymentAmount
				,ChannelID
				,PackageExecutionHistoryID)
		SELECT
			CustomerPaymentID
			,CustomerSubscriptionID	
			,@CreatedDate
			,PlanAmount
			,@RecurringChannelID
			,@PackageExecutionHistoryID
		FROM @Subs
	
		--Update the status as InProgress
			
		UPDATE	CS
			SET		CS.PaymentProcessStatus =	@InProgressPaymentProcessStatus  -- Update the status to be in progress
					,CS.UTCUpdatedDateTime	=	@CurrentUTCDate
		FROM @Subs Subs
			INNER JOIN	tescosubscription.CustomerSubscription CS ON Subs.CustomerSubscriptionID = CS.CustomerSubscriptionID
	

	--The following details are sent to the Scheduler Service
		SELECT
			 CustomerPaymentHistoryID
			,[CustomerID]
			,[Region]
			,[PaymentToken]
			,[PlanAmount]
			-- For cards whose first payment is due, 'Web' is used as the Channel to accomodate RONo requirements.
			-- But in the CustomerPaymentHistory, 'Subscriptions' is recorded as the channel after the payment.
			,CASE	
					WHEN	IsFirstPaymentDue = 1	THEN @WebChannel
					ELSE	@RecurringChannel END AS 'Channel'
		FROM	@Subs Subs
		JOIN [Tescosubscription].[CustomerPaymentHistory] CH
			ON CH.CustomerSubscriptionID=Subs.CustomerSubscriptionID
		WHERE 
			PackageExecutionHistoryID=@PackageExecutionHistoryID

	END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionsDueRenewalGet] TO [SubsUser]
GO
