SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[SearchCoupon]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [Coupon].[SearchCoupon]
** DATE WRITTEN   : 11th July 2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): 0 in case of success.
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	23 July 2013	Navdeep_Singh					Incorporated Review Comments from Manju

*/

CREATE PROCEDURE [Coupon].[SearchCoupon]
(
@CouponCode		NVARCHAR(25)	= NULL,
@CustomerID		BIGINT			= NULL
)
AS

BEGIN

SET NOCOUNT ON

DECLARE @ErrorMessage    NVARCHAR(2048)

IF (@CouponCode IS NULL AND @CustomerID IS NULL)
	BEGIN 
		SET @ErrorMessage = 'Either, CustomerID or CouponCode should be supplied'
			
		RAISERROR (
		'SP - [Coupon].[SearchCoupon] Error = %s',
		16,
		1,
		@ErrorMessage
		)
	END


IF (@CouponCode IS NOT NULL)
	BEGIN
	
	;WITH CampAttrUn
	AS
	(SELECT PVT.CampaignId
			,PVT.[1] SubscriptionPlanId
			,CAST(SUBSTRING(PVT.[2],6,2)+'/'+SUBSTRING(PVT.[2],9,2)+'/'+SUBSTRING(PVT.[2],1,4) AS VARCHAR(10)) EffectiveStartDateTime
			,CAST(SUBSTRING(PVT.[3],6,2)+'/'+SUBSTRING(PVT.[3],9,2)+'/'+SUBSTRING(PVT.[3],1,4) AS VARCHAR(10)) EffectiveEndDateTime
			,PVT.[4] MaxRedemption
			,PVT.[5] LapsePeriod
			,PVT.[6] CouponsGeneratedCount 
			,CouponID
		FROM
			(
			SELECT C.CampaignId,
					AttributeValue,
					AttributeID	
					,CouponID		
			FROM Coupon.Coupon CP (NOLOCK)
			JOIN Coupon.Campaign C  (NOLOCK)
			ON CouponCode=@CouponCode AND C.CampaignID=CP.CampaignID 	
			JOIN Coupon.CampaignAttributes CA  (NOLOCK)
				ON CA.CampaignID = C.CampaignID	
			) TempA
			PIVOT (
				 MIN(Attributevalue)
				 FOR AttributeID in ([1],[2],[3],[4],[5],[6])
			) PVT
		)			
		SELECT	C.CouponID													
				,C.CouponCode
				,Cmp.CampaignID
				,Cmp.CampaignCode
				,CONVERT(VARCHAR(10),CampAttrUn.EffectiveStartDateTime,101)		AS ValidFrom
				,CONVERT(VARCHAR(10),CampAttrUn.EffectiveEndDateTime,101)		AS ValidTo					
				,Cmp.Amount														AS AmountOff
				,CASE WHEN C.RedeemCount <> 0 
					THEN 'Yes' 
					ELSE 'No' 
				END																AS IsRedeemed
				,Ccm.CustomerID													AS CustomerIDIsLinked
				,Cr.CustomerID													AS CustomerIDRedeemed		
				,CONVERT(VARCHAR(10),Cr.UTCCreatedDateTime,101)					AS RedemptionDate					
				,CampAttrUn.SubscriptionPlanID		
				,Cmp.CampaignTypeID
				,CampAttrUn.LapsePeriod
				,Cmp.DescriptionShort											AS InternalDescription
				,Cmp.DescriptionLong											AS ExternalDescription
				,CampAttrUn.MaxRedemption
				,C.RedeemCount													AS CouponRedeemedHowManyTimes
			FROM  CampAttrUn WITH (NOLOCK)
				INNER JOIN Coupon.Coupon C (NOLOCK)
					ON CampAttrUn.CouponID = C.CouponID
				INNER JOIN Coupon.Campaign Cmp (NOLOCK)
					ON Cmp.CampaignID = CampAttrUn.CampaignID
				LEFT OUTER JOIN Coupon.CouponCustomerMap Ccm (NOLOCK)
					ON Ccm.CouponID = C.CouponID
				LEFT OUTER JOIN Coupon.CouponRedemption Cr (NOLOCK)
					ON Cr.CouponCode = C.CouponCode
			ORDER BY RedemptionDate DESC
			
	END
