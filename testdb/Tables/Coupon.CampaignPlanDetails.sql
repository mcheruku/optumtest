CREATE TABLE [Coupon].[CampaignPlanDetails]
(
[CampaignID] [bigint] NOT NULL,
[SubscriptionPlanID] [int] NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CampaignPlanDetails_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CampaignPlanDetails_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CampaignPlanDetails] ADD CONSTRAINT [PK_CampaignPlanDetails_CampaignID_SubscriptionPlanID] PRIMARY KEY CLUSTERED  ([CampaignID], [SubscriptionPlanID]) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CampaignPlanDetails] ADD CONSTRAINT [FK_CampaignPlanDetails_SubscriptionPlan] FOREIGN KEY ([SubscriptionPlanID]) REFERENCES [tescosubscription].[SubscriptionPlan] ([SubscriptionPlanID])
GO
