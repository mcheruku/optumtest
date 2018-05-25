SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignEdit]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [Coupon].[CampaignEdit]
** DATE WRITTEN   : 09th July 2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): 0 in case of success.
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>

*/

CREATE PROCEDURE [Coupon].[CampaignEdit] 
(
@XmlDocument XML
)
AS

BEGIN

	SET NOCOUNT ON

	DECLARE @ErrorMessage			NVARCHAR(2048)
	DECLARE @XmlDocumentHandle		INT
	DECLARE @CampaignID				BIGINT
	DECLARE @RecordsToAdd			BIGINT
	DECLARE @RecordsToDelete		BIGINT
	DECLARE @RecordsToDeleteCoup	BIGINT
	DECLARE @ProcSection			VARCHAR(100)
	DECLARE @CampaignTypeID			INT
	

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
			,GetUTCDate() AS UTCUpdatedDateTime
	INTO #TempCampaignDetails		
	FROM (			
		SELECT *
		FROM OPENXML (@XmlDocumentHandle, '/Campaign',1)
		WITH (	CampaignID			BIGINT,				--check on this
				CampaignCode		NVARCHAR(25),
				DescriptionShort	NVARCHAR(200),
				DescriptionLong		NVARCHAR(300),
				Amount				MONEY,
				IsActive			VARCHAR(5),
				CampaignTypeId int
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
			@CampaignTypeId = CampaignTypeId 
	FROM  #TempCampaignDetails
	
	SELECT CustomerID
			,CouponCode
			,Amount
			,RedeemCount
			,CASE WHEN IsActive like 'True'
				THEN 1
				ELSE
				0
			END AS IsActive
			,CASE WHEN IsRedeemed like 'True'
				THEN 1
				ELSE
				0
			END AS IsRedeemed
			,CampaignID
			,ActionFlag				
	INTO #TempLinkedCouponDetails
	FROM(
	SELECT *
	FROM OPENXML (@XmlDocumentHandle, '/Campaign/CouponsList/CouponDetail',1)
	WITH (	CustomerID			BIGINT,
			CouponCode			NVARCHAR(25),
			Amount				MONEY,
			RedeemCount			INT,
			IsActive			VARCHAR(5),
			IsRedeemed			VARCHAR(5),
			CampaignID			BIGINT,
			ActionFlag			VARCHAR(10)
		  )
		)TempCoupon
				  
	SELECT @RecordsToAdd = Count(*) FROM #TempLinkedCouponDetails WHERE IsActive = 1 --Getting records to insert
	
	SELECT @RecordsToDelete = Count(*) FROM #TempLinkedCouponDetails WHERE IsActive = 0 --Getting records to delete
	
	SELECT @RecordsToDeleteCoup = Count(*) FROM #TempLinkedCouponDetails WHERE IsActive = 0 AND IsRedeemed = 0 -- Getting coupons to delete
	
	--Attribute Details 
	SELECT TempAttributes.*						
	INTO #TempCampaignAttributes
	FROM(
		SELECT *
		FROM OPENXML (@XmlDocumentHandle, 'Campaign/CampaignAttributesList/CampaignAttribute',3)
		WITH (AttributeID		SMALLINT,
			  AttributeValue	NVARCHAR(50)
			  )
		)TempAttributes
	ORDER BY TempAttributes.AttributeId 

	EXEC sp_xml_removedocument @XmlDocumentHandle


	BEGIN TRANSACTION [Save_CampaignDetails] 

	IF (@CampaignTypeId >=1 AND @CampaignTypeId <=3) --Editing Campaign Details for all Coupon(s)
	BEGIN
		
			SET @ProcSection = 'Update Section in Coupon.Campaign:'
				
			UPDATE [TescoSubscription].[Coupon].[Campaign]
					SET	CampaignCode = TCD.CampaignCode
						,DescriptionShort = TCD.DescriptionShort
						,DescriptionLong = TCD.DescriptionLong
						,Amount = TCD.Amount
						,IsActive = TCD.IsActive
						,CampaignTypeId = TCD.CampaignTypeId						
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
			
			SET @ProcSection = 'Update Section Coupon.CampaignAttributes: '			
			
			UPDATE [TescoSubscription].[Coupon].[CampaignAttributes]
				SET	AttributeValue = TCA.AttributeValue,
					UTCUpdatedDateTime = GETUTCDATE()
				FROM #TempCampaignAttributes TCA
				INNER JOIN Coupon.CampaignAttributes CA
					   ON  CA.CampaignID = @CampaignID
					   AND CA.AttributeId = TCA.AttributeId	
					
			IF(@@ROWCOUNT <> 6)
			BEGIN			
				SET @ErrorMessage = 'Failed in ' + @ProcSection
				
				RAISERROR (
							'%s',
							16,
							1,
							@ErrorMessage
							)
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
							,Amount
							,RedeemCount
							,IsActive					
							,GetUTCDate() AS [UTCCreatedeDateTime]
							,GetUTCDate() AS [UTCUpdatedDateTime]
							,CampaignId
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
											AND Tcd.IsRedeemed = 0
											)
					
					
				IF(@@ROWCOUNT <> @RecordsToDeleteCoup)
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
						
			RAISERROR (
					'SP - [coupon].[CampaignEdit] Error = (%s)',
					16,
					1,
					@ErrorMessage
					)
	END CATCH

END
GO
GRANT EXECUTE ON  [Coupon].[CampaignEdit] TO [SubsUser]
GO
