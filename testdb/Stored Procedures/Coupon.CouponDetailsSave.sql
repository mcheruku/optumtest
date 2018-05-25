SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

    
CREATE PROCEDURE [Coupon].[CouponDetailsSave] 
(@CouponDetailsXML XML)
AS
	/*   
Author:  Swaraj    
Created: 04/Oct/2012    
Purpose: Save Coupons Details    

Example:    
Execute [coupon].[CouponDetailsSave] @CouponDetailsXML =     
'    
<ArrayOfCouponDetails>  
<CouponDetails CouponID="0" CouponCode="DDWDQ" DescriptionShort="Testing ADD" DescriptionLong="New" Amount="15.0000" RedeemCount="0" IsActive="false" UTCCreatedeDateTime="2012-10-10T00:00:00" UTCUpdatedDateTime="2012-10-10T00:00:00">  
<CouponAttributesList>  
<CouponAttribute>  
<AttributeID>1</AttributeID><AttributeValue>1</AttributeValue>  
</CouponAttribute>  
<CouponAttribute>  
<AttributeID>2</AttributeID><AttributeValue>2012/10/06</AttributeValue>  
</CouponAttribute>  
<CouponAttribute>  
<AttributeID>3</AttributeID><AttributeValue>2012/10/14</AttributeValue>  
</CouponAttribute>  
<CouponAttribute>  
<AttributeID>4</AttributeID><AttributeValue>500</AttributeValue>  
</CouponAttribute>  
<CouponAttribute>  
<AttributeID>5</AttributeID><AttributeValue>15</AttributeValue>  
</CouponAttribute>  
</CouponAttributesList>  
</CouponDetails>  
</ArrayOfCouponDetails>  
'    
--Modifications History--    
Changed On   Changed By  Defect  Changes  Change Description     

*/   

BEGIN
	SET NOCOUNT ON;     
	DECLARE @ErrorMessage    NVARCHAR(2048),
	        @CurrentUTCDate  SMALLDATETIME  
	
	CREATE TABLE #couponDetails
	(
		[CouponID]          [bigint] NOT NULL,
		[CouponCode]        [nvarchar](25) NOT NULL,
		[DescriptionShort]  [nvarchar](200) NULL,
		[DescriptionLong]   [nvarchar](300) NULL,
		[Amount]            [money],
		[IsActive]          [bit] NOT NULL DEFAULT((0)),
		AttributeId         SMALLINT NULL,
		AttributeValue      VARCHAR(50)
	)    
	
	SELECT @CurrentUTCDate = GETUTCDATE()
		
	INSERT INTO #couponDetails
	  (
	    CouponID,
	    CouponCode,
	    DescriptionShort,
	    DescriptionLong,
	    Amount,
	    IsActive,
	    AttributeId,
	    AttributeValue
	  )
	SELECT T.C.value('../../@CouponID[1]', 'bigint') [CouponID],
	       T.C.value('../../@CouponCode[1]', 'nvarchar(25)') [CouponCode],
	       T.C.value('../../@DescriptionShort[1]', 'NVARCHAR(200)') 
	       [DescriptionShort],
	       T.C.value('../../@DescriptionLong[1]', 'NVARCHAR(300)') 
	       [DescriptionLong],
	       T.C.value('../../@Amount[1]', 'money') Amount,
	       T.C.value('../../@IsActive[1]', 'bit') [IsActive],
	       T.C.value('AttributeID[1]', 'smallint') AttributeID,
	       T.C.value('AttributeValue[1]', 'nvarchar(50)') AttributeValue
	FROM   @CouponDetailsXML.nodes(
	           'ArrayOfCouponDetails/CouponDetails/CouponAttributesList/CouponAttribute'
	       ) T(c)    
	
	BEGIN TRY
		BEGIN TRANSACTION Save_CouponDetails 
		--Update  Coupon.Coupon
		--   
		
		UPDATE Coupon.Coupon
		SET    DescriptionShort = cd.DescriptionShort,
		       DescriptionLong = cd.DescriptionLong,
		       Amount = cd.Amount,
		       IsActive = cd.IsActive,		       
		       UTCUpdatedDateTime = @CurrentUTCDate
		FROM   #couponDetails cd
		       INNER JOIN Coupon.Coupon c
		            ON  c.CouponID = cd.CouponID 
		
		--update Coupon.CouponAttributes    
		UPDATE Coupon.CouponAttributes
		SET    AttributeValue = cd.AttributeValue,
		       UTCUpdatedDateTime = @CurrentUTCDate
		FROM   #couponDetails cd
		       INNER JOIN Coupon.CouponAttributes ca
		            ON  ca.CouponID = cd.CouponID
		            AND ca.AttributeId = cd.AttributeId 
		
		--Insert into Coupon.Coupon    
		INSERT INTO Coupon.Coupon
		  (
		    CouponCode,
		    DescriptionShort,
		    DescriptionLong,
		    Amount,
		    IsActive
		  )
		SELECT DISTINCT 
		       cd.CouponCode,
		       cd.DescriptionShort,
		       cd.DescriptionLong,
		       cd.Amount,
		       cd.IsActive
		FROM   #couponDetails cd
		       LEFT JOIN Coupon.Coupon c
		            ON  c.CouponID = cd.CouponID
		WHERE  c.CouponID IS NULL   
		
		INSERT INTO coupon.CouponAttributes
		  (
		    CouponID,
		    AttributeID,
		    AttributeValue
		  )
		SELECT C.CouponId,
		       cd.AttributeId,
		       cd.AttributeValue  
		FROM   #couponDetails CD
		       JOIN Coupon.Coupon C
		            ON  CD.CouponCode = C.CouponCode
		       LEFT JOIN Coupon.CouponAttributes ca
		            ON  ca.CouponID = C.CouponID
		            AND ca.AttributeId = CD.AttributeId
		WHERE  CA.AttributeID IS NULL 
		
		COMMIT TRANSACTION [Save_CouponDetails]
	END TRY    
	BEGIN CATCH		 
	    SET @ErrorMessage = ERROR_MESSAGE()
	     
		IF @@TRANCOUNT > 0
		BEGIN
		    ROLLBACK TRANSACTION [Save_CouponDetails]
		END 
		
		RAISERROR (
		    'SP - [coupon].[CouponDetailsSave] Error = (%s)',
		    16,
		    1,
		    @ErrorMessage
		)
	END CATCH 
	
	DROP TABLE #couponDetails
END

GO
GRANT EXECUTE ON  [Coupon].[CouponDetailsSave] TO [SubsUser]
GO
