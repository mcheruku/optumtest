SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Coupon].[CouponDetailsGet2]
(
	@CouponCode				NVARCHAR(MAX)
)
AS
/*
	Author:		Robin
	Created:	17/Feb/2014
	Purpose:	Get coupon based on couponCode

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 

*/
BEGIN

	SET NOCOUNT ON;	

DECLARE

@Delimiter    NVARCHAR(1)

SET @Delimiter = ','

DECLARE @CouponTable TABLE  (String NVARCHAR(MAX))


INSERT INTO @CouponTable ( [String] )
(SELECT Item FROM [dbo].[ConvertListToTable] (@CouponCode,@Delimiter))


-- To get the distinct coupon codes
SELECT 
		CC.CouponCode,
        CC.CouponID,
		CM.DescriptionShort,
		CM.DescriptionLong,
		CC.RedeemCount,
		CM.IsActive,
        CM.campaignTypeID CouponType,
		CM.IsMutuallyExclusive
        FROM Coupon.Coupon CC WITH (NOLOCK)
        INNER JOIN Coupon.Campaign CM WITH (NOLOCK)
        ON CC.CampaignID = CM.CampaignID
        WHERE  CC.CouponCode  IN (SELECT String FROM @CouponTable)

-- In case of Linked Coupon

SELECT CC.CouponCode,
       CM.CustomerID
       FROM Coupon.Coupon CC  WITH (NOLOCK)
       INNER JOIN Coupon.CouponCustomerMap CM  WITH (NOLOCK)
       ON CC.CouponID = CM.CouponID
       WHERE CC.CouponCode IN (SELECT String FROM @CouponTable)   

--  Get coupon Discount TypeID
 
SELECT CC.CouponCode,
       CD.DiscountTypeID,
	   CD.DiscountValue
       FROM Coupon.Coupon CC  WITH (NOLOCK)
       INNER JOIN Coupon.CampaignDiscountType CD  WITH (NOLOCK)
       ON CC.CampaignID = CD.CampaignID
       WHERE CC.CouponCode IN (SELECT String FROM @CouponTable) 

--Get the coupon Attributes


SELECT CC.CouponCode,
       CA.AttributeID,
	   CA.AttributeValue
       FROM Coupon.Coupon CC  WITH (NOLOCK)
       INNER JOIN Coupon.CampaignAttributes CA  WITH (NOLOCK)
       ON CC.CampaignID = CA.CampaignID
       WHERE CC.CouponCode IN (SELECT String FROM @CouponTable) 
  
--Get the Plan IDs comma seperated per coupon    
SELECT DISTINCT(C.CouponCode), 
    SUBSTRING(
        (
            SELECT ','+ CONVERT(VARCHAR,CPD1.SubscriptionPlanID) AS [text()]
            From Coupon.CampaignPlanDetails CPD1
            Where CPD1.CampaignID = CPD2.CampaignID
            ORDER BY CPD1.CampaignID
            For XML PATH ('')
        ), 2, 1000) [PlanIDs]
From Coupon.CampaignPlanDetails CPD2 WITH (NOLOCK)
INNER JOIN Coupon.Coupon C   WITH (NOLOCK)
ON CPD2.CampaignID = C.CampaignID 
INNER JOIN @CouponTable CT 
ON CT.[String] = C.CouponCode

END


GO
GRANT EXECUTE ON  [Coupon].[CouponDetailsGet2] TO [SubsUser]
GO
