SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [tescosubscription].[PackageExecutionHistoryUpdate] 
(	   
        @PackageExecutionHistoryID  BIGINT
       ,@PackageEndtime DATETIME
       ,@statusID TINYINT
)

AS

/*  Author:			Saritha Kommineni
	Date created:	22 Aug 2011
	Purpose:	    To update PackageExecution details into [tescosubscription].[PackageExecutionHistory] table
	Behaviour:		
	Usage:			
	Called by:		
	WarmUP Script:	Execute [tescosubscription].[PackageExecutionHistoryUpdate]  

--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	
*/

BEGIN
SET NOCOUNT ON;

		Update  [tescosubscription].[PackageExecutionHistory]          
		set [PackageEndTime]= @PackageEndtime,
			[statusID] = @statusID
		where PackageExecutionHistoryID = @PackageExecutionHistoryID 

END


GO
GRANT EXECUTE ON  [tescosubscription].[PackageExecutionHistoryUpdate] TO [SubsUser]
GO
