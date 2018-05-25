SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Coupon].[CouponDetailsValidate]
(
	@CouponCode				NVARCHAR(25)	
)
AS


/*
	Author:		Robin
	Created:	20/Feb/2014
	Purpose:	Get coupon detils for validation based on couponCode
    Called By:  Coupon Service

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 

*/

BEGIN

	SET NOCOUNT ON;	

DECLARE 
@listStr VARCHAR(200), 
@CampaignID BIGINT 

		SELECT @listStr = COALESCE(@listStr + ', ' ,'') + CONVERT(VARCHAR,PD.SubscriptionPlanID),@CampaignID= CC.CampaignID  
		FROM Coupon.CampaignPlanDetails PD WITH (NOLOCK)
		INNER JOIN Coupon.Coupon CC WITH (NOLOCK)
		ON CC.CampaignID = PD.CampaignID 
		WHERE CC.CouponCode = @CouponCode

;WITH PlanIDCTE(PlanIDs,CampaignID) AS (SELECT @listStr,@CampaignID)

-- To get Coupon Details

		SELECT 
		CC.CouponCode,
		CM.DescriptionShort,
		CM.DescriptionLong,
		CC.RedeemCount,
		CC.IsActive,
        CM.campaignTypeID CouponType,
        PD.PlanIDs,
		CM.UsageTypeID
        FROM Coupon.Coupon CC WITH (NOLOCK)
        INNER JOIN Coupon.Campaign CM WITH (NOLOCK)
        ON CC.CampaignID = CM.CampaignID
        LEFT JOIN PlaniDCTE PD
        ON PD.CampaignID = CC.CampaignID
        WHERE CouponCode = @CouponCode


-- To get the CustomerID for the LinkedCoupons  CASE WHEN TM.CampaignTypeID IN (1,2) THEN NULL ELSE 

		SELECT 
		CM.CustomerID AS CustomerID
		FROM [Coupon].[CouponCustomerMap] CM WITH (NOLOCK)
		INNER JOIN [Coupon].[Coupon] CC WITH (NOLOCK)
		ON CM.CouponID = CC.CouponID
		INNER JOIN [Coupon].[Campaign] CI WITH (NOLOCK)
		ON CC.CampaignID = CI.CampaignID
		WHERE  CC.CouponCode = @CouponCode AND CI.CampaignTypeID=3


-- To get Coupons attributes

		SELECT 
		ca.AttributeId,
		ca.AttributeValue
		FROM Coupon.Coupon CC WITH (NOLOCK)
		INNER JOIN Coupon.CampaignAttributes CA WITH (NOLOCK)
		ON CC.campaignid = CA.campaignid
        WHERE CC.CouponCode = @CouponCode
		AND CA.AttributeId <>1
		ORDER BY CA.AttributeId

END

GO
GRANT EXECUTE ON  [Coupon].[CouponDetailsValidate] TO [SubsUser]
GO
