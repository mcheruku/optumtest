SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[CouponPaymentSave]
(
@CustomerId BIGINT,
@CustomerSubscriptionID BIGINT,
@IsActive	BIT,
@Token  NVARCHAR(44), 
@Remarks    VARCHAR(100),
@PaymentMode        TINYINT,
@PaymentStatus   TINYINT,
@IsFirstPaymentDue     BIT,
@PackExeHistId BIGINT,
@Channel INT,
--@CouponAppliedTyp   TINYINT,
@Amount                MONEY
)
AS

/*

	Author:			HarshaByloor
	Date created:	20/03/2014
	Purpose:		Applies Coupon Details in Payment Table	
	Behaviour:		How does this procedure actually work
	Usage:			
	Called by:		<DeliverySaver Website>

    --Modifications History--
 	Changed On    Changed By   Defect   Changes   Change  Description 

	
*/
BEGIN

     DECLARE 
			 @errorDescription	NVARCHAR(2048)
			,@error				INT
			,@errorProcedure    SYSNAME
			,@errorLine	        INT
            ,@RowCount          INT
            ,@CustomerPaymentID BIGINT
 			
	If @PaymentMode = 2
			BEGIN	
				set @Token = upper(@Token)
			END

      SELECT @CustomerPaymentID = CustomerPaymentID FROM [tescosubscription].[CustomerPayment]
             WHERE CustomerID		=	@CustomerID
			 AND		CAST(PaymentToken AS VARBINARY(90))	=	CAST(@Token AS VARBINARY(90))
			 AND		PaymentModeID	=	@PaymentMode
             AND     IsActive = 1
        SELECT @RowCount = @@RowCount
	   
	
BEGIN TRY
		DECLARE 
              @CustomerPayment TABLE (CustomerPaymentID BIGINT)

        BEGIN TRANSACTION CouponPaymentSave
		
    
	    IF @CustomerID IS NOT NULL AND @RowCount = 0           
        BEGIN 
		
			INSERT INTO tescosubscription.Customerpayment
						   (CustomerID,
							PaymentModeId,
							PaymentToken,
							IsActive,
							IsFirstPaymentDue)					
			OUTPUT inserted.CustomerPaymentID INTO @CustomerPayment
				VALUES
						   (@CustomerId,
							@PaymentMode,
							@Token,
							@IsActive,
							@IsFirstPaymentDue)

			SELECT CustomerPaymentID FROM @CustomerPayment
         
	    END

        ELSE if @customersubscriptionid IS NULL

        PRINT 'The Provided Token ' + @Token + ' Already Exists'

		ELSE
		INSERT INTO @CustomerPayment VALUES (@CustomerPaymentID)
      
		IF @CustomerSubscriptionID IS NOT NULL

		BEGIN
			DECLARE
			@PaymentHistory  TABLE (CustomerPaymentHistoryID  BIGINT)

			INSERT INTO [tescosubscription].[CustomerPaymentHistory]
						   ([CustomerPaymentID]
						   ,[CustomerSubscriptionID]
						   ,[PaymentDate]
						   ,[PaymentAmount]
						   ,[ChannelID]
						   ,[IsEmailSent]
						   ,[PackageExecutionHistoryID])
			OUTPUT inserted.CustomerPaymentHistoryID  INTO @PaymentHistory
				SELECT  CustomerPaymentID,
						@CustomerSubscriptionID,
						GETDATE(),
						@Amount,
						@Channel,
						0,
						@PackExeHistId FROM @CustomerPayment

			 SELECT CustomerPaymentHistoryID FROM @PaymentHistory
		     
			INSERT INTO [Tescosubscription].[CustomerPaymentHistoryResponse]
					   (CustomerPaymentHistoryID
						,PaymentStatusID
						,Remarks
						)
			  OUTPUT INSERTED.CustomerPaymentHistoryResponseID
       			  SELECT CustomerPaymentHistoryID,
						 @PaymentStatus,
						 @Remarks
						 FROM @PaymentHistory

    END

COMMIT TRANSACTION CouponPaymentSave
	
END TRY
	BEGIN CATCH

      SELECT   @errorProcedure       = Routine_Schema  + '.' + Routine_Name
             , @error                = ERROR_NUMBER()
             , @errorDescription     = ERROR_MESSAGE()
             , @errorLine            = ERROR_LINE()
      FROM  INFORMATION_SCHEMA.ROUTINES
      WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

    ROLLBACK TRANSACTION CouponPaymentSave

      RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
	END CATCH
END


GO
GRANT EXECUTE ON  [tescosubscription].[CouponPaymentSave] TO [SubsUser]
GO
