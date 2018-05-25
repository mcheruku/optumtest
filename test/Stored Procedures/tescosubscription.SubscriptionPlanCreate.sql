SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[SubscriptionPlanCreate] 
(
	 @CountryCurrencyID			TINYINT
	,@BusinessID				TINYINT
	,@SubscriptionID		    TINYINT
	,@PlanName					VARCHAR(50)
	,@PlanDescription			VARCHAR(255)
	,@SortOrder					SMALLINT
	,@PlanTenure				INT
	,@PlanEffectiveStartDate    DATETIME
	,@PlanEffectiveEndDate		DATETIME 
	,@PlanAmount				SMALLMONEY		
	,@IsActive					BIT
	,@RecurringMonths			TINYINT
	,@PlanMaxUsage				SMALLINT
	,@BasketValue				SMALLMONEY
	,@FreePeriod				TINYINT	
	,@TermConditions			VARCHAR(255) = Null
	,@LogicErrorOut			    VARCHAR(50) output
)

AS

/*  Author:			Praneeth Raj
	Date created:	27 July 2011
	Purpose:	    To insert subscription plan details into SubscriptionPlan table	
	Behaviour:		
	Usage:			
	Called by:		
	WarmUP Script:	Execute [tescosubscription].[SubscriptionPlanCreate]

--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	27-July-2011    Sheshgiri Balgi					Removed the unwanted input parameters
	03-Aug-2011		Saritha k						BasketValue datatype changed from decimal to smallmoney
	05-Aug-2011		Saritha K						SortOrder datatype changed from tinyint to smallint
	05-Sep-2011		Saritha K                       Removed Scope identity and used Output clause - Perf Tuning
	05-Jul-2013     Robin                           Increased the datatype for PlanName from 30 to 50
*/

BEGIN

	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlan]WHERE [SortOrder] = @SortOrder)
					
		BEGIN
			SET @LogicErrorOut = 'Plan exists with given priority'
		END	
	ELSE

	BEGIN

	INSERT INTO [tescosubscription].[SubscriptionPlan]           
			([CountryCurrencyID]
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
           ,[FreePeriod])       
           OUTPUT Inserted.SubscriptionPlanID    
		   VALUES	
           (
				 @CountryCurrencyID
				,@BusinessID
				,@SubscriptionID
				,@PlanName
				,@PlanDescription
				,@SortOrder
				,@PlanTenure
				,@PlanEffectiveStartDate
				,@PlanEffectiveEndDate
				,@PlanAmount				
				,@TermConditions
				,@IsActive
				,@RecurringMonths
				,@PlanMaxUsage
				,@BasketValue
				,@FreePeriod								
		   )
	
	--SELECT 	SCOPE_IDENTITY() SubscriptionPlanID
		
END

END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanCreate] TO [SubsUser]
GO
