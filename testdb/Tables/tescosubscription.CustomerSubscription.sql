CREATE TABLE [tescosubscription].[CustomerSubscription]
(
[CustomerSubscriptionID] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [bigint] NOT NULL,
[SubscriptionPlanID] [int] NOT NULL,
[CustomerPlanStartDate] [datetime] NOT NULL,
[CustomerPlanEndDate] [datetime] NOT NULL,
[NextRenewalDate] [datetime] NOT NULL,
[SubscriptionStatus] [tinyint] NOT NULL,
[PaymentProcessStatus] [tinyint] NOT NULL CONSTRAINT [DF_CustomerSubscription_PaymentProcessStatus] DEFAULT ((6)),
[RenewalReferenceDate] [datetime] NOT NULL,
[EmailSentRenewalDate] [datetime] NOT NULL CONSTRAINT [DF_CustomerSubscription_EmailSentRenewalDate] DEFAULT (((1)/(1))/(1900)),
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerSubscription_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerSubscription_UTCUpdatedDateTime] DEFAULT (getutcdate()),
[SwitchTo] [int] NULL,
[SwitchCustomerSubscriptionID] [bigint] NULL,
[NextPaymentDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CustomerSubscription] ADD CONSTRAINT [PK_CustomerSubscription] PRIMARY KEY CLUSTERED  ([CustomerSubscriptionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerSubscription_CustomerID] ON [tescosubscription].[CustomerSubscription] ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerSubscription_NextPaymentDate] ON [tescosubscription].[CustomerSubscription] ([NextPaymentDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerSubscription_PaymentProcessStatus] ON [tescosubscription].[CustomerSubscription] ([PaymentProcessStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerSubscription_SubscriptionStatus_NextRenewalDate] ON [tescosubscription].[CustomerSubscription] ([SubscriptionStatus], [NextRenewalDate]) ON [PRIMARY]
GO
