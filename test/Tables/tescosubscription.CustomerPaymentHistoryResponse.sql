CREATE TABLE [tescosubscription].[CustomerPaymentHistoryResponse]
(
[CustomerPaymentHistoryResponseID] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerPaymentHistoryID] [bigint] NOT NULL,
[PaymentStatusID] [tinyint] NOT NULL,
[Remarks] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerPaymentHistoryResponse_UTCCreatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CustomerPaymentHistoryResponse] ADD CONSTRAINT [PK_CustomerPaymentHistoryResponse] PRIMARY KEY CLUSTERED  ([CustomerPaymentHistoryResponseID]) ON [PRIMARY]
GO
