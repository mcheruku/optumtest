SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/****** Object:  StoredProcedure [tescosubscription].[CustomerSubscriptionPaymentStatusUpdate]    Script Date: 06/28/2011 12:35:08 ******/
CREATE	PROCEDURE	[tescosubscription].[CustomerSubscriptionPaymentStatusUpdate] 
(
	--INPUT PARAMETERS HERE--
	@PackageExecutionHistoryID BIGINT
)
AS
/*  Author:			Manjunathan Raman
	Date created:	21 Jun 2011
	Purpose:		To update batches of Subscriptions to success status
	Behaviour:		 update batches of Subscriptions to success status during failure in SSIS package
	Usage:			Often in batch
	Called by:		DataFlow task in RenewCustomerSubscriptions [SSIS Package]
	

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	06 Jan	2012	Manjunathan Raman				Changes to incorporate column "PackageExecutionHistoryID" moved to customerPaymentHistory table

*/

BEGIN
	SET NOCOUNT ON
	-- Declare a table variable to get the desired customer subscriptions

	DECLARE @CurrentUTCDate DATETIME	
			,@SuccessPaymentProcessStatus TINYINT 
			,@InProgressPaymentProcessStatus TINYINT
 -- Set today's date with time set to end of day.
	SELECT @CurrentUTCDate = GETUTCDATE()	
		   ,@SuccessPaymentProcessStatus = 6 	
		   ,@InProgressPaymentProcessStatus = 5
		
	--Update the status to Success
		UPDATE	CS
		SET		CS.PaymentProcessStatus =	@SuccessPaymentProcessStatus 
				,CS.UTCUpdatedDateTime	=	@CurrentUTCDate
		FROM [tescosubscription].CustomerPaymentHistory CPH
		JOIN tescosubscription.CustomerSubscription CS 
			ON CPH.PackageExecutionHistoryID=@PackageExecutionHistoryID
			AND CS.CustomerSubscriptionID = CPH.CustomerSubscriptionID
			AND CS.PaymentProcessStatus=@InProgressPaymentProcessStatus

END



GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionPaymentStatusUpdate] TO [SubsUser]
GO
