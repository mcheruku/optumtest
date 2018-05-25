CREATE TABLE [tescosubscription].[CustomerSubscriptionSwitchHistory]
(
[CustomerSubscriptionID] [bigint] NOT NULL,
[SwitchTo] [int] NULL,
[SwitchStatus] [tinyint] NOT NULL,
[SwitchOrigin] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTCRequestedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CustomerSubscriptionSwitchHistory_UTCRequestedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CI_CustomerSubscriptionSwitchHistory_CustomerSubscriptionID] ON [tescosubscription].[CustomerSubscriptionSwitchHistory] ([CustomerSubscriptionID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
