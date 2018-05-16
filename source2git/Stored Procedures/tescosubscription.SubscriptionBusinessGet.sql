SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionBusinessGet]  
AS

/*

	Author:			Praneeth Raj
	Date created:	26 July 2011
	Purpose:		To get list of businesses
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [tescosubscription].[SubscriptionBusinessGet]  

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	26-July-2011	Sheshgiri Balgi		<TFS no.>	Changed	Return Type to xml


*/



BEGIN

	SET NOCOUNT ON			
			SELECT  [BusinessID]   'BusinessID',
				    [BusinessName] 'BusinessName'    
			FROM    [tescosubscription].[BusinessMaster]	
		    FOR XML PATH('BusinessDetail'),TYPE,root('BusinessDetails')
END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionBusinessGet] TO [SubsUser]
GO
