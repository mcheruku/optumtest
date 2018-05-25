SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionSwitchHistoryGet] 
(
     @CustomerID BIGINT 
    ,@PageStart SMAllINT
    ,@TotalRecords   SMALLINT
)

AS
/*
Author:			Robin
Date created:	18 Feb 2013
Purpose:		To get the Switch history Details Based on CustomerID
Behaviour:		
Usage:			
Called by:		<DS>/Juvo

Execute [tescosubscription].[CustomerSubscriptionSwitchHistoryGet] 72723281,1,200
 

--Modifications History--
	Changed On		Changed By		Defect Ref		                                Change Description
	07 Mar 2013     Robin                                                           Changed the status Id as per the new status introduced 
	13 Mar 2013     Robin                                                           Changed the nextrenewaldate logic
*/
BEGIN
	   
	SET NOCOUNT ON

 
;WITH CTE
AS           --Inserting Records into Temp Table
(
	 SELECT  --CS.CustomerSubscriptionID
             SP.PlanName ExistingPlanName
			--,SM.StatusName ExistingStatusName
			,CS.NextRenewalDate SwitchDate
			,SH.UTCRequestedDateTime DateRequested
		    ,Target_SP.PlanName
		    ,Target_SM.StatusName
		    ,Target_SP.PlanAmount 
			,ROW_NUMBER() OVER(ORDER BY SH.UTCRequestedDateTime DESC) AS RowNum
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
	 WHERE CS.CustomerID = @CustomerID
)


SELECT  DateRequested                   -- Select the records from Temp Table along with Row_Number()
       ,ExistingPlanName 'From'
       ,PlanName 'To'
       ,StatusName 'Status'
       ,PlanAmount
	   ,CASE WHEN SwitchStatus = 18 THEN NULL ELSE SwitchDate END SwitchDate 
       FROM CTE
       WHERE RowNum BETWEEN @PageStart and (@PageStart + @TotalRecords - 1)
       ORDER BY RowNum


SELECT  COUNT(*) TotalRecords
	 FROM tescosubscription.CustomerSubscription CS (NOLOCK)
	 INNER JOIN tescosubscription.CustomerSubscriptionSwitchHistory SH (NOLOCK)
     ON CS.CustomerSubscriptionID = SH.CustomerSubscriptionID
     WHERE CS.CustomerID = @CustomerID


            
END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionSwitchHistoryGet] TO [SubsUser]
GO
