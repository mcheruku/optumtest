SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [tescosubscription].[CustomerPaymentHistorySave]
(
		--INPUT PARAMETERS HERE--
	 @CustomerPaymentID				BIGINT
	,@CustomerSubscriptionID		BIGINT
    ,@PaymentAmount					SMALLMONEY
	,@Channel						VARCHAR(20) 
)
AS

/*

	Author:			Rajendra Singh
	Date created:	20 Jun 2011
	Purpose:		To insert the status of the payment for each payment record in table CustomerPaymentHistory
	Behaviour:		This procedure is called from Appstore on receiving response from CPS
	Usage:			Often in batch
	Called by:		AppStore
	WarmUP Script:	Execute [tescosubscription].[CustomerPaymentHistorySave] 11,23456,1,'Success',10,'Subscriptions'
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	<14 Jul 2011>	<Thulasi>						< Changed @StatusID type as TINYINT from SMALLINT>
	<23 Jul 2011>	<Thulasi>						<Based on the Channel update the status, IsFirstPaymentDue as false in the CustomerPayment>
	25 Aug 2011		Manjunathan						Removed PreAuth Logic
	16 Sep 2011		Thulasi					        Channel type changed from char(3) to varchar(20)
	27 Sep 2011		Manjunathan						returns the INSERTED CustomerPaymentHistoryid
	27 Dec 2011		Ramesh CH						Removed columns paymentStatusID and Remarks from CustomerPaymentHistory
*/

BEGIN
	DECLARE @ChannelID							TINYINT
			,@CurrentDate						DATETIME
				
	SET NOCOUNT ON

	SELECT @CurrentDate = GETDATE()
		   ,@ChannelID=ChannelID 
    FROM tescosubscription.ChannelMaster WITH (NOLOCK) WHERE ChannelName=@Channel

		INSERT	INTO tescosubscription.CustomerPaymentHistory 
			(
				[CustomerPaymentID]
			   ,[CustomerSubscriptionID]  
			   ,[PaymentDate]
			   ,[PaymentAmount]
			   ,[ChannelID]
			) output INSERTED.CustomerPaymentHistoryid 
			
		VALUES	( @CustomerPaymentID, 
				  @CustomerSubscriptionID, 
		          @CurrentDate, 
		          @PaymentAmount, 
		          @ChannelID )
END



GO
GRANT EXECUTE ON  [tescosubscription].[CustomerPaymentHistorySave] TO [SubsUser]
GO
