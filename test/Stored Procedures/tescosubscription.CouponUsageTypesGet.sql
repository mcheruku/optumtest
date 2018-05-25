SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [tescosubscription].[CouponUsageTypesGet] 
AS

/*

	Author:			Deepmala Trivedi
	Date created:	03 Apr 2014
	Purpose:		To get all the coupon usage types
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	    
*/

BEGIN
	SET NOCOUNT ON		

	SELECT UsageTypeId, UsageName FROM Coupon.CouponUsageType WITH (NOLOCK)
		
END



GO
GRANT EXECUTE ON  [tescosubscription].[CouponUsageTypesGet] TO [SubsUser]
GO
