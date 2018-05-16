SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Coupon].[CouponGet]
(
	@CouponCode				NVARCHAR(25)	
)
AS

/*
	Author:		Shilpa
	Created:	18/Sep/2012
	Purpose:	Get coupon based on couponCode

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 

*/
	
BEGIN

	SET NOCOUNT ON;	
	

	SELECT pvt.Amount, pvt.[2] EffectiveStartDateTime, Pvt.[3] EffectiveEndDateTime FROM
	(
		SELECT 
			AttributeValue,
			AttributeID,
			c.Amount
		FROM Coupon.coupon c (NOLOCK) JOIN		
			coupon.CouponAttributes ca (NOLOCK) ON ca.CouponID = c.CouponID
		WHERE c.CouponCode = @CouponCode 
	) A
	PIVOT (
		 MIN(Attributevalue)
		 FOR AttributeID in ([2],[3])
	) pvt
 

END


GO
GRANT EXECUTE ON  [Coupon].[CouponGet] TO [SubsUser]
GO
