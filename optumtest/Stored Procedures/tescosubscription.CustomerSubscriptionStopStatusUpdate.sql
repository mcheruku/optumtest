SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionStopStatusUpdate]

AS

/*

	Author:		   Saritha Kommineni
	Date created:  25 Aug 2011
	Purpose:	   Updates subscriptions with status 'pending stop' to 'Stopped'	
	Behaviour:		
	Usage:			
	Called by:		
	WarmUP Script:	
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	

*/

BEGIN
			
SET NOCOUNT ON

DECLARE @Stopped TINYINT
	   ,@PendingStop TINYINT

-- Below Assigned values are status Id reference data from status master table
SELECT  @Stopped=10, 
        @PendingStop=11


  -- Updates subscriptions with status 'pending stop' to 'Stopped'

		UPDATE tescosubscription.CustomerSubscription
		SET    SubscriptionStatus= @Stopped,
               UTCUpdatedDateTime= GetUTCDate()
        WHERE  CustomerPlanEndDate < CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),101) + ' 23:59:59')
        AND    SubscriptionStatus=@PendingStop  

END
GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionStopStatusUpdate] TO [SubsUser]
GO
