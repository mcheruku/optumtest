SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionPlanGet] 
(
     @CustomerID BIGINT,
     @BusinessTypeId TINYINT,
     @DeliveryTypeId TINYINT  
)

AS
/*
Author:			Robin
Date created:	12/12/2012
Purpose:		Returns the subscription details for a customer based upon Business, Delivery type and CustomerId
Behaviour:		How does this procedure actually work
Usage:			
Called by:		<DS>
exec [tescosubscription].[CustomerSubscriptionPlanGet] 

--Modifications History--
	Changed On		Changed By		Defect Ref		                                Change Description
	12/06/2012       Robin	         Correction ** Create Procedure
	
*/
BEGIN
	   
	SET NOCOUNT ON

	CREATE TABLE #TempPlanGet
	(PlanName VARCHAR(50),BasketValue SMALLMONEY, PlanDescription varchar(255), StatusName VARCHAR(20)
	,StatusID TINYINT,CustomerPlanStartDate DATETIME,CustomerPlanEndDate DATETIME
	,SubscriptionPlanID INT,ISSlotRestricted BIT) 

	INSERT #TempPlanGet 	
	SELECT TOP 1
		SP.Planname,
		SP.BasketValue,
		SP.PlanDescription,
		SN.StatusName,
		SN.StatusId,
		CS.CustomerPlanStartDate,
		CS.CustomerPlanEndDate,
		SP.SubscriptionPlanID,
		SP.ISSlotRestricted	   
	FROM [Tescosubscription].[CustomerSubscription] CS (NOLOCK)  
	INNER JOIN [Tescosubscription].[SubscriptionPlan] SP (NOLOCK)
	ON CS.SubscriptionPlanID  = SP.SubscriptionPlanID
	INNER JOIN [Tescosubscription].[StatusMaster] SN (NOLOCK)
	ON CS.SubscriptionStatus = SN.StatusID
	WHERE CS.Customerid = @CustomerID
	AND SP.BusinessID = @BusinessTypeId
	AND SP.SubscriptionID = @DeliveryTypeId
	ORDER BY CS.CustomerPlanStartDate desc
	--AND CS.SubscriptionStatus in (8,11) 					


	SELECT
		SubscriptionPlanID,
		Planname,
		PlanDescription,
		BasketValue,
		StatusName,
		StatusId,
		CustomerPlanStartDate,
		CustomerPlanEndDate,
		ISSlotRestricted
	FROM #TempPlanGet

	IF (SELECT ISSlotRestricted FROM #TempPlanGet) = 1
	BEGIN
		SELECT 
			DOW
		FROM #TempPlanGet SubsPlan  
		INNER JOIN [Tescosubscription].[SubscriptionPlanSlot] Slot (NOLOCK)  
		ON SubsPlan.SubscriptionPlanID  = Slot.SubscriptionPlanID
		ORDER BY DOW
	END


	DROP TABLE #TempPlanGet		 

END 


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionPlanGet] TO [SubsUser]
GO
