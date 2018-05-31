SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionSwitchSave1] 
(
  --INPUT PARAMETERS HERE--
     @CustomerID BIGINT
	,@SubscriptionID BIGINT
    ,@SwitchTo INT
	,@SwitchOrigin  VARCHAR(60)
    
)
AS
/*  Author:			Robin John
	Date created:	22 April 2013
	Purpose:		To update Customersubscription and insert records in Customersubscriptionswitchhistorytable 
	Behaviour:		Creates entry in CustomersubscriptionSwitchHistory table and CustomerSubscription table.
	Usage:			Whenever a customer Switches a plan on the website there is a entry made in CustomersubscriptionSwitchHistory table and CustomerSubscription 
	Called by:		DS and Juvo
	WarmUP Script:  EXECUTE [tescosubscription].[CustomerSubscriptionSwitchSave] 500,0,0 
--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	21 April 2013   Robin                           New Versioned SP (Added check to cancel the existing switch , when customer is switching to different plan)			
*/
 
 

BEGIN	
	SET NOCOUNT ON
    DECLARE 
    @SwitchStatusCancel TINYINT
	,@SwitchStatusInitiated TINYINT
	,@SwitchToExisting INT
	,@errorDescription	NVARCHAR(2048)
	,@error				INT
	,@errorProcedure	SYSNAME
	,@errorLine			INT


		SELECT @SwitchStatusInitiated = 17 , @SwitchStatusCancel = 18, @SwitchToExisting=SwitchTo  
		FROM [Tescosubscription].[CustomerSubscription] (NOLOCK) -- GET SwitchTo Record Before Update
		WHERE CustomerSubscriptionID = @SubscriptionID AND CustomerID = @Customerid 
    
	   IF @SwitchStatusInitiated IS NULL OR (@SwitchToExisting IS NULL AND @SwitchTo IS NULL  ) OR (@SwitchToExisting = @SwitchTo)
	   BEGIN

		    RAISERROR('[Procedure:INVALID INPUT ]',16,1)
		
			return (-1) 
	   END
	 
	BEGIN TRY
		BEGIN TRAN


    	UPDATE [TescoSubscription].[CustomerSubscription] -- Update the SwitchTo Coloumn 
		SET SwitchTo = @SwitchTo, UTCUpdatedDateTime = GETUTCDATE()  -- Update the SwitchTo coloumn and UTCUpdatedDateTime
		WHERE CustomerSubscriptionID = @SubscriptionID 


		IF (@SwitchToExisting IS NOT NULL AND @SwitchTo IS NOT NULL AND @SwitchToExisting <> @SwitchTo)
		   BEGIN
			INSERT INTO [tescosubscription].[CustomerSubscriptionSwitchHistory]
				   (
						[CustomerSubscriptionID]
					   ,[SwitchTo]
					   ,[SwitchStatus]
					   ,[SwitchOrigin]
					   
					)
			SELECT @SubscriptionID
				,@SwitchToExisting
				,@SwitchStatusCancel
				,@SwitchOrigin

	   END


		INSERT INTO [tescosubscription].[CustomerSubscriptionSwitchHistory]
			   (
				    [CustomerSubscriptionID]
                   ,[SwitchTo]
                   ,[SwitchStatus]
				   ,[SwitchOrigin]
				   
				)
		SELECT @SubscriptionID
			,ISNULL(@SwitchTO,@SwitchToExisting)
			,CASE WHEN @SwitchTO IS NULL THEN @SwitchStatusCancel ELSE @SwitchStatusInitiated END
			,@SwitchOrigin
		
      COMMIT TRANSACTION

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
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionSwitchSave1] TO [SubsUser]
GO
