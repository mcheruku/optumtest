SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignDetailsGetAll]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [TescoSubscription].[CampaignDetailsGetAll]
** DATE WRITTEN   : 06/04/2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): DATA OF TABLE [Coupon].[CampaignDetailsGetAll] WHICH IS ACTIVE
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	20 Jun 2013		Navdeep_Singh	131642			Modified Decimal Conversion parameters - 'Cost Associated'
	02 Jul 2013		Navdeep_Singh	NA				Development: Changed to incorporate req. for View Coupon Story
	04 Jul 2013		Navdeep_Singh	NA				Development: Changed to include CampaignTypeID and ExternalDescription for View Coupon Story
*/

CREATE PROCEDURE [Coupon].[CampaignDetailsGetAll] 
(
@CampaignID BIGINT = NULL
)
AS

BEGIN
SET NOCOUNT ON

DECLARE @ErrorMessage    NVARCHAR(2048)

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
					,TempCampaignAttributes.SubscriptionPlanId 
					,ISNULL(TempCampaignDetails.DescriptionShort,'') AS [InternalDescription]
					,ISNULL(TempCampaignDetails.DescriptionLong,'') AS [ExternalDescription]			
					,TempCampaignAttributes.[CouponsGeneratedCount]
					,ISNULL(TempCouponDetails.[Redemptions],0) AS [Redemptions]
					,ISNULL(TempCampaignDetails.[AmountOff],0)	AS [AmountOff]		
					,ISNULL(CONVERT(DECIMAL(38,2),(TempCouponDetails.[Redemptions] * [AmountOff])),0) AS [CostAssociated]
					,TempCampaignDetails.IsActive
					,TempCampaignAttributes.EffectiveStartDateTime
					,TempCampaignAttributes.EffectiveEndDateTime 
					,TempCampaignAttributes.MaxRedemption
					,TempCampaignAttributes.LapsePeriod	
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
				 FROM Coupon.Campaign C (NOLOCK)
				INNER JOIN Coupon.CampaignTypeMaster CTM (NOLOCK)
					On C.CampaignTypeID = CTM.CampaignTypeID		
				)TempCampaignDetails
				LEFT OUTER JOIN (SELECT	Cpn.CampaignID
										,Sum (Cpn.RedeemCount) AS [Redemptions]								
								FROM Coupon.Coupon Cpn						
								GROUP BY CampaignID
								)TempCouponDetails
				ON TempCampaignDetails.CampaignID = TempCouponDetails.CampaignID
				LEFT OUTER JOIN (
								SELECT PVT.CampaignId
										,PVT.[1] SubscriptionPlanId
										,PVT.[2] EffectiveStartDateTime
										,PVT.[3] EffectiveEndDateTime
										,PVT.[4] MaxRedemption
										,PVT.[5] LapsePeriod
										,PVT.[6] CouponsGeneratedCount 
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
										 FOR AttributeID in ([1],[2],[3],[4],[5],[6])
									) PVT
								)TempCampaignAttributes
									ON TempCampaignAttributes.CampaignID=TempCampaignDetails.CampaignID		
						WHERE @CampaignID = 0 OR TempCampaignDetails.CampaignID = @CampaignID
						ORDER BY TempCampaignDetails.UTCCreatedDateTime DESC,TempCampaignDetails.CampaignID DESC
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
GRANT EXECUTE ON  [Coupon].[CampaignDetailsGetAll] TO [SubsUser]
GO
