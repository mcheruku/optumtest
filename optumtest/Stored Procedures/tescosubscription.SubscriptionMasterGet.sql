SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionMasterGet] 
AS

/*

	Author:			Praneeth Raj
	Date created:	26 July 2011
	Purpose:		To get subscriptions master data
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [tescosubscription].[SubscriptionMasterGet] 

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	26-July-2011	Sheshgiri Balgi		<TFS no.>	Changed	Return Type to xml
	28-July-2011	Ravi Paladugu					Changed Xml element name from SubscriptionTypeDetail to SubscriptionMasterDetail

*/

BEGIN

			SET NOCOUNT ON	
		
			SELECT [SubscriptionID]   'SubscriptionID',
				   [SubscriptionName] 'SubscriptionName'   
		    FROM   [tescosubscription].[SubscriptionMaster] 
			ORDER BY [SubscriptionName] 
			FOR XML PATH('SubscriptionMasterDetail'),TYPE,root('SubscriptionMasterDetails')	


END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionMasterGet] TO [SubsUser]
GO
