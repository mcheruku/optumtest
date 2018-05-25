SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionGet1]
	(@CustomerSubscriptionID BIGINT)
AS
/*
Author:		Robin
Create date: 10 - Feb - 2013
Purpose: To get the customer subscription
Called by:		DS

--Modifications History--
Changed On		Changed By		Defect Ref		Change Description
27 June 2013    RObin                           Versioned and added Logic for NextPaymentDate
*/

BEGIN	
	SET NOCOUNT ON;

	SELECT CS.[CustomerSubscriptionID]
      ,CS.[CustomerID]
      ,CS.[SubscriptionPlanID]
      ,CS.[CustomerPlanStartDate]
      ,CS.[CustomerPlanEndDate]
      ,CS.[NextRenewalDate]
      ,CS.[SubscriptionStatus]
      ,CS.[PaymentProcessStatus]
      ,CS.[RenewalReferenceDate]
      ,CS.[EmailSentRenewalDate]
      ,CS.[UTCCreatedDateTime]
      ,CS.[UTCUpdatedDateTime]
      ,CS.[SwitchCustomerSubscriptionID]
      ,CS.[SwitchTo]
      ,CS.[NextPaymentDate]
      ,CASE WHEN CS.NextPaymentDate IS NULL THEN 0 ELSE ISNULL(DATEDIFF(M,CS.NextPaymentDate,CS.NextRenewalDate)/IP.InstallmentTenure,0) END RemainingInstallments					
	FROM [TescoSubscription].[CustomerSubscription] CS(NOLOCK)
    INNER JOIN [Tescosubscription].[SubscriptionPlan] SP (NOLOCK)
    ON CS.SubscriptionPlanID = SP.SubscriptionPlanID
    INNER JOIN [Tescosubscription].[PaymentInstallment] IP (NOLOCK) 
    ON SP.PaymentInstallmentID = IP.PaymentInstallmentID
	WHERE CS.[CustomerSubscriptionID] = @CustomerSubscriptionID
END

GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionGet1] TO [SubsUser]
GO
