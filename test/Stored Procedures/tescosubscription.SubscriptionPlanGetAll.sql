SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[SubscriptionPlanGetAll]


AS

/*

	Author:			Saritha kommineni
	Date created:	02 Aug 2011
	Purpose:		To get all SubscriptionPlans
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [tescosubscription].[SubscriptionPlanGetAll] 

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
    05/08/2011		Ravi Paladugu					added [PlanEffectiveStartDate],[PlanEffectiveEndDate],[IsActive],[SortOrder] in select list
	05/08/2011		Ravi Paladugu					added Order by clause for SortOrder

*/
BEGIN 

SET NOCOUNT ON

SELECT	SP.[SubscriptionPlanID] 'SubscriptionPlanID'
		,SP.[PlanName]   'PlanName'
		,SP.[PlanTenure] 'PlanTenure'
		,SP.[PlanAmount] 'PlanAmount'
		,BM.[BusinessName] 'BusinessType'
        ,SM.[SubscriptionName]  'SubscriptionType'
		,SP.[PlanEffectiveStartDate] 'PlanEffectiveStartDate'
		,SP.[PlanEffectiveEndDate] 'PlanEffectiveEndDate'
		,SP.[IsActive] 'IsActive'
		,SP.[SortOrder] 'SortOrder'
FROM    [tescosubscription].[tescosubscription].[SubscriptionPlan] SP (NOLOCK)
INNER JOIN [tescosubscription].[tescosubscription].[BusinessMaster] BM  (NOLOCK)
ON		SP.[BusinessID]= BM.[BusinessID] 
INNER JOIN [tescosubscription].[tescosubscription].[SubscriptionMaster] SM  (NOLOCK)
ON      SP.[SubscriptionID]= SM.[SubscriptionID]
order by SP.[SortOrder]
FOR XML PATH('SubscriptionPlan'),TYPE,root('SubscriptionPlans')

END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanGetAll] TO [SubsUser]
GO
