SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[SubscriptionMasterGet1] 
AS

/*
    Author:			Robin John
	Date created:	05 Dec 2012
	Purpose:		To get subscriptions master data
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [BOASubscription].[CountryCurrencyGet] 

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	12/06/2012       Robin                           Correction *** CREATE PROCEDURE
	12/12/2012		 Robin	                         Added WITH (NOLOCK)

*/

BEGIN

			SET NOCOUNT ON	
		
			SELECT [SubscriptionID]   'SubscriptionID',
				   [SubscriptionName] 'SubscriptionName'   
		    FROM   [tescosubscription].[SubscriptionMaster] WITH (NOLOCK) 
			ORDER BY [SubscriptionName]  
END

GO
GRANT EXECUTE ON  [tescosubscription].[SubscriptionMasterGet1] TO [SubsUser]
GO
