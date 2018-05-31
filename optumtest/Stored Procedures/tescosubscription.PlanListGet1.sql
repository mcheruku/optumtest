SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[PlanListGet1]
(
	--INPUT PARAMETERS HERE--
	@SubscriptionPlanRefNumber	INT
	,@CountryCode				CHAR(2)
	,@CountryCurrency			CHAR(3)
	,@SubscriptionName			VARCHAR(30) 
	,@BusinessName				VARCHAR(30)
	
)
AS

/*

	Author:			Robin
	Date created:	11 Dec	2012
	Purpose:		To get all the Subscription Plan for a given business, subscription Type and region
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<MT/BOA/DBA>
	WarmUP Script:	Execute [tescosubscription].[PlanListGet] 'GB', 'GBP', 'Delivery', 'Grocery'
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	
*/

BEGIN

	SET NOCOUNT ON
	
	--DECLARE variables here--
	
	--DECLARE TABLE variables here--
	
	IF (@SubscriptionPlanRefNumber >0)
		BEGIN
			SELECT [SubscriptionPlanID]
				  ,[PlanName]
				  ,[PlanDescription]			     
				  ,[PlanTenure]
				  ,[PlanAmount]
				  ,[TermConditions]
				  ,[IsActive]
				  ,[RecurringMonths]
				  ,[PlanMaxUsage]
				  ,[BasketValue]
				  ,[FreePeriod]
				  ,[PlanEffectiveStartDate]
				  ,[PlanEffectiveEndDate]
				  ,[CCM].CountryCurrency	
			FROM tescosubscription.SubscriptionPlan SP WITH (NOLOCK)
			INNER JOIN tescosubscription.CountryCurrencyMap CCM WITH (NOLOCK) ON 
			CCM.CountryCurrencyID = SP.CountryCurrencyID
			WHERE SP.SubscriptionPlanID = @SubscriptionPlanRefNumber

			SELECT 
				DOW
			FROM tescosubscription.SubscriptionPlan SP WITH (NOLOCK)
			INNER JOIN [Tescosubscription].[SubscriptionPlanSlot] Slot (NOLOCK)  
				ON SP.SubscriptionPlanId = Slot.SubscriptionPlanId
			Where SP.SubscriptionPlanID = @SubscriptionPlanRefNumber
				and SP.IsSlotRestricted = 1
				Order by DOW
		END
	ELSE 
		BEGIN

			SELECT [SubscriptionPlanID]
				  ,[PlanName]
				  ,[PlanDescription]
				  ,[PlanTenure]
				  ,[PlanAmount]
				  ,[TermConditions]
				  ,[IsActive]
				  ,[RecurringMonths]
				  ,[PlanMaxUsage]
				  ,[BasketValue]
				  ,[FreePeriod]
				  ,[PlanEffectiveStartDate]
				  ,[PlanEffectiveEndDate]
				  ,[CCM].CountryCurrency
			FROM tescosubscription.SubscriptionPlan SP  WITH (NOLOCK)
			INNER JOIN tescosubscription.CountryCurrencyMap CCM WITH (NOLOCK) ON CCM.CountryCurrencyID = SP.CountryCurrencyID 
																AND CCM.CountryCode	= @CountryCode
																AND CCM.CountryCurrency	= @CountryCurrency
			INNER JOIN tescosubscription.SubscriptionMaster SM  WITH (NOLOCK)ON SM.SubscriptionID = SP.SubscriptionID
																AND	SM.SubscriptionName	= @SubscriptionName
			INNER JOIN tescosubscription.BusinessMaster BM  WITH (NOLOCK)ON BM.BusinessID = SP.BusinessID
																AND BM.BusinessName	= @BusinessName

			ORDER BY [SortOrder]				
		END
END

GO
GRANT EXECUTE ON  [tescosubscription].[PlanListGet1] TO [SubsUser]
GO
