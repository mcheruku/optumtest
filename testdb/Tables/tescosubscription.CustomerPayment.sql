CREATE TABLE [tescosubscription].[CustomerPayment]
(
[CustomerPaymentID] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerID] [bigint] NOT NULL,
[PaymentModeID] [tinyint] NOT NULL,
[PaymentToken] [nvarchar] (44) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_CustomerPayment_IsActive] DEFAULT ((0)),
[IsFirstPaymentDue] [bit] NOT NULL CONSTRAINT [DF_CustomerPayment_IsFirstPaymentDue] DEFAULT ((1)),
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPayment_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPayment_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CustomerPayment] ADD CONSTRAINT [PK_CustomerPayment] PRIMARY KEY CLUSTERED  ([CustomerPaymentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerPayment_CustomerID] ON [tescosubscription].[CustomerPayment] ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_CustomerPayment_PaymentToken] ON [tescosubscription].[CustomerPayment] ([PaymentToken]) ON [PRIMARY]
GO
