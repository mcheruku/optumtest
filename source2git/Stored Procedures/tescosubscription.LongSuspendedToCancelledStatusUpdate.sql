SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[LongSuspendedToCancelledStatusUpdate] 
AS

/*  
    Author:			Saritha Kommineni
	Date created:	25 Apr 2014
	Purpose:		To Cancel long suspended subscriptions
	Behaviour:		
	Usage:			
	Called by:		Job TescoSubscriptionSubscriptionStatusUpdate
	WarmUP Script:	Execute [tescosubscription].[LongSuspendedToCancelledStatusUpdate]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	
*/

BEGIN


DECLARE  @SuspendedSubscriptionStatus          TINYINT
		,@CancelledSubscriptionStatus          TINYINT
        ,@SuspendedToCancelledStatusDurtation  VARCHAR(255)
        ,@SwitchStatusCancel                   TINYINT
        ,@errorDescription			           NVARCHAR(2048)
		,@error								   INT
		,@errorProcedure			           SYSNAME
		,@errorLine			                   INT

CREATE TABLE #CustomerSubscriptionID (CustomerSubscriptionID BIGINT, SwitchTo INT)

		SELECT @SuspendedSubscriptionStatus =7 
			  ,@CancelledSubscriptionStatus= 9 
			  ,@SwitchStatusCancel = 18

SELECT @SuspendedToCancelledStatusDurtation = SettingValue FROM [tescosubscription].[ConfigurationSettings] WITH (NOLOCK)
                                              WHERE SettingName = 'SuspendedToCancelledStatusDuration'


		INSERT  INTO #CustomerSubscriptionID
		SELECT CustomerSubscriptionID, 
				CASE WHEN SwitchTo IS NOT NULL
					 THEN 0
					 ELSE SwitchTo 
				END
		FROM tescosubscription.CustomerSubscription WITH (NOLOCK)
		WHERE SubscriptionStatus=@SuspendedSubscriptionStatus
		AND DATEDIFF(DD,NextRenewalDate, GETDATE()) >= @SuspendedToCancelledStatusDurtation

BEGIN TRY
BEGIN TRANSACTION
      
    -- Update tescosubscription.CustomerSubscription

		UPDATE CS
		SET  CustomerplanEndDate = GETUTCDATE()
			,SubscriptionStatus  = @CancelledSubscriptionStatus
			,CS.SwitchTo = CST.SwitchTo
			,UTCUpdatedDateTime  = GETUTCDATE()
		FROM tescosubscription.CustomerSubscription CS WITH (NOLOCK)
		JOIN #CustomerSubscriptionID CST
		ON CS.CustomerSubscriptionID = CST.CustomerSubscriptionID

  -- Insert tescosubscription.CustomerSubscriptionHistory

	
	   INSERT INTO [tescosubscription].[CustomerSubscriptionHistory]
				 ( [CustomerSubscriptionID]
				  ,[SubscriptionStatus]			 
				  ,[Remarks])
	   SELECT      CustomerSubscriptionID
				  ,@CancelledSubscriptionStatus			
				  ,'Cancelled automatically - previously a suspended plan' 
	   FROM  #CustomerSubscriptionID

  -- Insert tescosubscription.CustomerSubscriptionSwitchHistory

		 INSERT INTO tescosubscription.CustomerSubscriptionSwitchHistory
			(
				[CustomerSubscriptionID]
			   ,[SwitchTo]
			   ,[SwitchStatus]
			   ,[SwitchOrigin]					   
			)
		 SELECT CustomerSubscriptionID
			   ,SwitchTo
			   ,@SwitchStatusCancel
			   ,'Job TescoSubscriptionSubscriptionStatusUpdate'   
		 FROM #CustomerSubscriptionID
	  

 COMMIT TRANSACTION

DROP TABLE #CustomerSubscriptionID

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
GRANT EXECUTE ON  [tescosubscription].[LongSuspendedToCancelledStatusUpdate] TO [SubsUser]
GO
