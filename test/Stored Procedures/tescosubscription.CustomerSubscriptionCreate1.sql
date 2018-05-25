SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionCreate1] 
(
	@CustomerID					BIGINT
	,@SubscriptionPlanID		INT
	,@CustomerPlanStartDate		DATETIME
	,@CustomerPlanEndDate		DATETIME
	,@SubscriptionStatus		TINYINT
)
AS
/*  Author:			Robin
	Date created:	09 MAY 2013
	Purpose:		To create a new Customer subscription Entry
	Behaviour:		Inserts a new CustomerSubscription with an Active Status, assigns the next renewal date and returns the newly generated CustomerSubscriptionID
	Usage:			Whenever a customer Places an Order from the Subscription Website.
	Called by:		Appstore method CreateCustomerSubscription
	WarmUP Script:	Execute [tescosubscription].[CustomerSubscriptionCreate1] 25,9, '05/08/2013', '05/08/2014', 8
	
--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	
*/
BEGIN
	
	SET NOCOUNT ON;

 BEGIN TRY

	DECLARE @FreePeriod		TINYINT
			,@PlanTenure	INT
			,@CustomerSubscriptionID BIGINT
            ,@errorDescription				    NVARCHAR(2048)
			,@error								INT
			,@errorProcedure					SYSNAME
			,@errorLine							INT
			,@SubscriptionStatusCancelled		TinyInt
 			,@SubscriptionStatusStopped		TinyInt
			,@SubscriptionStatusSwitched TINYINT
            ,@PaymentInstallmentID  TINYINT
            ,@InstallmentTenure TINYINT
             
	SELECT	@FreePeriod		=	SP.FreePeriod
			,@PlanTenure	=	SP.PlanTenure
			,@SubscriptionStatusCancelled = 9  -- 9 status of cancelled subscription 
			,@SubscriptionStatusStopped = 10	
			,@SubscriptionStatusSwitched = 16
            ,@InstallmentTenure  = IP.InstallmentTenure 
            ,@PaymentInstallmentID = SP.PaymentInstallmentID
	FROM	tescosubscription.SubscriptionPlan SP WITH (NOLOCK)
    INNER JOIN tescosubscription.PaymentInstallment IP WITH (NOLOCK) 
		ON SP.PaymentInstallmentID = IP.PaymentInstallmentID
	WHERE	SubscriptionPlanID	=	@SubscriptionPlanID

    

DECLARE @SubsTemp TABLE (
 CustomerSubscriptionID BIGINT)

IF EXISTS (
	SELECT 1 FROM  [tescosubscription].[CustomerSubscription] WHERE
		[CustomerID] = @CustomerID  and [SubscriptionStatus] NOT IN (@SubscriptionStatusCancelled,
																	@SubscriptionStatusStopped
																	,@SubscriptionStatusSwitched)	
		)
	BEGIN 
		-- a recent sub exists so don't create a new one 
		SELECT -1 CustomerSubscriptionID

	END 

ELSE
	BEGIN
	BEGIN TRANSACTION
		INSERT INTO [tescosubscription].[CustomerSubscription]
			   (
					[CustomerID]
				   ,[SubscriptionPlanID]
				   ,[CustomerPlanStartDate]
				   ,[CustomerPlanEndDate]
				   ,[NextRenewalDate]
				   ,[SubscriptionStatus]
				   ,[RenewalReferenceDate]
                   ,[NextPaymentDate]
                   
				)
	   OUTPUT inserted.CustomerSubscriptionID INTO @SubsTemp
		 VALUES
			   (
					@CustomerID				
					,@SubscriptionPlanID		
					,@CustomerPlanStartDate		
					,@CustomerPlanEndDate			
					,CASE	@FreePeriod
							WHEN	0	THEN	DATEADD(m,( @PlanTenure ), @CustomerPlanStartDate )
                            ELSE	DATEADD(m,( @FreePeriod ), @CustomerPlanStartDate )	END
					,@SubscriptionStatus		
					,CASE	@FreePeriod
							WHEN	0	THEN	@CustomerPlanStartDate
							ELSE	DATEADD(m,( @FreePeriod ), @CustomerPlanStartDate )	END
                    ,CASE WHEN @PaymentInstallmentID <> 1
							THEN DATEADD(m,(CASE WHEN @FreePeriod = 0 THEN @InstallmentTenure ELSE @FreePeriod END), @CustomerPlanStartDate )
                           ELSE NULL END
               )
		
		INSERT INTO [tescosubscription].[CustomerSubscriptionHistory]
			   ([CustomerSubscriptionID]
			   ,[SubscriptionStatus]
			   ,[Remarks])
		 OUTPUT inserted.CustomerSubscriptionID
		 SELECT
			   CustomerSubscriptionID
			   ,@SubscriptionStatus
			   ,'Created New subs'
		 FROM @SubsTemp
		
	COMMIT TRANSACTION
	END
END TRY
	BEGIN CATCH

      SELECT      @errorProcedure         = Routine_Schema  + '.' + Routine_Name
                  , @error                = ERROR_NUMBER()
                  , @errorDescription     = ERROR_MESSAGE()
                  , @errorLine            = ERROR_LINE()
      FROM  INFORMATION_SCHEMA.ROUTINES
      WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

     ROLLBACK TRANSACTION 

	 RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
	 

	END CATCH

END



GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionCreate1] TO [SubsUser]
GO
