SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionSwitchGet] 
(
      @CustomerSubscriptionID  BIGINT
     ,@CustomerID  BIGINT
)

AS
/*
Author:			Robin
Date created:	18 Feb 2013
Purpose:		To get the Switch history Details Based on CustomerSubscriptionID
Behaviour:		
Usage:			
Called by:		<DS>/Juvo

Execute [tescosubscription].[CustomerSubscriptionSwitchGet]  560603,72723281
select * from [tescosubscription].[CustomerSubscriptionSwitchHistory]where customersubscriptionid = 475993
insert into  [tescosubscription].[CustomerSubscriptionSwitchHistory] values (475993,1,16,'Scheduler',getdate())
 where customerSubscriptionID = 475993

--Modifications History--
	Changed On		Changed By		Defect Ref		                                Change Description
	
	
*/
BEGIN
	   
	SET NOCOUNT ON

IF EXISTS(SELECT 1 FROM tescosubscription.CustomerSubscription WHERE CustomerSubscriptionID = @CustomerSubscriptionID 
                                                                     AND CustomerID = @CustomerID )

BEGIN

     SELECT  SH.UTCRequestedDateTime DateRequested
		    ,Target_SP.PlanName NameOfNewPlan
		    ,Target_SM.StatusName Status 
		    ,Target_SP.PlanAmount PlanAmount 
            ,Target_SP.BasketValue MinimumOrder 
            ,Target_SP.PlanTenure PeriodOfPlan
			,CASE WHEN SH.SwitchStatus = 18 THEN NULL ELSE CS.NextRenewalDate END StartDate            
            ,SH.SwitchStatus
	 FROM tescosubscription.CustomerSubscription CS (NOLOCK)
	 INNER JOIN tescosubscription.SubscriptionPlan SP (NOLOCK)
	 ON CS.SubscriptionPlanID = SP.SubscriptionPlanID
	 INNER JOIN tescosubscription.StatusMaster SM (NOLOCK)
	 ON CS.SubscriptionStatus = SM.StatusID
     INNER JOIN tescosubscription.CustomerSubscriptionSwitchHistory SH (NOLOCK)
     ON CS.CustomerSubscriptionID = SH.CustomerSubscriptionID
     LEFT OUTER JOIN tescosubscription.SubscriptionPlan Target_SP (NOLOCK)
     ON SH.SwitchTo = Target_SP.SubscriptionPlanID
     INNER JOIN tescosubscription.StatusMaster Target_SM (NOLOCK)
     ON SH.SwitchStatus = Target_SM.StatusID
	 WHERE SH.CustomerSubscriptionID = @CustomerSubscriptionID 
     ORDER BY DateRequested DESC

END

ELSE
 
RAISERROR('[Procedure:INVALID INPUT ]',16,1)

END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionSwitchGet] TO [SubsUser]
GO
