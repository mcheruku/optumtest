SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[PlanListGet]
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

	Author:			Rajendra Singh
	Date created:	16 Jun 2011
	Purpose:		To get all the Subscription Plan for a given business, subscription Type and region
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<MT/BOA/DBA>
	WarmUP Script:	Execute [tescosubscription].[PlanListGet] 'GB', 'GBP', 'Delivery', 'Grocery'
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	<26 Jul 2011>	<Thulasi>						<Added the fields PlanDescription and Sort Order. The SP Returns the PlanList based on Sort Order>
	<11/12/2012>    <Robin>                         <Added where condition on ln81>
	<12/12/2012>	<Robin>							<Added Order By for midweek plan>
	<12/17/2012>	<Robin>							<Removed select DOW for midweek plan>
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
			INNER JOIN tescosubscription.CountryCurrencyMap CCM 
			WITH (NOLOCK)ON  SP.SubscriptionPlanID = @SubscriptionPlanRefNumber AND CCM.CountryCurrencyID = SP.CountryCurrencyID
			WHERE SP.SubscriptionPlanID = @SubscriptionPlanRefNumber

			
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
GRANT EXECUTE ON  [tescosubscription].[PlanListGet] TO [SubsUser]
GO
