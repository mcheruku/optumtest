SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[PackageErrorLogCreate] 
(	  
       @ErrorID BIGINT
      ,@PackageExecutionHistoryID BIGINT
      ,@ErrorDescription VARCHAR(1000)
      ,@ErrrorDateTime DATETIME
  )

AS

/*  Author:			Saritha Kommineni
	Date created:	22 Aug 2011
	Purpose:	    To insert PackageError Log details into [tescosubscription].[PackageErrorLog] table
	Behaviour:		
	Usage:			
	Called by:		SSIS PACKAGE RenewCustomerSubscriptions.dtsx
	WarmUP Script:	Execute [tescosubscription].[PackageErrorLogCreate] 

--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
		
*/

BEGIN

	SET NOCOUNT ON;

		INSERT INTO [tescosubscription].[PackageErrorLog]
			(
             [ErrorID]
			 ,[PackageExecutionHistoryID] 
		     ,[ErrorDescription]
			 ,[ErrorDateTime]
             )            
		VALUES	
           (
              @ErrorID
              ,@PackageExecutionHistoryID
              ,@ErrorDescription  
              ,@ErrrorDateTime        		
		   )	
END

 
GO
GRANT EXECUTE ON  [tescosubscription].[PackageErrorLogCreate] TO [SubsUser]
GO
