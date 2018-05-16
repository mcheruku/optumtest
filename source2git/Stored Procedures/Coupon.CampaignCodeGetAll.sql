SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [Coupon].[CampaignCodeGetAll]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [Coupon].[CampaignCodeGetAll]
** DATE WRITTEN   : 27/06/2013                     
** ARGUMENT(S)    : NONE
** RETURN VALUE(S): 0 in case of success.
*******************************************************************************************  
*******************************************************************************************/
/*
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>

*/

CREATE PROCEDURE [Coupon].[CampaignCodeGetAll] 

AS

BEGIN

SET NOCOUNT ON;
DECLARE @ErrorMessage		NVARCHAR(2048)

BEGIN TRY

	SELECT CampaignCode from Coupon.Campaign
			
END TRY	
BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE()

		RAISERROR (
				'SP - [coupon].[CampaignCodeGetAll] Error = (%s)',
				16,
				1,
				@ErrorMessage
				)
END CATCH

END
GO
GRANT EXECUTE ON  [Coupon].[CampaignCodeGetAll] TO [SubsUser]
GO
