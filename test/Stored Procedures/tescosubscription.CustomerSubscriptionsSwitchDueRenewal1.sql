SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionsSwitchDueRenewal1]

AS

/*

	Author:			Robin
	Date created:	15 Jan 2013
	Purpose:		CustomerSubscriptionsSwitchDueRenewal 
	Behaviour:		How does this procedure actually work
	Usage:			
	Called by:		DS
	--exec [tescosubscription].[CustomerSubscriptionsGet] 111,''

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
    15 Jan 2013     Robin                           New SP 
	17 Jan 2013     Robin                           Added CustomerPlanEndDate = @CurrentUTCDate added Go before granting permission
*/

BEGIN

		SET NOCOUNT ON

		DECLARE @CurrentUTCDate	DATETIME,
				@CurrentDate	DATETIME,
				@SubscriptionActiveStatus TinyInt,
				@SubscriptionPendingStoppedStatus TinyInt,
				@SubscriptionSwitchedStatus TinyInt,
				@errorDescription NVARCHAR(2048),
				@error INT,
				@errorProcedure	SYSNAME,
				@errorLine	INT,
                @SwitchSucess TinyInt -- For Switch Sucess Status in Switch History Table  
                 

		SELECT	@CurrentUTCDate = GETUTCDATE(),	@CurrentDate = GETDATE()
				,@SubscriptionActiveStatus = 8,
				@SubscriptionPendingStoppedStatus = 11,
				@SubscriptionSwitchedStatus = 16,
                @SwitchSucess = 19 --Switch History Table 


		CREATE TABLE #PlanSwitchSubscriptions
		(
			CustomerSubscriptionID BIGINT,
			NewCustomerSubscriptionID BIGINT,
			SwitchTo TinyInt
		)


		 BEGIN TRY


		BEGIN TRAN

				INSERT INTO [TescoSubscription].[CustomerSubscription]
					   (
							[CustomerID]
						   ,[SubscriptionPlanID]
						   ,[CustomerPlanStartDate]
						   ,[CustomerPlanEndDate]
						   ,[NextRenewalDate]
						   ,[SubscriptionStatus]
						   ,[RenewalReferenceDate]
						   ,[SwitchCustomerSubscriptionID]
							,[NextPaymentDate]
						)
			   OUTPUT inserted.SwitchCustomerSubscriptionID, inserted.CustomerSubscriptionID, inserted.SubscriptionPlanID INTO #PlanSwitchSubscriptions
				SELECT 
					PS.CustomerID,
					SwitchTo,
					@CurrentDate,
					'9999/12/31 23:59:59',
					@CurrentDate,
					@SubscriptionActiveStatus ,
					@CurrentDate,
					CustomerSubscriptionID,
					(Case When SP.PaymentInstallmentId != 1 Then getdate() Else null End)
				FROM TescoSubscription.CustomerSubscription (NOLOCK) PS
				INNER JOIN TescoSubscription.SubscriptionPlan (NOLOCK) SP on SP.SubscriptionPlanId = PS.SwitchTo 
				WHERE PS.NextRenewalDate <= CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 101) + ' 23:59:59') 
				AND SubscriptionStatus IN (@SubscriptionActiveStatus,@SubscriptionPendingStoppedStatus) 
				AND SwitchTo IS NOT NULL
 

				UPDATE CS
				SET SubscriptionStatus = @SubscriptionSwitchedStatus,
				UTCUpdatedDateTime = @CurrentUTCDate, CustomerPlanEndDate = @CurrentUTCDate
				FROM TescoSubscription.customerSubscription CS 
				INNER JOIN #PlanSwitchSubscriptions PS on CS.CustomerSubscriptionID = PS.CustomerSubscriptionID

		COMMIT

				INSERT INTO [tescosubscription].[CustomerSubscriptionHistory]
					   ([CustomerSubscriptionID]
					   ,[SubscriptionStatus]
					   ,[Remarks])
				 SELECT
					   CustomerSubscriptionID
					   ,@SubscriptionSwitchedStatus
					   ,'Plan Switched'
				 FROM #PlanSwitchSubscriptions

				INSERT INTO [tescosubscription].[CustomerSubscriptionHistory]
					   ([CustomerSubscriptionID]
					   ,[SubscriptionStatus]
					   ,[Remarks])
				 SELECT
					   NewCustomerSubscriptionID
					   ,@SubscriptionActiveStatus
					   ,'Created New subs'
				 FROM #PlanSwitchSubscriptions

		INSERT INTO [TescoSubscription].[tescosubscription].[CustomerSubscriptionSwitchHistory]
				   ([CustomerSubscriptionID]
				   ,[SwitchTo]
				   ,[SwitchStatus]
                   ,[SwitchOrigin])
		SELECT CustomerSubscriptionID
					   ,SwitchTo
					   ,@SwitchSucess
                       ,'Scheduler'
				 FROM #PlanSwitchSubscriptions
   
		END TRY
			BEGIN CATCH

			  SELECT      @errorProcedure         = Routine_Schema  + '.' + Routine_Name
						  , @error                = ERROR_NUMBER()
						  , @errorDescription     = ERROR_MESSAGE()
						  , @errorLine            = ERROR_LINE()
			  FROM  INFORMATION_SCHEMA.ROUTINES
			  WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

			 IF @@TRANCOUNT >0 ROLLBACK TRANSACTION 
     
			 RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
       
			END CATCH

			DROP TABLE #PlanSwitchSubscriptions

		END

GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionsSwitchDueRenewal1] TO [SubsUser]
GO
