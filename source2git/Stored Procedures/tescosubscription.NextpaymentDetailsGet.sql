SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [tescosubscription].[NextpaymentDetailsGet]
(
	@CustomerSubsID BIGINT
)
AS

/*

	Author:			Saminathan
	Date created:	02/04/2014
	Purpose:		Returns next payment details
	Behaviour:		How does this procedure actually work
	Usage:			Hourly/Often
	Called by:		<JUVO>

    --Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
*/

	BEGIN
	
	  SET NOCOUNT ON		
		DECLARE @NextPlanID	INT,
		        @CustomerID BIGINT,
                @Suspended  TINYINT,
                @Active     TINYINT,
                @PendingStop TINYINT,
				@CouponPayment TINYINT,
				@CardPayment	TINYINT,
				@UpfrontPayment  TINYINT


        SELECT  @Suspended = 7,
                @Active = 8,
                @PendingStop = 11,
				@CouponPayment=2,
				@CardPayment=1,
				@UpfrontPayment =1
		
		
		SELECT @NextPlanID=COALESCE(SwitchTo,SubscriptionPlanID),
			   @CustomerID=CustomerID
			   FROM tescosubscription.CustomerSubscription WITH (NOLOCK)
			   WHERE CustomerSubscriptionID=@CustomerSubsID
			
		SELECT SP.SubscriptionPlanID as PlanID,
			
			NextRenewalDate AS	'PlanStartDate',
			PlanName,
			PlanTenure,
			PlanAmount,
			SP.PaymentInstallmentID,
			CASE WHEN SP.PaymentInstallmentID <> @UpfrontPayment THEN ROUND(PlanAmount/PlanTenure,2)* InstallmentTenure ELSE NULL END 'InstallmentAmount'	
	        FROM tescosubscription.CustomerSubscription CS WITH (NOLOCK) 
            INNER JOIN  tescosubscription.SubscriptionPlan SP WITH (NOLOCK)
	        ON SP.SubscriptionPlanID=@NextPlanID
			INNER JOIN [tescosubscription].[PaymentInstallment] IP WITH  (NOLOCK)
			ON SP.PaymentInstallmentID =IP.PaymentInstallmentID
	        WHERE CustomerSubscriptionID= @CustomerSubsID 
            AND (SubscriptionStatus IN (@Suspended,@Active) OR (SwitchTo IS NOT NULL AND SubscriptionStatus=@PendingStop  ))
			

		SELECT PaymentModeID,
				PaymentToken
				FROM tescosubscription.CustomerPayment WITH (NOLOCK) 
				WHERE CustomerID=@CustomerID and ((PaymentModeID=@CouponPayment AND IsActive = 1 AND IsFirstPaymentDue = 1 ) 
			    OR (PaymentModeID=@CardPayment AND  IsActive = 1 ))

	
	END


GO
GRANT EXECUTE ON  [tescosubscription].[NextpaymentDetailsGet] TO [SubsUser]
GO
