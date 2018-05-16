SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignDetailsSave]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [Coupon].[CampaignDetailsSave]
** DATE WRITTEN   : 25/06/2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): 0 in case of success.
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>

*/

CREATE PROCEDURE [Coupon].[CampaignDetailsSave] 
(
@XmlDocument XML
)
AS

BEGIN

	SET NOCOUNT ON

	DECLARE @ErrorMessage			NVARCHAR(2048)
	DECLARE @XmlDocumentHandle		INT
	DECLARE @NewCampaignId			BIGINT	
	DECLARE @SaveIdnFlag			VARCHAR(50)
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
			,GetUTCDate() AS UTCCreatedeDateTime
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
	
	SELECT @CampaignTypeId = CampaignTypeId FROM  #TempCampaignDetails
	
	IF (@CampaignTypeId = 3) --Linked Coupon(s) need to be generated
		BEGIN
			SELECT CustomerID
					,CouponCode
					--,DescriptionShort
					--,DescriptionLong
					,Amount
					,RedeemCount
					,CASE WHEN IsActive like 'True'
						THEN 1
						ELSE
						0
					END AS IsActive
					,CampaignID
					,GetUTCDate() AS UTCCreatedeDateTime
					,GetUTCDate() AS UTCUpdatedDateTime
			INTO #TempLinkedCouponDetails
			FROM(
			SELECT *
			FROM OPENXML (@XmlDocumentHandle, '/Campaign/CouponsList/CouponDetail',1)
			WITH (	CustomerID			bigint,
					CouponCode			nvarchar(25),
					--DescriptionShort	nvarchar(200),
					--DescriptionLong		nvarchar(300),
					Amount				Money,
					RedeemCount			int,
					IsActive			varchar(5),
					CampaignID			bigint
				  )
				  )TempCoupon
		END
	ELSE
		BEGIN	     
			--Coupons Details 
			SELECT  CouponCode
					--,DescriptionShort
					--,DescriptionLong
					,Amount
					,RedeemCount
					,CASE WHEN IsActive like 'True'
						THEN 1
						ELSE
						0
					END AS IsActive
					,CampaignID
					,GetUTCDate() AS UTCCreatedeDateTime
					,GetUTCDate() AS UTCUpdatedDateTime
			INTO #TempCouponDetails
			FROM(
				SELECT *
				FROM OPENXML (@XmlDocumentHandle, '/Campaign/CouponsList/CouponDetail',1)
				WITH (	CouponCode			NVARCHAR(25),
						--DescriptionShort	NVARCHAR(200),
						--DescriptionLong		NVARCHAR(300),
						Amount				MONEY,
						RedeemCount			INT,
						IsActive			VARCHAR(5),
						CampaignID			BIGINT
					  )
				  )TempCoupon
		END     

	--Attribute Details 
	SELECT TempAttributes.*
			,GETUTCDATE() AS [UTCCreatedDateTime]
			,GETUTCDATE() AS [UTCUpdatedDateTime]
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

	END TRY

	BEGIN CATCH
		SET @ErrorMessage = @ProcSection + ERROR_MESSAGE()
		
		RAISERROR (
				'SP - [coupon].[CampaignDetailsSave] Error = (%s)',
				16,
				1,
				@ErrorMessage
			)
	END CATCH


	BEGIN TRY
	
	BEGIN TRANSACTION [Save_CampaignDetails] 

	IF (@CampaignTypeId >=1 AND @CampaignTypeId <=3) --Saving Campaign Details and Naive or Unique Coupon(s)
	BEGIN
			SET @ProcSection = 'Section in Coupon.Campaign:'
			
			INSERT INTO [TescoSubscription].[Coupon].[Campaign]
					   ([CampaignCode]
					   ,[DescriptionShort]
					   ,[DescriptionLong]
					   ,[Amount]
					   ,[IsActive]
					   ,[CampaignTypeId]
					   ,[UTCCreatedDateTime]
					   ,[UTCUpdatedDateTime])
				SELECT CampaignCode
						,DescriptionShort
						,DescriptionLong
						,Amount
						,IsActive
						,CampaignTypeId
						,UTCCreatedeDateTime
						,UTCUpdatedDateTime
				FROM #TempCampaignDetails		
				
			SELECT @NewCampaignId = @@IDENTITY
					
			PRINT 'New CampaignID Generated: ' + Convert(Varchar(200),@NewCampaignId) --remove this line in final code of proc
			
			SET @ProcSection = 'Section in Coupon.Coupon: '
			
			IF (@CampaignTypeId >=1 AND @CampaignTypeId <=2)
			BEGIN
			--PRINT 'INSERTING NAIVE OR UNIQUE COUPONS'
			INSERT INTO [TescoSubscription].[Coupon].[Coupon]
					   ([CouponCode]
					   --,[DescriptionShort]
					   --,[DescriptionLong]
					   ,[Amount]
					   ,[RedeemCount]
					   ,[IsActive]
					   ,[UTCCreatedeDateTime]
					   ,[UTCUpdatedDateTime]
					   ,[CampaignID])
				SELECT CouponCode
						--,DescriptionShort
						--,DescriptionLong
						,Amount
						,RedeemCount
						,IsActive					
						,UTCCreatedeDateTime
						,UTCUpdatedDateTime
						,@NewCampaignId
				FROM #TempCouponDetails
			END
			
			IF (@CampaignTypeId = 3) --Customer Linked Coupons
			BEGIN
				--PRINT 'INSERTING LINKED COUPONS'
				INSERT INTO [TescoSubscription].[Coupon].[Coupon]
					   ([CouponCode]
					   --,[DescriptionShort]
					   --,[DescriptionLong]
					   ,[Amount]
					   ,[RedeemCount]
					   ,[IsActive]
					   ,[UTCCreatedeDateTime]
					   ,[UTCUpdatedDateTime]
					   ,[CampaignID])
				SELECT CouponCode
						--,DescriptionShort
						--,DescriptionLong
						,Amount
						,RedeemCount
						,IsActive					
						,UTCCreatedeDateTime
						,UTCUpdatedDateTime
						,@NewCampaignId
				FROM #TempLinkedCouponDetails
			END
				
			SET @ProcSection = 'Section Coupon.CampaignAttributes: '
							
			INSERT INTO [TescoSubscription].[Coupon].[CampaignAttributes]
					   ([CampaignID]
					   ,[AttributeID]
					   ,[AttributeValue]
					   ,[UTCCreatedDateTime]
					   ,[UTCUpdatedDateTime])
				SELECT @NewCampaignId
						,AttributeID
						,AttributeValue
						,UTCCreatedDateTime
						,UTCUpdatedDateTime
				FROM #TempCampaignAttributes		
				
				
		END
			
	IF (@CampaignTypeId = 3)
		BEGIN		
			SET @ProcSection = 'Section Coupon.CouponCustomerMap: '
				
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
				ON Lower(Tcd.CouponCode) = Lower(Cpn.CouponCode)					
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
		
		COMMIT TRANSACTION [Save_CampaignDetails]		
				
	--Removing Temporary Table(S)
	
	DROP TABLE #TempCampaignDetails
	
	IF (@CampaignTypeId <> 3)
	BEGIN
		DROP TABLE #TempCouponDetails
	END
	ELSE
	BEGIN
		DROP TABLE #TempLinkedCouponDetails
	END
	
	DROP TABLE #TempCampaignAttributes

	--Selecting the new Campaign ID generated in String Format as per UI req.
	SELECT CONVERT(VARCHAR(100),@NewCampaignId)				
	PRINT 'CAMPAIGN AND COUPON(S) SUCCESSFULLY SAVED IN DATABASE.'		
		
	END TRY	
	BEGIN CATCH
			SET @ErrorMessage = @ProcSection + ERROR_MESSAGE()
	
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION [Save_CampaignDetails]
			END
			
			RAISERROR (
					'SP - [coupon].[CampaignDetailsSave] Error = (%s)',
					16,
					1,
					@ErrorMessage
					)
	END CATCH

END
GO
GRANT EXECUTE ON  [Coupon].[CampaignDetailsSave] TO [SubsUser]
GO
