CREATE TABLE [tescosubscription].[CustomerPaymentHistory]
(
[CustomerPaymentHistoryID] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerPaymentID] [bigint] NOT NULL,
[CustomerSubscriptionID] [bigint] NOT NULL,
[PaymentDate] [datetime] NOT NULL,
[PaymentAmount] [smallmoney] NOT NULL,
[ChannelID] [tinyint] NOT NULL,
[PackageExecutionHistoryID] [bigint] NULL,
[IsEmailSent] [bit] NOT NULL CONSTRAINT [DF_CustomerPaymentHistory_IsEmailSent] DEFAULT ((0)),
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPaymentHistory_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPaymentHistory_UTCUpdatedDateTime] DEFAULT (getutcdate()),
[IsPreAuth] [bit] NOT NULL CONSTRAINT [DF_CustomerPaymentHistory_IsPreAuth] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CustomerPaymentHistory] ADD CONSTRAINT [PK_CustomerPaymentHistory] PRIMARY KEY CLUSTERED  ([CustomerPaymentHistoryID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerPaymentHistory_CustomerSubscriptionID] ON [tescosubscription].[CustomerPaymentHistory] ([CustomerSubscriptionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerPaymentHistory_IsEmailSent] ON [tescosubscription].[CustomerPaymentHistory] ([IsEmailSent]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerPaymentHistory_PackageExecutionHistoryID] ON [tescosubscription].[CustomerPaymentHistory] ([PackageExecutionHistoryID]) ON [PRIMARY]
GO
