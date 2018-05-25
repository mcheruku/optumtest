CREATE TABLE [tescosubscription].[CustomerSubscriptionHistory]
(
[SubscriptionHistoryID] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerSubscriptionID] [bigint] NOT NULL,
[SubscriptionStatus] [tinyint] NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerSubscriptionHistory_UTCCreatedDateTime] DEFAULT (getutcdate()),
[Remarks] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CustomerSubscriptionHistory] ADD CONSTRAINT [PK_SubscriptionHistoryID] PRIMARY KEY CLUSTERED  ([SubscriptionHistoryID]) ON [PRIMARY]
GO
