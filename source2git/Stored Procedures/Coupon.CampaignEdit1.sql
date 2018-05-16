SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Coupon].[CampaignEdit1] 
(
@XmlDocument XML
)
AS
/*   
 Author:   Saminathan
 Date created: 03 Apr 2014 
 Purpose:  Edits campaign Details
 Behaviour:  How does this procedure actually work  
 Usage:   Hourly/Often 
 Called by:  <SubscriptionService>  

  --Modifications History--  
 Changed On  Changed By  Defect Ref  Change Description  23/0
 
 */ 
BEGIN

	SET NOCOUNT ON

	DECLARE @ErrorMessage			NVARCHAR(2048)
	DECLARE @XmlDocumentHandle		INT
	DECLARE @CampaignID				BIGINT
	DECLARE @RecordsToAdd			BIGINT
	DECLARE @RecordsToDelete		BIGINT
	--DECLARE @RecordsToDeleteCoup	BIGINT
	DECLARE @ProcSection			VARCHAR(100)
	DECLARE @CampaignTypeID			INT
	Declare @UsageTypeNew			INT
    Declare @UsageType			    INT
	Declare @ClubCardBoostFlagNew	BIT
    Declare @ClubCardBoostFlag      BIT
	BEGIN TRY

	SET @ProcSection = 'Section Reading XML'
	-- Create an internal representation of the XML document.
	
	EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @XmlDocument


	SELECT CampaignID
			,CampaignCode
			,DescriptionShort
			,DescriptionLong
			,Amount
			,CASE WHEN IsActive like 'true'
				THEN 1
				ELSE
				0
			END AS IsActive
			,CampaignTypeId
			,IsMutuallyExclusive
			,UsageTypeID
			,GetUTCDate() AS UTCUpdatedDateTime
	INTO #TempCampaignDetails		
	FROM (			
		SELECT *
		FROM OPENXML (@XmlDocumentHandle, 'Campaign',2)
		WITH (	CampaignId		BIGINT 'CampaignId',				--check on this
				CampaignCode		NVARCHAR(25),
				DescriptionShort	NVARCHAR(200),
				DescriptionLong		NVARCHAR(300),
				Amount				MONEY,
				IsActive			VARCHAR(5),
				CampaignTypeId		int,
				IsMutuallyExclusive	BIT,
				UsageTypeId         TINYINT './UsageType/UsageTypeId'
			  )
		  )TempCampaign
		  
	IF EXISTS (SELECT 1 FROM #TempCampaignDetails WHERE LEN(CampaignCode) = 0)
	BEGIN
		SET @ErrorMessage = 'Invalid Coupon Code is being transmitted. Please check.'
		
		RAISERROR (
				'%s',
				16,
				1,
				@ErrorMessage
			)
	END
	
	SELECT @CampaignID = CampaignID,
			@CampaignTypeId = CampaignTypeId ,@UsageTypeNew=UsageTypeId
	FROM  #TempCampaignDetails
	
SELECT @UsageType=UsageTypeID from Coupon.Campaign where CampaignID=@CampaignID

	SELECT 
			*
	INTO #TempPlanID		
	FROM (			
		SELECT *
FROM   OPENXML(@XmlDocumentHandle, 'Campaign/SubscriptionPlanIds/string', 2)
       WITH ([PlanID] INT '.')
		  )TempPlans

SELECT 
			*
	INTO #TempDiscountTypes
	FROM (			
		SELECT *
		FROM OPENXML (@XmlDocumentHandle, 'Campaign/CampaignDiscounts/DiscountType',2)
		WITH (	DiscountTypeId			TINYINT,
				DiscountTypeValue       DECIMAL(6,2)				--check on this
			  )
		  )TempDiscounts
	

	SELECT CustomerID
			,CouponCode
			,Amount
			,RedeemCount
			,CASE WHEN IsActive like 'True'
				THEN 1
				ELSE
				0
			END AS IsActive
			,CampaignID
			,ActionFlag				
	INTO #TempLinkedCouponDetails
	FROM(
	SELECT *
	FROM OPENXML (@XmlDocumentHandle, 'Campaign/Coupons/Coupon',2)
	WITH (	CustomerID			BIGINT  'CustomerIds/string',
			CouponCode			NVARCHAR(25)   './CouponCode',
			Amount				MONEY,
			RedeemCount			INT,
			IsActive			VARCHAR(5),
			CampaignID			BIGINT,
			ActionFlag			VARCHAR(10)
		  )
		)TempCoupon
				  
	SELECT @RecordsToAdd = Count(*) FROM #TempLinkedCouponDetails WHERE IsActive = 1 --Getting records to insert
	
	SELECT @RecordsToDelete = Count(*) FROM #TempLinkedCouponDetails WHERE IsActive = 0 --Getting records to delete
	
	--SELECT @RecordsToDeleteCoup = Count(*) FROM #TempLinkedCouponDetails WHERE IsActive = 0 AND IsRedeemed = 0 -- Getting coupons to delete
	
	--Attribute Details 
	SELECT TempAttributes.*						
	INTO #TempCampaignAttributes
	FROM(
		SELECT *
		FROM OPENXML (@XmlDocumentHandle, 'Campaign/CampaignAttributes/CampaignAttribute',3)
		WITH (AttributeID		SMALLINT,
			  AttributeValue	NVARCHAR(50)
			  )where AttributeID > 0
		)TempAttributes
	ORDER BY TempAttributes.AttributeId 

select @ClubCardBoostFlagNew=AttributeValue from #TempCampaignAttributes where AttributeID=7
select @ClubCardBoostFlag=AttributeValue from Coupon.CampaignAttributes where CampaignID=@CampaignID and  AttributeID=7 

	EXEC sp_xml_removedocument @XmlDocumentHandle


	BEGIN TRANSACTION [Save_CampaignDetails] 

	IF (@CampaignTypeId >=1 AND @CampaignTypeId <=3) --Editing Campaign Details for all Coupon(s)
	BEGIN
		
			SET @ProcSection = 'Update Section in Coupon.Campaign:'
				
			UPDATE [TescoSubscription].[Coupon].[Campaign]
					SET	CampaignCode = TCD.CampaignCode
						,DescriptionShort = TCD.DescriptionShort
						,DescriptionLong = TCD.DescriptionLong
						,Amount = 0
						,IsActive = TCD.IsActive
						--,CampaignTypeId = TCD.CampaignTypeId --campaigntypeid should not be allowed to change
						,IsMutuallyExclusive=TCD.IsMutuallyExclusive
						,UsageTypeID	=TCD.UsageTypeId				
						,UTCUpdatedDateTime = GETUTCDATE()
					FROM #TempCampaignDetails TCD
					INNER JOIN [TescoSubscription].[Coupon].[Campaign] C
						ON C.CampaignID = TCD.CampaignID			
						
			IF(@@ROWCOUNT <> 1)
			BEGIN			
				SET @ErrorMessage = 'Failed in ' + @ProcSection
				
				RAISERROR (
							'%s',
							16,
							1,
							@ErrorMessage
							)
			END
			
		SET @ProcSection = 'Update Section Coupon.CampaignPlanDetails: '	
		
		DELETE FROM Coupon.CampaignPlanDetails 
		WHERE CampaignID=@CampaignID 
		AND SubscriptionPlanID NOT IN (SELECT [PlanID] FROM #TempPlanID)

		INSERT INTO Coupon.CampaignPlanDetails  
		 (CampaignID
		,SubscriptionPlanID 
		,UTCCreatedDateTime
		,UTCUpdatedDateTime
		)
		SELECT 
		@CampaignID
		,PlanID
		,getutcdate()
		,getutcdate()
		 FROM #TempPlanID WHERE PlanID  NOT IN 
		(SELECT SubscriptionPlanID FROM Coupon.CampaignPlanDetails 
		WHERE CampaignId = @CampaignID) 

		SET @ProcSection = 'Update Section Coupon.CampaignDiscountType: '	
		
		DELETE FROM Coupon.CampaignDiscountType
        WHERE CampaignID = @CampaignID 
        AND DiscountTypeID NOT IN (SELECT DiscountTypeID FROM #TempDiscountTypes WHERE CampaignID = @CampaignID)
		
		UPDATE Coupon.CampaignDiscountType 
		SET DiscountValue=DiscountTypeValue,
			UTCUpdatedDateTime=GETUTCDATE()
		FROM #TempDiscountTypes TD INNER JOIN
		Coupon.CampaignDiscountType CD ON
		CD.CampaignID=@CampaignID
		AND CD.DiscountTypeID=TD.DiscountTypeId

		INSERT INTO [Coupon].[CampaignDiscountType] (
            CampaignID,
            DiscountTypeID,
            DiscountValue,
			UTCCreatedDateTime,
			UTCUpdatedDateTime
            )
            SELECT 
            @CampaignID,
            DiscountTypeID,
            DiscountTypeValue,
			getutcdate(),
			getutcdate()
            FROM #TempDiscountTypes 
            WHERE DiscountTypeID NOT IN 
			(SELECT DiscountTypeID FROM [Coupon].[CampaignDiscountType] WHERE CampaignID = @CampaignID)

			SET @ProcSection = 'Update Section Coupon.CampaignAttributes: '			
			
			UPDATE [TescoSubscription].[Coupon].[CampaignAttributes]
				SET	AttributeValue = TCA.AttributeValue,
					UTCUpdatedDateTime = GETUTCDATE()
				FROM #TempCampaignAttributes TCA
				INNER JOIN Coupon.CampaignAttributes CA
					   ON  CA.CampaignID = @CampaignID
					   AND CA.AttributeId = TCA.AttributeId	

			IF NOT (@UsageType = @UsageTypeNew)
				BEGIN
				 IF (@UsageTypeNew=1)
					BEGIN
					INSERT INTO [TescoSubscription].[Coupon].[CampaignAttributes]
									   ([CampaignID]
									   ,[AttributeID]
									   ,[AttributeValue]
									   ,[UTCCreatedDateTime]
									   ,[UTCUpdatedDateTime])
								SELECT @CampaignID
										,AttributeID
										,AttributeValue
										,GetUTCDate() AS [UTCCreatedeDateTime]
										,GetUTCDate() AS [UTCUpdatedDateTime]
								FROM #TempCampaignAttributes WHERE AttributeID=5
					END
				   ELSE IF(@UsageTypeNew=2)
						BEGIN
							DELETE FROM [TescoSubscription].[Coupon].[CampaignAttributes]
							WHERE CampaignID=@CampaignID and AttributeID=5			

						END

			END			

			IF NOT (@ClubCardBoostFlag = @ClubCardBoostFlagNew)
				BEGIN
				 IF (@ClubCardBoostFlagNew=1)
					BEGIN
					INSERT INTO [TescoSubscription].[Coupon].[CampaignAttributes]
									   ([CampaignID]
									   ,[AttributeID]
									   ,[AttributeValue]
									   ,[UTCCreatedDateTime]
									   ,[UTCUpdatedDateTime])
								SELECT @CampaignId
										,AttributeID
										,AttributeValue
										,GetUTCDate() AS [UTCCreatedeDateTime]
										,GetUTCDate() AS [UTCUpdatedDateTime]
								FROM #TempCampaignAttributes WHERE AttributeID=8
					END
				 ELSE IF(@ClubCardBoostFlagNew=0)
						BEGIN
							DELETE FROM [TescoSubscription].[Coupon].[CampaignAttributes]
							WHERE CampaignID=@CampaignID and AttributeID=8			

						END

			END		

		
				
			IF (@RecordsToAdd <> 0)
			BEGIN
			
			/*ADD SECTION BEGINS */
			
				SET @ProcSection = 'Add Section in Coupon.Coupon: '
					
					
					INSERT INTO [TescoSubscription].[Coupon].[Coupon]
						   ([CouponCode]
						   ,[Amount]
						   ,[RedeemCount]
						   ,[IsActive]
						   ,[UTCCreatedeDateTime]
						   ,[UTCUpdatedDateTime]
						   ,[CampaignID])
					SELECT CouponCode
							,0
							,RedeemCount
							,IsActive					
							,GetUTCDate() AS [UTCCreatedeDateTime]
							,GetUTCDate() AS [UTCUpdatedDateTime]
							,@CampaignID
					FROM #TempLinkedCouponDetails TCD
					WHERE Tcd.IsActive = 1
						
					IF(@@ROWCOUNT <> @RecordsToAdd)
					BEGIN			
						SET @ErrorMessage = 'Failed in ' + @ProcSection
						RAISERROR (
									'%s',
									16,
									1,
									@ErrorMessage
									)
					END		
				
					SET @ProcSection = 'Add Section Coupon.CouponCustomerMap: '
					
					INSERT INTO [TescoSubscription].[Coupon].[CouponCustomerMap]
					   ([CouponID]
					   ,[CustomerID]
					   ,[UTCCreatedDateTime]
					   ,[UTCUpdatedDateTime])
					Select Cpn.CouponID
							,Tcd.CustomerID
							,GetUTCDate() AS [UTCCreatedDateTime]
							,GetUTCDate() AS [UTCUpdatedDateTime]
					FROM #TempLinkedCouponDetails Tcd
					INNER JOIN Coupon.Coupon Cpn
						ON LOWER(Tcd.CouponCode) = LOWER(Cpn.CouponCode)
						AND Tcd.IsActive = 1
												
					IF(@@ROWCOUNT <> @RecordsToAdd)
					BEGIN			
						SET @ErrorMessage = 'Failed in ' + @ProcSection
						RAISERROR (
									'%s',
									16,
									1,
									@ErrorMessage
									)
					END	
			END			
						
		/*ADD SECTION ENDS*/
		
		

		/*DELETE SECTION BEGINS*/			
			IF (@RecordsToDelete <> 0)
			BEGIN
				SET @ProcSection = 'Delete Section Coupon.CouponCustomerMap: '
				
				DELETE FROM [TescoSubscription].[Coupon].[CouponCustomerMap] 
				WHERE CouponID IN (
									SELECT Cpn.CouponID														
									FROM #TempLinkedCouponDetails Tcd
									INNER JOIN Coupon.Coupon Cpn
										ON Lower(Tcd.CouponCode) = Lower(Cpn.CouponCode)
										AND Tcd.IsActive = 0										
										)
					
				IF(@@ROWCOUNT <> @RecordsToDelete)
					BEGIN			
						SET @ErrorMessage = 'Failed in ' + @ProcSection
						RAISERROR (
									'%s',
									16,
									1,
									@ErrorMessage
									)
					END	
					
				
				SET @ProcSection = 'Delete Section Coupon.Coupon: '					 
				
				DELETE FROM [TescoSubscription].[Coupon].[Coupon]  
				WHERE CouponCode IN (SELECT TCD.CouponCode 
										FROM #TempLinkedCouponDetails Tcd
											WHERE Tcd.IsActive = 0
											AND NOT EXISTS (SELECT 1 FROM Coupon.CouponRedemption Cr (NOLOCK)
											WHERE Tcd.CouponCode = Cr.CouponCode)
											)
					
					
    		END		
		/*DELETE SECTION ENDS*/	
		
		COMMIT TRANSACTION [Save_CampaignDetails]
						
		END
	
		IF (@CampaignTypeId < 1 OR @CampaignTypeId > 3)
			BEGIN
				SET @ErrorMessage = 'Unrecognised CampaignType supplied in XML '
				
				IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION [Save_CampaignDetails]
				END
				
				RAISERROR (
						'%s',
						16,
						1,
						@ErrorMessage
						)
			END		
					
		--Removing Temporary Table(S)
		
		DROP TABLE #TempCampaignDetails
		
		DROP TABLE #TempLinkedCouponDetails
			
		DROP TABLE #TempCampaignAttributes

		DROP TABLE #TempDiscountTypes

		DROP TABLE #TempPlanID	
		PRINT 'CAMPAIGN AND COUPON(S) EDITED IN DATABASE FOR ' + CONVERT(NVARCHAR(100),@CampaignID) + ' CampaignID'
		
	END TRY	
	
	BEGIN CATCH
			SET @ErrorMessage = @ProcSection + ERROR_MESSAGE()
	
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION [Save_CampaignDetails]
			END

			IF OBJECT_ID('tempdb..#TempCampaignDetails') IS NOT NULL DROP TABLE #TempCampaignDetails
			IF OBJECT_ID('tempdb..#TempLinkedCouponDetails') IS NOT NULL DROP TABLE #TempLinkedCouponDetails
			IF OBJECT_ID('tempdb..#TempCampaignAttributes') IS NOT NULL DROP TABLE #TempCampaignAttributes
			IF OBJECT_ID('tempdb..#TempPlanID') IS NOT NULL DROP TABLE #TempPlanID
			IF OBJECT_ID('tempdb..#TempDiscountTypes') IS NOT NULL DROP TABLE #TempDiscountTypes
			RAISERROR (
					'SP - [coupon].[CampaignEdit1] Error = (%s)',
					16,
					1,
					@ErrorMessage
					)
	END CATCH

END

GO
GRANT EXECUTE ON  [Coupon].[CampaignEdit1] TO [SubsUser]
GO
