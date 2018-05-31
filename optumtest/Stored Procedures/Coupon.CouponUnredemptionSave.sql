SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CouponUnredemptionSave]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [Coupon].[CouponUnredemptionSave]
** DATE WRITTEN   : 09th July 2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): 0 in case of success.
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	15 Jul 2013		Navdeep_Singh					RedemptionFix of value 1
	23 Jul 2013		Navdeep_Singh					Incorporating Manju's logic fro redemption

*/

CREATE PROCEDURE [Coupon].[CouponUnredemptionSave]
(
	@CouponCode NVARCHAR(25)
	,@CustomerID BIGINT	
)
AS

BEGIN
	SET NOCOUNT ON;	

	DECLARE	 @errorDescription	NVARCHAR(2048)
		,@error				INT
		,@errorProcedure	SYSNAME
		,@errorLine			INT
	  
	BEGIN TRY
 
	BEGIN TRANSACTION 
		
	;WITH DelCoup AS
	( SELECT TOP 1 CouponCode FROM [TescoSubscription].[Coupon].[CouponRedemption]
      WHERE CustomerID = @CustomerID AND CouponCode=@CouponCode
      ORDER BY UTCCreatedDateTime DESC 
	)

	DELETE FROM DelCoup
      
	
	IF @@ROWCOUNT = 1 
	BEGIN		
		UPDATE Coupon.Coupon
		SET RedeemCount = RedeemCount - 1
			,UTCUpdatedDateTime = GETUTCDATE()
		WHERE 
			CouponCode = @CouponCode
		
	COMMIT TRANSACTION 	

	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION 
		
		RAISERROR (
				'SP - [coupon].[CouponUnRedemptionSave] Error = (%s)',
				16,
				1,
				'No record'
				)
	END	
	
	

	END TRY
	BEGIN CATCH

	IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION 
			END

	  SELECT      @errorProcedure         = Routine_Schema  + '.' + Routine_Name
				  , @error                = ERROR_NUMBER()
				  , @errorDescription     = ERROR_MESSAGE()
				  , @errorLine            = ERROR_LINE()
	  FROM  INFORMATION_SCHEMA.ROUTINES
	  WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

	 RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
 
	END CATCH


END
GO
GRANT EXECUTE ON  [Coupon].[CouponUnredemptionSave] TO [SubsUser]
GO
