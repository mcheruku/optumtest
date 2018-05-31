SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionGet]
	(@CustomerSubscriptionID BIGINT)
AS
/*
Author:		Robin
Create date: 10 - Feb - 2013
Purpose: To get the customer subscription
Called by:		DS and Juvo

--Modifications History--
Changed On		Changed By		Defect Ref		Change Description
 
*/

BEGIN	
	SET NOCOUNT ON;

	SELECT [CustomerSubscriptionID]
      ,[CustomerID]
      ,[SubscriptionPlanID]
      ,[CustomerPlanStartDate]
      ,[CustomerPlanEndDate]
      ,[NextRenewalDate]
      ,[SubscriptionStatus]
      ,[PaymentProcessStatus]
      ,[RenewalReferenceDate]
      ,[EmailSentRenewalDate]
      ,[UTCCreatedDateTime]
      ,[UTCUpdatedDateTime]
      ,[SwitchCustomerSubscriptionID]
      ,[SwitchTo]
	FROM [TescoSubscription].[tescosubscription].[CustomerSubscription](NOLOCK)
	WHERE [CustomerSubscriptionID] = @CustomerSubscriptionID
END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionGet] TO [SubsUser]
GO
