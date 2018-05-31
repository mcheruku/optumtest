CREATE TABLE [tescosubscription].[PaymentModeMaster]
(
[PaymentModeID] [tinyint] NOT NULL,
[PaymentModeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PaymentModeMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PaymentModeMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[PaymentModeMaster] ADD CONSTRAINT [PK_PaymentModeMaster] PRIMARY KEY CLUSTERED  ([PaymentModeID]) ON [PRIMARY]
GO
