SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionEmailFlagUpdate]
(
	--INPUT PARAMETERS HERE--
	@TransactionID as varchar(Max)
)
AS

/*

	Author:			Manjunathan Raman
	Date created:	26 Aug 2011
	Purpose:		To update Email flag
	Behaviour:		This procedure is called from Appstore on receiving response from notification service
	Usage:			Often in batch
	Called by:		AppStore
	WarmUP Script:	
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	
*/

BEGIN
	DECLARE @CurrentDate  DATETIME,
			@chrind INT,
			@Piece BIGINT
				
	SET NOCOUNT ON



	CREATE  TABLE #TempCustomerSubscription(TransactionID BIGINT)

	SELECT @chrind = 1,@CurrentDate=GETUTCDATE()
	WHILE @chrind > 0
	BEGIN
		SELECT @chrind = CHARINDEX(',',@TransactionID)
		IF @chrind > 0
			SELECT @Piece = LEFT(@TransactionID,@chrind - 1)
		ELSE
			SELECT @Piece = @TransactionID
		INSERT #TempCustomerSubscription(TransactionID) VALUES(@Piece)
		SELECT @TransactionID = RIGHT(@TransactionID,LEN(@TransactionID) - @chrind)
		IF LEN(@TransactionID) = 0 BREAK
	END

	UPDATE CustSubs
		SET EmailSentRenewalDate=NextRenewalDate,
			UTCUpdatedDateTime=@CurrentDate
	FROM
	 tescosubscription.CustomerSubscription  CustSubs
	JOIN #TempCustomerSubscription TempTb
		ON TempTb.TransactionID=CustomerSubscriptionID
			
	DROP TABLE #TempCustomerSubscription
			
END
GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionEmailFlagUpdate] TO [SubsUser]
GO
