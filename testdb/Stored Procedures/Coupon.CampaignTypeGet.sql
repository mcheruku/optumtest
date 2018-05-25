SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignTypeGet]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [TescoSubscription].[CampaignTypeGet]
** DATE WRITTEN   : 06/04/2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): DATA OF TABLE [Coupon].[CampaignTypeGet] WHICH IS ACTIVE
*******************************************************************************************  
*******************************************************************************************/

CREATE PROCEDURE [Coupon].[CampaignTypeGet]
AS


BEGIN

	SET NOCOUNT ON;	

	SELECT 
		CampaignTypeID as [CampaignTypeId],
		CampaignTypeName as [CampaignTypeName],
		Description
	FROM [Coupon].[CampaignTypeMaster]
	WHERE IsActive = 1 --Active Campaign
	--FOR XML PATH('SubscriptionCouponType'),TYPE,root('SubscriptionCouponTypes')

END

GO
GRANT EXECUTE ON  [Coupon].[CampaignTypeGet] TO [SubsUser]
GO
