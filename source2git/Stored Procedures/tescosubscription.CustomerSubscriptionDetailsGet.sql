SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionDetailsGet]
(
	@CustomerID BIGINT 
)
AS

/*

	Author:			Sheshgiri Balgi 
	Date created:	22/07/2011
	Purpose:		Returns Customer subscription Details	
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	03 Aug 2011		Saritha K						Added statusid in where condition to filter deactived subscriptions
	09 Aug 2011		Saritha K						Modified PlanName to PlanDescription and added statusid (9) in where condition to filter cancelled subscriptions
    24 Aug 2011		Saritha K						Added statusid (10) in where condition to cancel stopped subscriptions
    23 Sep 2011	    saritha K						Added Condition to filter subscription with status OrderInitiated
	12 Mar 2013     Robin                           Added Status for Switch
*/

BEGIN

  SET NOCOUNT ON		
	

SELECT
        cs.SubscriptionPlanID    'SubscriptiomPlanID',
		cs.CustomerPlanStartDate 'SubscriptionStartDate',
        cs.CustomerPlanEndDate	 'SubscriptionEndDate',
        sm.StatusName            'SubscriptionStatus', 				  
		(
		SELECT sp.SubscriptionID 'SubscriptionID',
               sp.PlanDescription  'PlanDescription',
               sp.PlanTenure     'PlanTenure',
               sp.PlanAmount     'PlanValue', 
               sp.IsActive       'IsActive', 
               sp.BasketValue    'BasketValue'              
		FROM tescosubscription.SubscriptionPlan sp 
		WHERE sp.SubscriptionPlanID = cs.SubscriptionPlanID
		FOR XML PATH(''),TYPE
		)'PlanDetails'
	FROM tescosubscription.CustomerSubscription cs
	JOIN  tescosubscription.StatusMaster sm  ON sm.StatusId = cs.SubscriptionStatus
	WHERE cs.CustomerID = @CustomerID AND sm.statusid not in (9,10,15,16) --Filter Stopped,OrderInitiated and Cancelled Subscription
	FOR XML PATH('CustomerSubscriptionDetails'),TYPE
		
END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionDetailsGet] TO [SubsUser]
GO
