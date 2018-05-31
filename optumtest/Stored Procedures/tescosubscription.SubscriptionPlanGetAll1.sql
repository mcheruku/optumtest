SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionPlanGetAll1]


AS

/*

	Author:			Robin John
	Date created:	05 Dec 2012
	Purpose:		To get all SubscriptionPlans
	Behaviour:		How does this procedure actually work
	 
	Called by:		<BOA>
	Script:	Execute [tescosubscription].[SubscriptionPlanGetAll1] 

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
    12/06/2012		Robin							Correction **CREATE PROCEDURE
	13/12/2012		Robin							Granted permissions
*/
BEGIN 

SET NOCOUNT ON

SELECT [SubscriptionPlanID] 
      ,[CountryCurrencyID]       
	  ,[BusinessID]				 
	  ,[SubscriptionID]			 
	  ,[PlanName]				 
	  ,[PlanDescription]	    
	  ,[SortOrder]				 
	  ,[PlanTenure]				 
	  ,[PlanEffectiveStartDate]  
	  ,[PlanEffectiveEndDate]	 
	  ,[PlanAmount]				 
	  ,[TermConditions]         
	  ,[IsActive]			    
	  ,[RecurringMonths]		 
	  ,[PlanMaxUsage]		    
	  ,[BasketValue]             
	  ,[FreePeriod]              
	  ,[PaymentInstallmentID]	 
		 
FROM    [tescosubscription].[tescosubscription].[SubscriptionPlan] (NOLOCK) 

END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanGetAll1] TO [SubsUser]
GO
