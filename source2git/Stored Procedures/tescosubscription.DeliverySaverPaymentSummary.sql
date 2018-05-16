SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 CREATE PROCEDURE [tescosubscription].[DeliverySaverPaymentSummary]       
 
    
 AS  

/*

	Author:			Rangan Thulasi
	Date created:	18 Jan 2012
	Purpose:		
	WarmUP Script:	Execute [tescosubscription].[DeliverySaverPaymentSummary]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	11-5-2012		Saritha  K						Removed parameter Timeinterval
	27-6-2013       Robin                           Removed old logic and added CONVERT(VARCHAR(10), GETDATE(), 101)

*/
  
 BEGIN    
 SET NOCOUNT ON    

 IF 1=2
 BEGIN
	SELECT 1 TotalCount,'                              ' Remarks
 END


  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
    
 DECLARE @StartOfDay DATETIME
  ,@SuccessPaymentProcessStatus TINYINT     
   ,@InProgressPaymentProcessStatus TINYINT    
   ,@SystemFailureStatusID TINYINT    
      
 SELECT  @StartOfDay = CONVERT(VARCHAR(10), GETDATE(), 101)
   ,@SuccessPaymentProcessStatus = 6      
   ,@InProgressPaymentProcessStatus = 5    
   ,@SystemFailureStatusID = 3   
  
  

CREATE TABLE #PaymentProcessed (CustomerPaymentHistoryID BIGINT, PaymentProcessStatus TINYINT)
    
 INSERT INTO #PaymentProcessed    
 SELECT CustomerPaymentHistoryID,PaymentProcessStatus FROM    
     tescosubscription.PackageExecutionHistory PEH  
   JOIN [tescosubscription].CustomerPaymentHistory CPH ON  PEH.PackageStartTime >= @StartOfDay AND CPH.PackageExecutionHistoryID=PEH.PackageExecutionHistoryID    
   JOIN tescosubscription.CustomerSubscription CS ON CS.CustomerSubscriptionID =CPH.CustomerSubscriptionID-- TLog.TransactionRefrenceID    
     

    
      
 -- Successfully processed    
 SELECT COUNT(1) TotalCount,'Payment Process Success' Remarks FROM  #PaymentProcessed PP    
 join tescosubscription.CustomerPaymentHistoryResponse CPH on PP.CustomerPaymentHistoryID = CPH.CustomerPaymentHistoryID    
 WHERE PaymentStatusID <> @SystemFailureStatusID      
     
 UNION ALL    
     
 ---- System failure    
 SELECT COUNT(1) TotalCount, Remarks FROM #PaymentProcessed PP    
 join tescosubscription.CustomerPaymentHistoryResponse CPH on PP.CustomerPaymentHistoryID = CPH.CustomerPaymentHistoryID    
 WHERE PaymentStatusID = @SystemFailureStatusID     
 GROUP BY Remarks     
     
 UNION ALL    
     
 ---- Unknown error    
 SELECT COUNT(1) TotalCount,'Unknown Error' Remarks FROM    
   #PaymentProcessed PP 
 WHERE PP.PaymentProcessStatus= @InProgressPaymentProcessStatus    
   
    
  DROP TABLE #PaymentProcessed
  
     
END     
      
    
    
GO
GRANT EXECUTE ON  [tescosubscription].[DeliverySaverPaymentSummary] TO [SubsUser]
GO
