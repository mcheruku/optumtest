CREATE TABLE [tescosubscription].[SubscriptionPlanSlot]
(
[SubscriptionPlanID] [int] NOT NULL,
[DOW] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[SubscriptionPlanSlot] ADD CONSTRAINT [PK_SubscriptionPlanSlot_SubscriptionPlanID_DOW] PRIMARY KEY CLUSTERED  ([SubscriptionPlanID], [DOW]) ON [PRIMARY]
GO
