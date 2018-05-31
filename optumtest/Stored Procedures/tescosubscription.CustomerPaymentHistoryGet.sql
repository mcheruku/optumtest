SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [tescosubscription].[CustomerPaymentHistoryGet]
(
	@CustomerSubscriptionID	BIGINT
)
AS
/*
	Author:		Robin
	Created:	17/Feb/2014
	Purpose:	Get Customer Payment Details Based on CustomerSubscriptionID
    Behaviour:  How does this procedure actually work
    Usage:      Called By Juvo     

	--Modifications History--
 	Changed On        Changed By  Defect  Changes  Change Description 
	14th July 2014    Robin                        Added condition not to fetch PreAuth Records as per new requirement.
	10th March 2015   Priyansh					   Changing the order of selection			
*/
BEGIN

	
		 SELECT  
           CP.[CustomerID]
		  ,CP.[PaymentModeID]
		  ,CP.[PaymentToken]
		  ,PH.[PaymentDate]
		  ,PH.[PaymentAmount]
		  ,HR.[PaymentStatusID]
		  ,HR.[Remarks]      
		 FROM [TescoSubscription].[CustomerPayment] CP WITH (NOLOCK)
		 LEFT JOIN [TescoSubscription].[CustomerPaymentHistory] PH WITH (NOLOCK)
		 ON CP.CustomerPaymentID = PH.CustomerPaymentID
		 LEFT JOIN [TescoSubscription].[CustomerPaymentHistoryResponse] HR WITH (NOLOCK)
		 ON HR.CustomerPaymentHistoryID = PH.CustomerPaymentHistoryID
		 WHERE CustomerSubscriptionID = @CustomerSubscriptionID AND IsPreAuth=0
		 ORDER BY PH.[PaymentDate] desc

      
END
GO
GRANT EXECUTE ON  [tescosubscription].[CustomerPaymentHistoryGet] TO [SubsUser]
GO
