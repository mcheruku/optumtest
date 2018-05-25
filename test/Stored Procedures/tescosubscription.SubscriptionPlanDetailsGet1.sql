SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionPlanDetailsGet1] 
(
@SubscriptionPlanID INT
)

AS

/*

	Author:			Robin
	Date created:	29/11/2012
	Purpose:		To get list of subscriptionPlan details for given SubscriptionPlanID
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [tescosubscription].[SubscriptionPlanDetailsGet1]

	--Modifications History--
	Changed On		Changed By		Defect Ref		                                               Change Description
	12/06/2012	     Robin	       Added where condition for subscriptionplanid	
	12/06/2012       Robin	       Correction Create Procedure
	

*/

BEGIN
SET NOCOUNT ON
DECLARE 
@ErrorMessage NVARCHAR(2048)


SELECT [SubscriptionPlanID]     'SubscriptionPlanID'
      ,[CountryCurrencyID]      'CountryCurrencyID'
      ,[BusinessID]				'BusinessID'
      ,[SubscriptionID]			'SubscriptionID'
      ,[PlanName]				'PlanName'
      ,[PlanDescription]	    'PlanDescription'
      ,[SortOrder]				'SortOrder'
      ,[PlanTenure]				'PlanTenure'
      ,[PlanEffectiveStartDate] 'PlanEffectiveStartDate'
      ,[PlanEffectiveEndDate]	'PlanEffectiveEndDate'
      ,[PlanAmount]				'PlanAmount'
	  ,[TermConditions]         'TermConditions'
      ,[IsActive]			    'IsActive'
      ,[RecurringMonths]		'RecurringMonths'
      ,[PlanMaxUsage]		    'PlanMaxUsage'
      ,[BasketValue]            'BasketValue'
      ,[FreePeriod]             'FreePeriod'
	  ,PaymentInstallmentID		'PaymentInstallmentID'
	 
FROM  [tescosubscription].[SubscriptionPlan] (NOLOCK)
WHERE [SubscriptionPlanID] = @SubscriptionPlanID


IF @@ROWCOUNT > 0 
BEGIN

IF EXISTS(SELECT 1 FROM  [tescosubscription].[SubscriptionPlan] (NOLOCK)
			WHERE [SubscriptionPlanID] = @SubscriptionPlanID AND ISSlotRestricted=1)
	SELECT DOW FROM [tescosubscription].[SubscriptionPlanSlot] (NOLOCK)
	        WHERE [SubscriptionPlanID] = @SubscriptionPlanID
 
ELSE
	SELECT 1 DOW UNION ALL
	SELECT 2 DOW UNION ALL
	SELECT 3 DOW UNION ALL
	SELECT 4 DOW UNION ALL
	SELECT 5 DOW UNION ALL
	SELECT 6 DOW UNION ALL
	SELECT 7 DOW


END

END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanDetailsGet1] TO [SubsUser]
GO
