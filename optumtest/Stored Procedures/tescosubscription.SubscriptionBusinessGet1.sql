SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionBusinessGet1]  
AS

/*
    Author:			Robin John
	Date created:	05 Dec 2012
	Purpose:		To get list of businesses
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [BOASubscription].[CountryCurrencyGet] 

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	
	12/06/2012       Robin							Correction **CREATE PROCEDURE
	12/11/2012		 Robin						    Added NOLOCK	
*/



BEGIN

	SET NOCOUNT ON			
			SELECT  [BusinessID]   'BusinessID',
				    [BusinessName] 'BusinessName'    
			FROM    [tescosubscription].[BusinessMaster] WITH (NOLOCK)
END


GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionBusinessGet1] TO [SubsUser]
GO
