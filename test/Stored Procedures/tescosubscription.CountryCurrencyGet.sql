SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[CountryCurrencyGet] 
AS

/*

	Author:			Praneeth Raj
	Date created:	26 July 2011
	Purpose:		To get all the Country Currencies
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	Execute [BOASubscription].[CountryCurrencyGet] 

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	26-July-2011	Sheshgiri Balgi		<TFS no.>	Changed	Return Type to xml
    06-12-2012      Robin               Added country currency   
*/

BEGIN

	   SET NOCOUNT ON		
	
	   SELECT [CountryCurrencyID]  'CountryCurrencyID',
              [CountryCode]        'CountryCode' ,
			  [CountryCurrency]	   'CountryCurrency'    
	   FROM   [tescosubscription].[CountryCurrencyMap] (NOLOCK)
	   FOR XML PATH('CountryCodeDetail'),TYPE,root('CountryCodeDetails')
END

GO
GRANT EXECUTE ON  [tescosubscription].[CountryCurrencyGet] TO [SubsUser]
GO
