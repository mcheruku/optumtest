SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignCountGetAll]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [Coupon].[CampaignCountGetAll]
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

CREATE PROCEDURE [Coupon].[CampaignCountGetAll]
AS

BEGIN

	SELECT COUNT(CampaignID) AS CampaignCount FROM Coupon.Campaign

END

GO
GRANT EXECUTE ON  [Coupon].[CampaignCountGetAll] TO [SubsUser]
GO
