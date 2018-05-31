SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerRemainingPaymentAfterCouponDiscountGet]
( 
	@CustomerId BIGINT
)
AS
BEGIN
SET NOCOUNT ON;

	SELECT [CustomerSubscriptionId]
          ,[PaymentRemainingAmount] 
      FROM [tescosubscription].[CustomerPaymentRemainingDetail] WITH (NOLOCK)
      WHERE [CustomerSubscriptionId] = @CustomerId
END

GO
GRANT EXECUTE ON  [tescosubscription].[CustomerRemainingPaymentAfterCouponDiscountGet] TO [SubsUser]
GO
