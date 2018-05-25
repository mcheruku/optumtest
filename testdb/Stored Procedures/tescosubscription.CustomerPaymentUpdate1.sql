SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

	CREATE PROCEDURE [tescosubscription].[CustomerPaymentUpdate1] 
	(
		 @CustomerPaymentID				BIGINT
		,@PaymentAmount					SMALLMONEY
		,@IsPreAuth						Bit
	)
	AS
	/*  Author:			Deepmala
		Date created:	20 May 2014
		Purpose:		Updates Customer Payment
		Behaviour:		Updates Customer Payment after successful Authorisation and makes other Payment Detail specific to the Customer as Inactive
		Usage:			Whenever a customer Places a new Payment Detail
		Called by:		Appstore method CreateCustomerPayment
	
	--Modifications History--
		Changed On		Changed By		Defect Ref		Change Description
		<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
		20 May 2014		Deepmala Trivedi				Added a new parameter IsPreAuth to modify IsFirstPaymentDue flag
	*/


	BEGIN

		DECLARE		@CustomerID					BIGINT
					,@PaymentModeID				TINYINT 
					,@CurrentUTCDate		DATETIME
					,@errorDescription	NVARCHAR(2048)
					,@error				INT
					,@errorProcedure	SYSNAME
					,@errorLine			INT
					--,@PreAuthAmount	SMALLMONEY
					
		SET NOCOUNT ON;	

		SELECT	@CurrentUTCDate = GETUTCDATE()--,@PreAuthAmount = 2
				,@CustomerID=CustomerID,@PaymentModeID=PaymentModeID
		 FROM
			[tescosubscription].[CustomerPayment]
		WHERE CustomerPaymentID=@CustomerPaymentID
		
			
		BEGIN TRY
		BEGIN TRANSACTION PaymentUpdate

	-- make others inactive
			UPDATE	[tescosubscription].[CustomerPayment]
			SET		[IsActive]			=	0,
					UTCUpdatedDateTime  =   @CurrentUTCDate
  			WHERE	CustomerID			=	@CustomerID
			AND		PaymentModeID		=	@PaymentModeID	
		
			UPDATE	[tescosubscription].[CustomerPayment]
							SET		[IsActive]	=	1
							,@CustomerPaymentID=CustomerPaymentID
							,IsFirstPaymentDue = CASE WHEN (@PaymentAmount > 0 and @IsPreAuth = 0) THEN 0 ELSE IsFirstPaymentDue END
							,UTCUpdatedDateTime  =   @CurrentUTCDate
			FROM	[tescosubscription].[CustomerPayment]
							WHERE	CustomerPaymentID=@CustomerPaymentID
				
		COMMIT TRANSACTION PaymentUpdate
		END TRY
		BEGIN CATCH

		  SELECT      @errorProcedure         = Routine_Schema  + '.' + Routine_Name
					  , @error                = ERROR_NUMBER()
					  , @errorDescription     = ERROR_MESSAGE()
					  , @errorLine            = ERROR_LINE()
		  FROM  INFORMATION_SCHEMA.ROUTINES
		  WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

		 ROLLBACK TRANSACTION PaymentUpdate
		 RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
	 
		END CATCH

				
	END
	
GO
GRANT EXECUTE ON  [tescosubscription].[CustomerPaymentUpdate1] TO [SubsUser]
GO
