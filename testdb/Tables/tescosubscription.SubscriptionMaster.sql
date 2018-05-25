CREATE TABLE [tescosubscription].[SubscriptionMaster]
(
[SubscriptionID] [tinyint] NOT NULL,
[SubscriptionName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_SubscriptionMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_SubscriptionMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[SubscriptionMaster] ADD CONSTRAINT [PK_subscription.SubscriptionMaster] PRIMARY KEY CLUSTERED  ([SubscriptionID]) ON [PRIMARY]
GO
