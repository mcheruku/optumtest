SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE PROCEDURE [tescosubscription].[PackageExecutionHistoryCreate]   
(      
    @PackageID SMALLINT  
     ,@PackageStartTime DATETIME      
)  
  
AS  
  
/*  Author:   Saritha Kommineni  
 Date created: 22 Aug 2011  
 Purpose:     To insert PackageExecution details into [tescosubscription].[PackageExecutionHistory] table  
 Behaviour:    
 Usage:     
 Called by:  SSIS PACKAGE RenewCustomerSubscriptions.dtsx  
 WarmUP Script: Execute [tescosubscription].[PackageExecutionHistoryCreate] 1,'2011-10-10 12:34:56'  
  
--Modifications History--  
 Changed On      Changed By      Defect Ref          Change Description  
 28-09-2011		  Thulasi R                          Renamed sp to PackageExecutionHistoryCreate from PackageExecutionHistorysave  
  
   
*/  
  
BEGIN  
  
 SET NOCOUNT ON;  
  
  INSERT INTO [tescosubscription].[PackageExecutionHistory]            
   (  
    [PackageID]  
      ,[PackageStartTime]  
             ) 
	OUTPUT inserted.PackageExecutionHistoryID        
    VALUES   
           (  
              @PackageID
             ,@PackageStartTime                 
		   ) 


End
  
  
GO
GRANT EXECUTE ON  [tescosubscription].[PackageExecutionHistoryCreate] TO [SubsUser]
GO
