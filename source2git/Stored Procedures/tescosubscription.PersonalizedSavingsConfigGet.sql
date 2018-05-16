SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[PersonalizedSavingsConfigGet] 
AS

/*

	Author:			Deepmala Trivedi
	Date created:	08 Aug 2013
	Purpose:		To get all the Country Currencies
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<Scheduler>
	WarmUP Script:	NA    
*/

BEGIN

	   SET NOCOUNT ON		
	
	  SELECT [SettingName],
              [SettingValue]
	   FROM   [TescoSubscription].[ConfigurationSettings] (NOLOCK)
	   Where SettingName in ('IsPersonalizeSaving','PersonalizedSavingsAmount')
END


GO
GRANT EXECUTE ON  [tescosubscription].[PersonalizedSavingsConfigGet] TO [SubsUser]
GO
