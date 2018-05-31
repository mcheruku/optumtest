SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionHistoryGet]
(
	@CustomerSubscriptionID BIGINT	
)
AS

/*

	Author:			Thulasi Rangan
	Date created:	19/08/2011
	Purpose:		Returns Customer subscription History Details	
	Behaviour:		Fetches all the records in the Customer subscription History for the given subscription.
	Usage:			
	Called by:		
	Warm up script	exec [tescosubscription].[CustomerSubscriptionHistoryGet] 9

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	

*/

	BEGIN
	
	SET NOCOUNT ON
	
			SELECT [SubscriptionHistoryID]
				   ,CSH.[CustomerSubscriptionID]
		           ,SM.StatusName
		           ,CSH.UTCCreatedDateTime
				   ,[Remarks]
		           ,CS.CustomerID as [CustomerID]
		  FROM tescosubscription.CustomerSubscription CS 
		  INNER JOIN	[tescosubscription].[CustomerSubscriptionHistory] CSH ON CS.CustomerSubscriptionID = @CustomerSubscriptionID AND CSH.CustomerSubscriptionID = CS.CustomerSubscriptionID
		  INNER JOIN	tescosubscription.StatusMaster SM ON  CSH.SubscriptionStatus = SM.StatusId  
		  ORDER BY [SubscriptionHistoryID] ASC
	END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionHistoryGet] TO [SubsUser]
GO
