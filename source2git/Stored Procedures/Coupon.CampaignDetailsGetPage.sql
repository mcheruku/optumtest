SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignDetailsGetPage]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [TescoSubscription].[CampaignDetailsGetPage]
** DATE WRITTEN   : 12 July 2013
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): DATA OF TABLE [Coupon].[CampaignDetailsGetPage] WHICH IS ACTIVE
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
*/

CREATE PROCEDURE [Coupon].[CampaignDetailsGetPage] 
(
@Start		INT
,@PageSize	INT
)
AS

BEGIN
SET NOCOUNT ON

DECLARE @ErrorMessage    NVARCHAR(2048)

BEGIN TRY


		;WITH TempCampaignAttributes
		AS
		(
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
		)
		
		SELECT * FROM(			
		SELECT ROW_NUMBER() OVER (ORDER BY TempT.UTCCreatedDateTime DESC
										,TempT.CampaignID DESC)
						AS RowNumber
				, TempT.*
			FROM(
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
					ON C.CampaignTypeID = CTM.CampaignTypeID		
				)TempCampaignDetails
				LEFT OUTER JOIN (SELECT	Cpn.CampaignID
										,Sum (Cpn.RedeemCount) AS [Redemptions]								
								FROM Coupon.Coupon Cpn						
								GROUP BY CampaignID
								)TempCouponDetails
				ON TempCampaignDetails.CampaignID = TempCouponDetails.CampaignID
				INNER JOIN TempCampaignAttributes --Only those records will come for which campaign attributes exists
					ON TempCampaignAttributes.CampaignID=TempCampaignDetails.CampaignID				
				)TempT
			)Temp
			WHERE RowNumber BETWEEN (@Start+1) AND (@Start+@PageSize)
			ORDER BY RowNumber
			
			
		END TRY

		BEGIN CATCH
				SET @ErrorMessage = ERROR_MESSAGE()	
		
				RAISERROR (
				'SP - [Coupon].[CampaignDetailsGetPage] Error = (%s)',
				16,
				1,
				@ErrorMessage
				)
		END CATCH;
END

GO
GRANT EXECUTE ON  [Coupon].[CampaignDetailsGetPage] TO [SubsUser]
GO
