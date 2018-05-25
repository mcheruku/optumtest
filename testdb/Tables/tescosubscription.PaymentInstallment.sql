CREATE TABLE [tescosubscription].[PaymentInstallment]
(
[PaymentInstallmentID] [tinyint] NOT NULL,
[PaymentInstallmentName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InstallmentTenure] [tinyint] NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PaymentInstallment_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PaymentInstallment_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[PaymentInstallment] ADD CONSTRAINT [PK_PaymentInstallment] PRIMARY KEY CLUSTERED  ([PaymentInstallmentID]) ON [PRIMARY]
GO
