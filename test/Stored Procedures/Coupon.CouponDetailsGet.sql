SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [Coupon].[CouponDetailsGet]
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

	SELECT 
		CouponCode,
		DescriptionShort,
		DescriptionLong,
		Amount,
		RedeemCount,
		IsActive	
	FROM
		Coupon.Coupon c (NOLOCK)
	WHERE
		CouponCode = @CouponCode


	SELECT 
		ca.AttributeId,
		ca.AttributeValue
	FROM
		Coupon.Coupon c (NOLOCK)
	INNER JOIN 
		Coupon.CouponAttributes ca (NOLOCK)
	ON c.CouponID = ca.CouponID
	WHERE
		CouponCode = @CouponCode
	ORDER BY ca.AttributeId

END

GO
GRANT EXECUTE ON  [Coupon].[CouponDetailsGet] TO [SubsUser]
GO
