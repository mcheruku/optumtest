SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionPlanDetailsUpdate]

		@SubscriptionPlanID	int  ,
		@CountryCurrencyID tinyint ,
		@BusinessID tinyint ,
		@SubscriptionID tinyint ,
		@PlanName varchar(50) ,
		@PlanDescription varchar(255)  ,
		@SortOrder smallint ,
		@PlanTenure int ,
		@PlanEffectiveStartDate datetime ,
		@PlanEffectiveEndDate datetime ,
		@PlanAmount smallmoney ,
		@IsActive bit ,
		@RecurringMonths tinyint ,
		@PlanMaxUsage smallint  ,
		@BasketValue smallmoney ,
		@FreePeriod tinyint ,
		@TermConditions varchar(500) = Null,
		@LogicErrorOut varchar(100) output

AS

/*  Author:			Saritha Kommineni
	Date created:	09 Aug 2011
	Purpose:	    To update subscription plan details into SubscriptionPlan table	
	Behaviour:		
	Usage:			
	Called by:		
	WarmUP Script:	Execute [tescosubscription].[SubscriptionPlanCreate]

--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	05/07/2013      Robin                           Increase the datatype for PlanName from 30 to 50	
*/

BEGIN

	SET NOCOUNT ON

DECLARE @CurrentUTCDate datetime
SET		@CurrentUTCDate = GETUTCDATE()

IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlan] WHERE SubscriptionPlanID <> @SubscriptionPlanID and sortorder =  @sortorder)
BEGIN
	 SET @LogicErrorOut = 'Sort Order already exists'
END

ELSE IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlan] WHERE SubscriptionPlanID = @SubscriptionPlanID)
				
BEGIN

	UPDATE  tescosubscription.SubscriptionPlan
	SET		CountryCurrencyID =COALESCE(@CountryCurrencyID,CountryCurrencyID),
			BusinessID		  =COALESCE(@BusinessID,BusinessID),
			SubscriptionID	  =COALESCE(@SubscriptionID,SubscriptionID),
			PlanName          =COALESCE(@PlanName,PlanName),
			PlanDescription   =COALESCE(@PlanDescription,PlanDescription),
            SortOrder         =COALESCE(@SortOrder,SortOrder),
			PlanTenure        =COALESCE(@PlanTenure,PlanTenure),
			PlanEffectiveStartDate =COALESCE(@PlanEffectiveStartDate,PlanEffectiveStartDate),
			PlanEffectiveEndDate   =COALESCE(@PlanEffectiveEndDate,PlanEffectiveEndDate),
			PlanAmount			   =COALESCE(@PlanAmount,PlanAmount),
			TermConditions         =COALESCE(@TermConditions,TermConditions),
			IsActive               =COALESCE(@IsActive,IsActive),
			RecurringMonths        =COALESCE(@RecurringMonths,RecurringMonths),
			PlanMaxUsage           =COALESCE(@PlanMaxUsage,PlanMaxUsage),
			BasketValue            =COALESCE(@BasketValue,BasketValue),
			FreePeriod             =COALESCE(@FreePeriod,FreePeriod),
			UTCUpdatedDateTime     =@CurrentUTCDate
	WHERE	SubscriptionPlanID     = @SubscriptionPlanID

    SET		@LogicErrorOut = 'Details Updated successfully  '
END

ELSE 
BEGIN
       SET @LogicErrorOut = 'SubscriptionPlanID does not exist'
 END

END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanDetailsUpdate] TO [SubsUser]
GO
