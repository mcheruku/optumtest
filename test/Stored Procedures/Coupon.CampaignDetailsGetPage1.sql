SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Coupon].[CampaignDetailsGetPage1] 
(
	 @StartDate DATETIME
	,@EndDate   DATETIME
	,@CampaignCode NVARCHAR(25)
	,@CampaignDiscription NVARCHAR(200)
	,@SubscriptionPlan NVARCHAR(50)
	,@Filtervalue INT
	,@PageOffset INT
	,@PageSize INT
)
AS
/*

	Author:			Deepmala
	Date created:	22/02/2013
	Purpose:		Returns All Coupon Details	
	Behaviour:		How does this procedure actually work
	Usage:			
	Called by:		BOA
	
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
   
*/
BEGIN
SET NOCOUNT ON
	

DECLARE 
    @CurrentDate DATETIME 
   ,@ErrorMessage  NVARCHAR(2048)
   ,@PlanData VARCHAR(100)
   ,@PageStart INT
   ,@PageEnd INT

SELECT @CurrentDate  = CONVERT(VARCHAR(10),GETDATE(),101)
      ,@PageStart = (@PageSize * (@PageOffset - 1)) + 1
      ,@PageEnd = (@PageOffset * @PageSize)

BEGIN TRY
	CREATE TABLE #TmpSearchData(CampaignId BIGINT,EffectiveStartDateTime DATETIME,EffectiveEndDateTime DATETIME,
				CouponsGeneratedCount VARCHAR(100),UTCCreatedDateTime DATETIME,CampaignCode VARCHAR(50),
				InternalDescription VARCHAR(300), CampaignTypeName VARCHAR(100), UsageName VARCHAR(100),IsActive BIT,
				Redemptions INT, AmountDiscount NUMERIC(10,2),PercentageDiscount INT ,CCDiscount INT,CostAssociated VARCHAR(100))
	
	CREATE TABLE #FinalData(CampaignId BIGINT,EffectiveStartDateTime DATETIME,EffectiveEndDateTime DATETIME,
				CouponsGeneratedCount VARCHAR(100),UTCCreatedDateTime DATETIME,CampaignCode VARCHAR(50),
				InternalDescription VARCHAR(300), CampaignTypeName VARCHAR(100), UsageName VARCHAR(100),IsActive BIT,
				Redemptions INT, AmountDiscount NUMERIC(10,2),PercentageDiscount INT,CCDiscount INT,
				CostAssociated VARCHAR(100), RNo INT)
			
	CREATE TABLE #CC (CampaignId BIGINT)--Hold the campaignids after filter on CampaignCode or CouponCode 
	CREATE TABLE #PlanTable (PlanId NVARCHAR(25))

		IF(LEN(@SubscriptionPlan)>0)
		BEGIN
			INSERT INTO #PlanTable ([PlanId]) SELECT Item FROM dbo.ConvertListToTable(@SubscriptionPlan,',')
		END

		IF (len(IsNull(@CampaignCode,''))>5)
		BEGIN
			INSERT INTO #CC SELECT CC.CampaignId FROM coupon.campaign CC					
			JOIN Coupon.Coupon CO ON CO.CampaignId = CC.CampaignId WHERE (CouponCode like '%'+ @CampaignCode + '%') 					
		END
		ELSE 

		BEGIN
			INSERT INTO #CC SELECT CC.CampaignId FROM coupon.campaign CC								
			WHERE (CampaignCode like '%'+ @CampaignCode + '%' OR @CampaignCode IS NULL) 					
		END

		;WITH TempCampaignAttributes AS
		( SELECT PVT.CampaignId,CONVERT(DATETIME,PVT.[2],101) EffectiveStartDateTime
				,CONVERT(DATETIME,PVT.[3],101) EffectiveEndDateTime	,CONVERT(INT,PVT.[6]) CouponsGeneratedCount
				,PVT.UTCCreatedDateTime,PVT.CampaignCode,PVT.InternalDescription,PVT.CampaignTypeName,PVT.UsageName,
				PVT.IsActive
			FROM
				(
					Select CC.CampaignId,CC.UTCCreatedDateTime ,CampaignCode,CC.DescriptionShort as InternalDescription,CampaignTypeName,
					UsageName,CC.IsActive, AttributeValue,AttributeId			
					From coupon.campaign CC					
					INNER JOIN Coupon.CampaignTypeMaster CT ON CC.CampaignTypeId = CT.CampaignTypeId
					INNER JOIN Coupon.CouponUsageType CU ON CC.UsageTypeId = CU.UsageTypeId
					INNER JOIN Coupon.CampaignAttributes CA ON ca.CampaignID = Cc.CampaignID	
					INNER JOIN #CC ON #CC.CampaignId = CC.CampaignId 				
					WHERE 						
					((CC.DescriptionShort like '%'+ @CampaignDiscription + '%' OR @CampaignDiscription IS NULL) 
					OR (CC.DescriptionLong like '%'+ @CampaignDiscription + '%' OR @CampaignDiscription IS NULL))				
				) A
					PIVOT (MIN(Attributevalue) FOR AttributeID in ([2],[3],[6])
				) PVT 			
		)

		Select * INTO #Mydata From TempCampaignAttributes
		
		--select * from #Mydata
		SELECT	CPN.CampaignID ,SUM (Cpn.RedeemCount) AS [Redemptions] INTO #RemData
        FROM Coupon.Coupon Cpn		
		JOIN #Mydata ON #Mydata.CampaignId = CPN.CampaignID				
        GROUP BY CPN.CampaignID 
		
		--Discounts calculation (Value column in UI)
		SELECT [1] AS AmountDiscount,[2] AS PercentageDiscount,[3]AS CCDiscount,CampaignId INTO #DiscountsData
		From 
			(
				SELECT DiscountTypeId,DiscountValue,CD.CampaignId FROM Coupon.CampaignDiscountType CD
				JOIN #Mydata ON #Mydata.CampaignId = CD.CampaignID	
			)A
			PIVOT(MIN(DiscountValue) FOR DiscountTypeId in ([1],[2],[3])
		)B
		--select * from #DiscountsData

		--Cost Associated  : Start
		SELECT CO.campaignid,CAST(SUM(PaymentAmount) AS NUMERIC(10,2)) AS CostAssociated INTO #TmpAmtData
		FROM tescosubscription.customerpaymenthistory CPH
		JOIN tescosubscription.customerpaymenthistoryresponse CPHR
        ON CPH.CustomerPaymentHistoryId = CPHR.CustomerPaymentHistoryId		
		JOIN tescosubscription.customerpayment CP 
        ON CP.CustomerPaymentId = CPH.CustomerPaymentId
		JOIN coupon.coupon CO 
        ON CO.CouponCode = CP.PaymentToken
		JOIN #Mydata 
        ON #Mydata.CampaignId = CO.CampaignID	
		WHERE paymentmodeid = 2
        AND PaymentStatusId = 1
		GROUP BY CO.campaignid

		SELECT CO.campaignid,COUNT(DISTINCT CustomerSubscriptionid) AS CSCount INTO #TmpCCData 
		FROM tescosubscription.customerpaymenthistory CPH
		JOIN tescosubscription.customerpaymenthistoryresponse CPHR
        ON CPH.CustomerPaymentHistoryId = CPHR.CustomerPaymentHistoryId
		JOIN tescosubscription.customerpayment CP 
        ON CP.CustomerPaymentId = CPH.CustomerPaymentId
		JOIN coupon.coupon CO 
        ON CO.CouponCode = CP.PaymentToken
		JOIN coupon.campaignDIscountType CDT 
        ON CDT.CampaignId = CO.CampaignId
		JOIN #Mydata 
        ON #Mydata.CampaignId = CO.CampaignID	
		WHERE paymentmodeid = 2 AND PaymentStatusId = 1 AND CDT.DiscountTypeId = 3
		GROUP BY CO.campaignid,CustomerSubscriptionid

		SELECT TC.CampaignId,CAST(SUM(CSCount * DiscountValue) AS INT) AS CCPointsDiscount 
		INTO #TmpFInalCcData FROM #TmpCCData TC 
		JOIN coupon.campaignDIscountType CD
        ON CD.CampaignId = TC.CampaignId 
		WHERE discounttypeid = 3
		GROUP BY TC.CampaignId
		
		SELECT #TmpAmtData.CampaignId,
			(CASE WHEN ISNULL(CostAssociated,0)>0 then ('œ' + CONVERT(VARCHAR,CostAssociated)) ELSE '' END) + 
			(CASE WHEN (ISNULL(CostAssociated,0)>0 and isnull(CCPointsDiscount,0)>0) THEN ', ' ELSE '' END) + 
			(CASE WHEN ISNULL(CCPointsDiscount,0)>0 THEN (CONVERT(VARCHAR,CCPointsDiscount) + ' CC POINTS') ELSE '' END 
			
			)
			AS CostAssociated			
		INTO #TmpFinalCostData
		FROM #TmpAmtData
		LEFT join #TmpFInalCcData on #TmpAmtData.Campaignid = #TmpFInalCcData.campaignid
		--Calculation end
		
		;WITH CampaignSearch AS (SELECT MyData.CampaignId,MyData.EffectiveStartDateTime,MyData.EffectiveEndDateTime				
				,MyData.CouponsGeneratedCount,MyData.UTCCreatedDateTime,MyData.CampaignCode,MyData.InternalDescription,
				MyData.CampaignTypeName,MyData.UsageName,MyData.IsActive
				,#RemData.Redemptions,AmountDiscount,PercentageDiscount,CCDiscount,#TmpFinalCostData.CostAssociated				
				FROM  #Mydata MyData
				INNER JOIN #RemData ON #RemData.CampaignId = Mydata.CampaignId
				INNER JOIN #DiscountsData ON #DiscountsData.CampaignId = Mydata.CampaignId
				LEFT OUTER JOIN #TmpFinalCostData ON #TmpFinalCostData.CampaignId = Mydata.CampaignId
					)
			
		SELECT * INTO #Mydata1 FROM CampaignSearch 
		--select * from #Mydata1
		IF ((Select count(*) from #PlanTable)>0)
		BEGIN	
			--Filter unique campaignids for plan search to avoid multiple records for one campaign with multiple plans
			SELECT distinct TC.CampaignId INTO #CampaignsPlan FROM #Mydata1 TC
			JOIN Coupon.CampaignPlanDetails CP ON CP.CampaignId = TC.CampaignId
			JOIN #PlanTable P ON P.PlanId = CP.SubscriptionPlanId
			
			INSERT INTO #TmpSearchData (CampaignId,EffectiveStartDateTime,EffectiveEndDateTime,
				CouponsGeneratedCount,UTCCreatedDateTime,CampaignCode,
				InternalDescription, CampaignTypeName ,UsageName,IsActive,
				Redemptions, AmountDiscount,PercentageDiscount,CCDiscount,CostAssociated)
			SELECT TC.CampaignId,EffectiveStartDateTime,EffectiveEndDateTime,CouponsGeneratedCount,
				TC.UTCCreatedDateTime,CampaignCode,InternalDescription,CampaignTypeName,UsageName,IsActive,Redemptions,
				AmountDiscount,PercentageDiscount,CCDiscount,CostAssociated
			FROM #Mydata1 TC
			JOIN #CampaignsPlan CP ON CP.CampaignId = TC.CampaignId
			
		END

		ELSE

		BEGIN
			INSERT INTO #TmpSearchData SELECT * FROM #Mydata1
		END		
		
		If ISNULL(@Filtervalue,0) = 1 --Active Campaign
		Begin
			;WITH CampaignSearch AS (SELECT *,ROW_NUMBER() OVER(ORDER BY UTCCreatedDateTime DESC
				,#TmpSearchData.CampaignID DESC) AS RowNumber FROM #TmpSearchData
				WHERE CONVERT(DATETIME,EffectiveStartDateTime,101) <= CONVERT(VARCHAR,GETDATE(),101) and
				CONVERT(DATETIME,EffectiveEndDateTime,101) >= CONVERT(VARCHAR,GETDATE(),101) and IsActive = 1
				AND (CONVERT(DATETIME,EffectiveStartDateTime,101) <= CONVERT(DATETIME,@EndDate,101) OR @EndDate IS NULL)
				AND (CONVERT(DATETIME,EffectiveEndDateTime,101) >= CONVERT(DATETIME,@StartDate,101) OR @StartDate IS NULL)
			)

			INSERT INTO #FinalData SELECT * FROM CampaignSearch 
		End
		Else If ISNULL(@Filtervalue,0) = 2 --Future Campaign
		Begin
			;WITH CampaignSearch AS (SELECT *,ROW_NUMBER() OVER(ORDER BY UTCCreatedDateTime DESC
				,#TmpSearchData.CampaignID DESC) AS RowNumber FROM #TmpSearchData
				WHERE CONVERT(DATETIME,EffectiveStartDateTime,101) > CONVERT(VARCHAR,GETDATE(),101) and IsActive = 1
				AND (CONVERT(DATETIME,EffectiveStartDateTime,101) <= CONVERT(DATETIME,@EndDate,101) OR @EndDate IS NULL)
				AND (CONVERT(DATETIME,EffectiveEndDateTime,101) >= CONVERT(DATETIME,@StartDate,101) OR @StartDate IS NULL)
			)
						
			INSERT INTO #FinalData SELECT * FROM CampaignSearch 
		End
		Else If ISNULL(@Filtervalue,0) = 3  --Past Campaign
		Begin
			;WITH CampaignSearch AS (SELECT *,ROW_NUMBER() OVER(ORDER BY UTCCreatedDateTime DESC
				,#TmpSearchData.CampaignID DESC) AS RowNumber
				 FROM #TmpSearchData
				Where CONVERT(DATETIME,EffectiveEndDateTime,101) < CONVERT(VARCHAR,GETDATE(),101) --and IsActive = 0
				AND (CONVERT(DATETIME,EffectiveStartDateTime,101) <= CONVERT(DATETIME,@EndDate,101) OR @EndDate IS NULL)
				AND (CONVERT(DATETIME,EffectiveEndDateTime,101) >= CONVERT(DATETIME,@StartDate,101) OR @StartDate IS NULL)
			)
						
			INSERT INTO #FinalData SELECT * FROM CampaignSearch 
		End
		Else If ISNULL(@Filtervalue,0) = 4 --Stopped Campaign
		Begin
			;WITH CampaignSearch AS (SELECT *,ROW_NUMBER() OVER(ORDER BY UTCCreatedDateTime DESC
				,#TmpSearchData.CampaignID DESC) AS RowNumber FROM #TmpSearchData Where IsActive = 0
				AND (CONVERT(DATETIME,EffectiveStartDateTime,101) <= CONVERT(DATETIME,@EndDate,101) OR @EndDate IS NULL) 
				AND (CONVERT(DATETIME,EffectiveEndDateTime,101) >= CONVERT(DATETIME,@StartDate,101)OR @StartDate IS NULL)
				)		
			
			INSERT INTO #FinalData SELECT * FROM CampaignSearch 
		END
		ELSE
		BEGIN	
			;WITH CampaignSearch AS (SELECT *,ROW_NUMBER() OVER(ORDER BY UTCCreatedDateTime DESC
				,#TmpSearchData.CampaignID DESC) AS RowNumber FROM #TmpSearchData
				WHERE (CONVERT(DATETIME,EffectiveStartDateTime,101) <= CONVERT(DATETIME,@EndDate,101) OR @EndDate IS NULL) 
				AND (CONVERT(DATETIME,EffectiveEndDateTime,101) >= CONVERT(DATETIME,@StartDate,101)OR @StartDate IS NULL)
			)
			
			INSERT INTO #FinalData SELECT * FROM CampaignSearch 
		END

		SELECT * FROM #FinalData WHERE RNo BETWEEN @PageStart and @PageEnd
		SELECT COUNT(CampaignId) as TotalRecords FROM #FinalData
END TRY

BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE()	

		RAISERROR (
		'SP - [Coupon].[CampaignDetailsGetPage1] Error = (%s)',
		16,
		1,
		@ErrorMessage
		)
END CATCH;

END
 

GO
GRANT EXECUTE ON  [Coupon].[CampaignDetailsGetPage1] TO [SubsUser]
GO
