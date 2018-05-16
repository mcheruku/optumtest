SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[CustomerPaymentHistoryResponseCreate]
(
		--INPUT PARAMETERS HERE--
	 @CustomerPaymentHistoryID				BIGINT
	,@StatusID						TINYINT
	,@Remarks						VARCHAR(100) 
    
)
AS

/*

	Author:			Joji Isac
	Date created:	26 dec 2011
	Purpose:		To insert the payment attempt result in table CustomerPaymentHistoryResponse
	Behaviour:		This procedure is called from Appstore on receiving response from CPS
	Usage:			Often in batch
	Called by:		AppStore
	WarmUP Script:	Execute [tescosubscription].[CustomerPaymentHistoryResponseCreate] 11,0,'Subscriptions'
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	*/

BEGIN
				
	SET NOCOUNT ON

	INSERT INTO [tescosubscription].[CustomerPaymentHistoryResponse]
			   ([CustomerPaymentHistoryID]
			   ,[PaymentStatusID]
			   ,[Remarks])
		 VALUES
			   (
				@CustomerPaymentHistoryID
			   ,@StatusID
			   ,@Remarks  )

	
END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerPaymentHistoryResponseCreate] TO [SubsUser]
GO
