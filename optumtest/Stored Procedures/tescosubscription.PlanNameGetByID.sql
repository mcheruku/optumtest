SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************  
********************************************************************************************  
** TYPE           : CREATE PROCEDURE  
** NAME           : PROCEDURE [TescoSubscription].[PlanNameGetByID]   
** AUTHOR         : INFOSYS TECHNOLOGIES LIMITED  
** DESCRIPTION    : THIS SCRIPT WILL CREATE PROCEDURE [TescoSubscription].[PlanNameGetByID]
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

CREATE PROCEDURE [tescosubscription].[PlanNameGetByID]
(
@SubscriptionPlanID	INT
)
AS
BEGIN

	SELECT PlanName 
	FROM tescosubscription.SubscriptionPlan Sp
	WHERE Sp.SubscriptionPlanID = @SubscriptionPlanID
	
	IF(@@ROWCOUNT > 1 OR @@ROWCOUNT = 0)
	BEGIN
		RAISERROR('ERROR - Procedure [TescoSubscription].[PlanNameGetByID]: multiple name found or plan doesn''t exist',16,1)
	END
	

END

GO
GRANT EXECUTE ON  [tescosubscription].[PlanNameGetByID] TO [SubsUser]
GO
