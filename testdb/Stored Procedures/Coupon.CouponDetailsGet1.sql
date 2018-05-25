SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Coupon].[CouponDetailsGet1]
(
	@CouponCode				NVARCHAR(25)	
)
AS


/*
	Author:		Robin
	Created:	15/Jul/2013
	Purpose:	Get coupon based on couponCode

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 

*/

BEGIN

	SET NOCOUNT ON;	

-- To get Coupon Details

SELECT 
		CC.CouponCode,
		CM.DescriptionShort,
		CM.DescriptionLong,
		CM.Amount,
		CC.RedeemCount,
		CC.IsActive,
        CM.campaignTypeID CouponType
        FROM Coupon.Coupon CC (NOLOCK)
        INNER JOIN Coupon.Campaign CM (NOLOCK)
        ON CC.CampaignID = CM.CampaignID
        WHERE CouponCode = @CouponCode



-- To get the CustomerID for the LinkedCoupons  CASE WHEN TM.CampaignTypeID IN (1,2) THEN NULL ELSE 

    SELECT CM.CustomerID  CustomerID
    FROM [Coupon].[CouponCustomerMap] CM (NOLOCK)
    INNER JOIN [Coupon].[Coupon] CC (NOLOCK)
    ON CM.CouponID = CC.CouponID
    INNER JOIN [Coupon].[Campaign] CI (NOLOCK)
    ON CC.CampaignID = CI.CampaignID
    WHERE  CC.CouponCode = @CouponCode AND CI.CampaignTypeID=3


-- To get Coupons attributes

	SELECT 
		ca.AttributeId,
		ca.AttributeValue
	FROM
		Coupon.Coupon c (NOLOCK)
	INNER JOIN 
		Coupon.CampaignAttributes ca (NOLOCK)
	ON c.campaignid = ca.campaignid
	WHERE
		CouponCode = @CouponCode
	ORDER BY ca.AttributeId

END

GO
GRANT EXECUTE ON  [Coupon].[CouponDetailsGet1] TO [SubsUser]
GO
