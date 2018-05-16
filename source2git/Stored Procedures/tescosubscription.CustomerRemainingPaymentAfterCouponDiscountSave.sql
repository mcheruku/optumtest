SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [tescosubscription].[CustomerRemainingPaymentAfterCouponDiscountSave]
(
	 @CustomerId BIGINT
	,@CustomerSubscriptionID BIGINT	
	,@RemainingAmount MONEY	
)
AS
/*   
 Author:   Deepmala
 Date created: 29 Apr 2014 
 Purpose:  Delete the exiting record and insert a new entry in the table 
 Behaviour:  How does this procedure actually work  
 Usage:   Hourly/Often 
 Called by:  <SubscriptionService>  
  --Modifications History--  
 Changed On     Changed By     Defect Ref       Change Description  
 
 */

BEGIN
	SET NOCOUNT ON;	

	DECLARE
	 @errorDescription	NVARCHAR(2048)
	,@error				INT
	,@errorProcedure	SYSNAME
	,@errorLine			INT
 
    BEGIN TRY
 
BEGIN TRANSACTION
		

        DELETE RM
        FROM Tescosubscription.CustomerPaymentRemainingDetail RM WITH (NOLOCK)
        INNER JOIN TescoSubscription.CustomerSubscription CS WITH (NOLOCK)
        ON RM.CustomerSubscriptionID = CS.CustomerSubscriptionID
        WHERE CS.CustomerID = @CustomerID

        IF (@RemainingAmount > -1)

        BEGIN
		INSERT INTO tescosubscription.CustomerPaymentRemainingDetail
		(
			CustomerSubscriptionId
			,PaymentRemainingAmount
		)
		VALUES
		(
		@CustomerSubscriptionID
		,@RemainingAmount
		)

        END
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
GRANT EXECUTE ON  [tescosubscription].[CustomerRemainingPaymentAfterCouponDiscountSave] TO [SubsUser]
GO
