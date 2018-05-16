CREATE TABLE [tescosubscription].[CustomerPaymentRemainingDetail]
(
[CustomerSubscriptionId] [bigint] NOT NULL,
[PaymentRemainingAmount] [money] NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPaymentRemainingDetail_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPaymentRemainingDetail_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CustomerPaymentRemainingDetail] ADD CONSTRAINT [PK_CustomerPaymentRemainingDetail_CustomerSubscriptionID_PaymentRemainingAmount] PRIMARY KEY CLUSTERED  ([CustomerSubscriptionId], [PaymentRemainingAmount]) ON [PRIMARY]
GO