ELSE -- Search to go ahead with CustomerID
	BEGIN
	
	;With CRTemp
	AS
	(SELECT CampaignID,C.CouponCode,CustomerID,UTCCreatedDateTime FROM Coupon.CouponRedemption CR (NOLOCK)
		JOIN Coupon.Coupon C (NOLOCK)
		ON C.CouponCode=CR.CouponCode 
		AND CustomerID=@CustomerID
	 )
	 , CMTemp
	 AS
	 (
	 SELECT CampaignID,CM.CouponID,CustomerID FROM Coupon.CouponCustomerMap CM (NOLOCK)
		JOIN Coupon.Coupon C (NOLOCK)
		ON C.CouponID=CM.CouponID 
		WHERE CustomerID=@CustomerID
	)
	, CampAttr
		AS
		(SELECT PVT.CampaignId
				,PVT.[1] SubscriptionPlanId
				,CAST(SUBSTRING(PVT.[2],6,2)+'/'+SUBSTRING(PVT.[2],9,2)+'/'+SUBSTRING(PVT.[2],1,4) AS VARCHAR(10)) EffectiveStartDateTime
				,CAST(SUBSTRING(PVT.[3],6,2)+'/'+SUBSTRING(PVT.[3],9,2)+'/'+SUBSTRING(PVT.[3],1,4) AS VARCHAR(10)) EffectiveEndDateTime
				,PVT.[4] MaxRedemption
				,PVT.[5] LapsePeriod
				,PVT.[6] CouponsGeneratedCount
			FROM
				(
				SELECT C.CampaignId,
						AttributeValue,
						AttributeID			
				FROM  (SELECT CampaignID FROM CRTemp WITH (NOLOCK)
						UNION
						SELECT CampaignID FROM CMTemp WITH (NOLOCK)) CT
				JOIN Coupon.Campaign C (NOLOCK)
					ON C.CampaignID=CT.CampaignID	
			   JOIN Coupon.CampaignAttributes CA (NOLOCK)
					ON CA.CampaignID = C.CampaignID
				) TempA
				PIVOT (
					 MIN(Attributevalue)
					 FOR AttributeID in ([1],[2],[3],[4],[5],[6])
				) PVT
		)
		SELECT	C.CouponID													
				,C.CouponCode
				,Cmp.CampaignID
				,Cmp.CampaignCode
				,CONVERT(VARCHAR(10),CampAttr.EffectiveStartDateTime,101)		AS ValidFrom
				,CONVERT(VARCHAR(10),CampAttr.EffectiveEndDateTime,101)			AS ValidTo					
				,Cmp.Amount														AS AmountOff
				,CASE WHEN C.RedeemCount <> 0 
					THEN 'Yes' 
					ELSE 'No' 
				END																AS IsRedeemed
				,Ccm.CustomerID													AS CustomerIDIsLinked
				,Cr.CustomerID													AS CustomerIDRedeemed		
				,CONVERT(VARCHAR(10),Cr.UTCCreatedDateTime,101)					AS RedemptionDate					
				,CampAttr.SubscriptionPlanID		
				,Cmp.CampaignTypeID
				,CampAttr.LapsePeriod
				,Cmp.DescriptionShort											AS InternalDescription
				,Cmp.DescriptionLong											AS ExternalDescription
				,CampAttr.MaxRedemption
				,C.RedeemCount													AS CouponRedeemedHowManyTimes
				FROM  CampAttr  WITH (NOLOCK)
				INNER JOIN Coupon.Campaign Cmp (NOLOCK)
					ON Cmp.CampaignID = CampAttr.CampaignID
				INNER JOIN Coupon.Coupon C (NOLOCK)
					ON Cmp.CampaignID = C.CampaignID
				LEFT OUTER JOIN CMTemp Ccm (NOLOCK)
					ON Ccm.CouponID = C.CouponID
				LEFT OUTER JOIN CRTemp Cr (NOLOCK)
					ON Cr.CouponCode = C.CouponCode
		WHERE ( Ccm.CustomerID = @CustomerID OR  Cr.CustomerID = @CustomerID )
		ORDER BY RedemptionDate DESC	
	END
END
GO
GRANT EXECUTE ON  [Coupon].[SearchCoupon] TO [SubsUser]
GO
