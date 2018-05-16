SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [tescosubscription].[CustomerActiveCouponGet]  
(  
 @CustomerID BIGINT  
)  
AS
/*
	Author:		Robin
	Created:	17/April/2014
	Purpose:	Get PaymentToken(coupon) and Plan Amount Based on CustomerID 

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 

*/ 
BEGIN  
DECLARE @Active TINYINT
, @Suspended TINYINT

SET  @Active = 8
SET  @Suspended = 7

	 SET NOCOUNT ON  
	  
	 SELECT PaymentToken  
	 FROM TescoSubscription.CustomerPayment WITH (NOLOCK)  
	 WHERE CustomerID = @CustomerID AND IsActive = 1 AND IsFirstPaymentdue=1 AND PaymentModeID=2  
	   
	 SELECT PlanAmount FROM Tescosubscription.SubscriptionPlan SP WITH (NOLOCK)   
	 WHERE SP.SubscriptionPlanID IN (SELECT COALESCE(SwitchTo,SubscriptionPlanID) 
	 FROM TescoSubscription.CustomerSubscription   
	 WHERE CustomerId = @CustomerID AND SubscriptionStatus in (@Active,@Suspended) 
	 )  
  
END  





GO
GRANT EXECUTE ON  [tescosubscription].[CustomerActiveCouponGet] TO [SubsUser]
GO
