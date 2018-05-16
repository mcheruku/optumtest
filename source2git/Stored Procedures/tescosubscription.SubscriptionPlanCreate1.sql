SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionPlanCreate1]  
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
	,@SlotXML					XML
	,@PaymentInstallmentID		TINYINT
)

AS

/*  Author:			Robin
	Date created:	29 NOv 3012
	Purpose:	    To insert subscription plan details into SubscriptionPlan table	(BACK OFFICE)
	Behaviour:		
	Usage:			
	Called by:		
	WarmUP Script:	Execute [tescosubscription].[SubscriptionPlanCreate1]
					SELECT @SlotXML='<Slots>
										 <Slot DOW="1"/>
										 <Slot DOW="2"/>
										 <Slot DOW="3"/>
									</Slots>'
   --Modifications History--
	Changed On		Changed By		Defect Ref		                                Change Description
	12/06/12         Robin		                                                   Increased datatype size for planname
*/

BEGIN

SET NOCOUNT ON;

DECLARE @IsSlotRestricted BIT,@ErrorMessage NVARCHAR(2048)

BEGIN TRY

	IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlan]WHERE [SortOrder] = @SortOrder)
					
		BEGIN
			SET @LogicErrorOut = 'Plan exists with given priority'
		END	
	ELSE
	BEGIN

		SELECT @IsSlotRestricted= CASE WHEN COUNT(*) = 7 THEN 0 ELSE 1 END FROM(
									SELECT
										DISTINCT T.C.value('@DOW', 'TINYINT') DOW
									FROM  @SlotXML.nodes('Slots/Slot') T(c)) A	

		DECLARE  @ID TABLE(SubscriptionPlanID INT)

		BEGIN TRAN

		INSERT INTO [Tescosubscription].[SubscriptionPlan]           
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
			   ,[FreePeriod]
			   ,PaymentInstallmentID
			   ,IsSlotRestricted)       
			   OUTPUT Inserted.SubscriptionPlanID INTO @ID
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
					,@PaymentInstallmentID
					,@IsSlotRestricted
			   )
		
		IF @IsSlotRestricted = 1 
		BEGIN
			INSERT INTO [tescosubscription].[SubscriptionPlanSlot]
			   ([SubscriptionPlanID]
			   ,[DOW])
			SELECT SubscriptionPlanID,T.C.value('@DOW', 'TINYINT') FROM @ID
				CROSS JOIN @SlotXML.nodes('Slots/Slot') T(c)
		END
	
		COMMIT TRAN		

		SELECT SubscriptionPlanID FROM @ID 
	
	END

END TRY
	BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE() 
		
		IF @@TRANCOUNT > 0        
			BEGIN
				ROLLBACK TRAN
			END 

		RAISERROR ('SP - [tescosubscription].[SubscriptionPlanCreate1] Error = (%s)',16,1,@ErrorMessage) 
		
	        
	END CATCH

END


GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanCreate1] TO [SubsUser]
GO
