SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Coupon].[CouponDetailsGetAll]
AS
	/*
Author:		Swaraj
Created:	04/Oct/2012
Purpose:	Get All Coupons Details


Example:
Execute [coupon].[CouponDetailsGetAll]
--Modifications History--
Changed On   Changed By  Defect  Changes  Change Description 

*/

BEGIN
	SET NOCOUNT ON;	
	
	SELECT c.CouponID,
	       c.CouponCode,
	       c.DescriptionShort,
	       c.DescriptionLong,
	       c.Amount,
	       c.RedeemCount,
	       c.IsActive,
	       c.UTCCreatedeDateTime,
	       (
	           SELECT ca.AttributeID,
	                  ca.AttributeValue 
	           FROM   Coupon.CouponAttributes ca	           
	           WHERE  ca.CouponID = c.CouponID
	                  FOR XML PATH('CouponAttribute'),TYPE, ROOT('CouponAttributes')
	       ) Attributes
	FROM   Coupon.Coupon c (NOLOCK)	
	ORDER BY
	       c.UTCCreatedeDateTime DESC
END
GO
GRANT EXECUTE ON  [Coupon].[CouponDetailsGetAll] TO [SubsUser]
GO
