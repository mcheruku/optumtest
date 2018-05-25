SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Coupon].[CampaignDetailsGetAll1] 
(
@CampaignID NVARCHAR(300) = NULL
)
AS

/*
	Author:		Robin
	Created:	17/March/2014
	Purpose:	Get Campaign Details
    Called By:  Coupon Service

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 

*/

BEGIN
SET NOCOUNT ON

DECLARE
@ErrorMessage    NVARCHAR(2048)
,@Delimiter    NVARCHAR(1)
,@String       NVARCHAR(25)

SET @Delimiter = ','

DECLARE 
@CouponTable  TABLE (String NVARCHAR(44))


INSERT INTO @CouponTable ( [String] )
(SELECT Item FROM [dbo].[ConvertListToTable] (@CampaignID,@Delimiter))


BEGIN TRY
			IF (@CampaignID IS NULL)
			BEGIN
				SET @CampaignID = 0
			END
			
			SELECT 	TempCampaignDetails.CampaignID
					,TempCampaignDetails.UTCCreatedDateTime
					,TempCampaignDetails.CampaignCode
					,TempCampaignDetails.CampaignTypeName
					,TempCampaignDetails.CampaignTypeID
					,ISNULL(TempCampaignDetails.DescriptionShort,'') AS [InternalDescription]
					,ISNULL(TempCampaignDetails.DescriptionLong,'') AS [ExternalDescription]			
					,TempCampaignAttributes.[CouponsGeneratedCount]
					,ISNULL(TempCouponDetails.[Redemptions],0) AS [Redemptions]
					,ISNULL(CONVERT(DECIMAL(38,2),(TempCouponDetails.[Redemptions] * [AmountOff])),0) AS [CostAssociated]
					,TempCampaignDetails.IsActive
					,TempCampaignAttributes.EffectiveStartDateTime
					,TempCampaignAttributes.EffectiveEndDateTime 
					,TempCampaignAttributes.MaxRedemption
					,TempCampaignAttributes.LapsePeriod	
                    ,TempCampaignAttributes.CouponsGeneratedCount 
                    ,TempCampaignAttributes.IsClubCardBoost
                    ,TempCampaignAttributes.ClubCardVoucherValue
                    ,TempCampaignDetails.UsageTypeID
                    ,TempCampaignDetails.IsMutuallyExclusive
                    ,TempCampaignDetails.UsageName
			FROM
				(
				SELECT	C.CampaignID
						,C.UTCCreatedDateTime
						,CampaignCode
						,C.CampaignTypeID
						,CTM.CampaignTypeName
						,C.DescriptionShort
						,C.DescriptionLong
                        ,C.Amount AS [AmountOff]
						,C.IsActive	
                        ,C.UsageTypeID
                        ,C.IsMutuallyExclusive
                        ,UT.UsageName
                FROM Coupon.Campaign C (NOLOCK)
				INNER JOIN Coupon.CampaignTypeMaster CTM (NOLOCK)
					On C.CampaignTypeID = CTM.CampaignTypeID
                INNER JOIN Coupon.CouponUsageType UT
                    ON C.UsageTypeID = UT.UsageTypeID	
				)TempCampaignDetails
				LEFT OUTER JOIN (SELECT	Cpn.CampaignID
										,Sum (Cpn.RedeemCount) AS [Redemptions]								
								FROM Coupon.Coupon Cpn						
								GROUP BY CampaignID
								)TempCouponDetails
				ON TempCampaignDetails.CampaignID = TempCouponDetails.CampaignID
				LEFT OUTER JOIN (
								SELECT PVT.CampaignId
										,PVT.[2] EffectiveStartDateTime
										,PVT.[3] EffectiveEndDateTime
										,PVT.[4] MaxRedemption
										,PVT.[5] LapsePeriod
										,PVT.[6] CouponsGeneratedCount 
                                        ,PVT.[7] IsClubCardBoost
                                        ,PVT.[8] ClubCardVoucherValue
								FROM
									(
									SELECT C.CampaignId,
											AttributeValue,
											AttributeID			
									FROM Coupon.Campaign C 
									JOIN Coupon.CampaignAttributes CA
										ON ca.CampaignID = c.CampaignID			
									) A
									PIVOT (
										 MIN(Attributevalue)
										 FOR AttributeID in ([2],[3],[4],[5],[6],[7],[8])
									) PVT
								)TempCampaignAttributes
									ON TempCampaignAttributes.CampaignID=TempCampaignDetails.CampaignID		
						WHERE @CampaignID IN (Select String FROM @CouponTable) OR TempCampaignDetails.CampaignID IN (Select String FROM @CouponTable)
						ORDER BY TempCampaignDetails.UTCCreatedDateTime DESC,TempCampaignDetails.CampaignID DESC

SELECT DT.CampaignID
,DT.DiscountTypeID
,DT.DiscountValue 
,TM.DiscountName
FROM Coupon.CampaignDiscountType DT WITH (NOLOCK)
INNER JOIN Coupon.DiscountTypeMaster TM  WITH (NOLOCK)
ON DT.DiscountTypeID = TM.DiscountTypeID
WHERE DT.CampaignID IN (Select String FROM @CouponTable)

SELECT CampaignID
,SubscriptionPlanID
From Coupon.CampaignPlanDetails WITH(NOLOCK)
WHERE CampaignID IN (Select String FROM @CouponTable)


		END TRY

		BEGIN CATCH
				SET @ErrorMessage = ERROR_MESSAGE()	
			
				RAISERROR (
				'SP - [Coupon].[CampaignDetailsGetAll] Error = (%s)',
				16,
				1,
				@ErrorMessage
				)
		END CATCH;
END
 

GO
GRANT EXECUTE ON  [Coupon].[CampaignDetailsGetAll1] TO [SubsUser]
GO
