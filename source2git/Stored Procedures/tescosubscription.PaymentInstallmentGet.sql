SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



	
	CREATE PROCEDURE [tescosubscription].[PaymentInstallmentGet]
		-- Add the parameters for the stored procedure here
		
	AS
	/*

	Author:			Robin
	Date created:	29/11/2012
	Purpose:		To get list of all PaymentInstallment details  
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<BOA>
	WarmUP Script:	

	--Modifications History--
 	Changed On   Changed By  Defect  Changes  Change Description 
	12/12/2012	 Robin						  Added  WITH (NOLOCK)
	

*/
	BEGIN
	

		 SET NOCOUNT ON

		  SELECT [PaymentInstallmentID]
			  ,[PaymentInstallmentName]
			 FROM [tescosubscription].[PaymentInstallment] WITH (NOLOCK)
	END





GO
GRANT EXECUTE ON  [tescosubscription].[PaymentInstallmentGet] TO [SubsUser]
GO
