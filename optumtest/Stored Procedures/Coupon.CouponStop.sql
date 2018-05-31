SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Coupon].[CouponStop]
(
    @CouponId Bigint
)
AS
	/*
Author:		Swaraj
Created:	04/Oct/2012
Purpose:	Stop a Coupons

execute coupon.couponstop 1
--Modifications History--
Changed On   Changed By  Defect  Changes  Change Description 

*/

BEGIN
	SET NOCOUNT ON;
	
	UPDATE Coupon.Coupon
		SET	
			IsActive = 0,
			UTCUpdatedDateTime = GETUTCDATE()	
		WHERE 
			CouponID = @CouponId
END
GO
GRANT EXECUTE ON  [Coupon].[CouponStop] TO [SubsUser]
GO
