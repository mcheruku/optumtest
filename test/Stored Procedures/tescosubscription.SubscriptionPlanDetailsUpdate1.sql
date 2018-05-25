SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[SubscriptionPlanDetailsUpdate1]

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
		@LogicErrorOut varchar(100) output,
        @SlotXML					XML,
	    @PaymentInstallmentID		TINYINT
 AS

/*  Author:			Robin
	Date created:	29/11/2012
	Purpose:	    To update subscription plan details into SubscriptionPlan table	
	Behaviour:		
	Usage:			
	Called by:		
    Script:	Execute [tescosubscription].[SubscriptionPlanDetailsUpdate1]

--Modifications History--
	Changed On		Changed By		Defect Ref		                                               Change Description
	12/06/2012	     Robin	       Removed 'Details Updated successfully' from logic error 
	                               since it is not caputed 
    12/06/12         Robin		   Correction ** CREATE PROCEDURE
*/

BEGIN

	SET NOCOUNT ON

DECLARE @CurrentUTCDate datetime, @IsSlotRestricted BIT,@ErrorMessage NVARCHAR(2048)
SET		@CurrentUTCDate = GETUTCDATE()

BEGIN TRY

IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlan] WHERE SubscriptionPlanID <> @SubscriptionPlanID and sortorder =  @sortorder)
BEGIN
	 SET @LogicErrorOut = 'Sort Order already exists'
END

ELSE IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlan] WHERE SubscriptionPlanID = @SubscriptionPlanID)
				
BEGIN
SELECT @IsSlotRestricted= CASE WHEN COUNT(*) = 7 THEN 0 ELSE 1 END FROM(
									SELECT
										DISTINCT T.C.value('@DOW', 'TINYINT') DOW
									FROM  @SlotXML.nodes('Slots/Slot') T(c)) A	

    BEGIN TRAN

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
			UTCUpdatedDateTime     =@CurrentUTCDate,
            IsSlotRestricted	   =@IsSlotRestricted,
            PaymentInstallmentID   = @PaymentInstallmentID
	WHERE	SubscriptionPlanID     = @SubscriptionPlanID

	IF @IsSlotRestricted = 1 
	BEGIN
		INSERT INTO [tescosubscription].[SubscriptionPlanSlot]
		   ([SubscriptionPlanID]
		   ,[DOW])
		SELECT @SubscriptionPlanID,T.C.value('@DOW', 'TINYINT')  
			FROM @SlotXML.nodes('Slots/Slot') T(c)
			LEFT JOIN [tescosubscription].[SubscriptionPlanSlot] Slot
				ON SubscriptionPlanID=@SubscriptionPlanID
					AND T.C.value('@DOW', 'TINYINT') =DOW
			WHERE SubscriptionPlanID IS NULL

		DELETE Slot
			FROM [tescosubscription].[SubscriptionPlanSlot] Slot
			LEFT JOIN  @SlotXML.nodes('Slots/Slot') T(c)
				ON T.C.value('@DOW', 'TINYINT') =DOW
			WHERE  SubscriptionPlanID=@SubscriptionPlanID
					AND T.C.value('@DOW', 'TINYINT') IS NULL
			
	END
	ELSE IF EXISTS(SELECT 1 FROM [tescosubscription].[SubscriptionPlanSlot] (NOLOCK) WHERE SubscriptionPlanID=@SubscriptionPlanID )
	BEGIN
		DELETE Slot
			FROM [tescosubscription].[SubscriptionPlanSlot] Slot
		WHERE SubscriptionPlanID=@SubscriptionPlanID
	END

		
		COMMIT TRAN		

        SET		@LogicErrorOut = ''
			 	
		END

ELSE 
BEGIN
       SET @LogicErrorOut = 'SubscriptionPlanID does not exist'
END

END TRY
BEGIN CATCH
	SELECT @ErrorMessage = ERROR_MESSAGE()
	
	IF @@TRANCOUNT > 0        
		BEGIN
			ROLLBACK TRAN
		END 

	RAISERROR ('SP - [tescosubscription].[SubscriptionPlanDetailsUpdate1] Error = (%s)',16,1,@ErrorMessage) 
	
        
END CATCH


   
END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionPlanDetailsUpdate1] TO [SubsUser]
GO
