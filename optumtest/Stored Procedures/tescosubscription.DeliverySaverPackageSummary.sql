SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

CREATE  PROCEDURE [tescosubscription].[DeliverySaverPackageSummary]  
   
 AS 

/*

	Author:			Rangan Thulasi
	Date created:	18 Jan 2012
	Purpose:		
	WarmUP Script:	Execute [tescosubscription].[DeliverySaverPackageSummary]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	27 Jun 2013     Robin                           Removed old logic and added  CONVERT(VARCHAR(10), GETDATE(), 101)  

*/

   
 BEGIN    
 SET NOCOUNT ON    
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
    
 DECLARE @StartOfDay DATETIME    
      
 SELECT  @StartOfDay = CONVERT(VARCHAR(10), GETDATE(), 101)     
       
 -- package failure error      
 -- both packages included     
 SELECT PM.PackageName    
    FROM tescosubscription.PackageErrorLog Elog     
  JOIN tescosubscription.PackageExecutionHistory PEH ON Elog.PackageExecutionHistoryID = PEH.PackageExecutionHistoryID    
  JOIN tescosubscription.PackageMaster PM ON PM.PackageID = PEH.PackageID    
  WHERE   PEH.PackageStartTime >= @StartOfDay     
  GROUP BY PM.PackageName           
     
     
END        
   
GO
GRANT EXECUTE ON  [tescosubscription].[DeliverySaverPackageSummary] TO [SubsUser]
GO
