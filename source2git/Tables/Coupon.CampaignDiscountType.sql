CREATE TABLE [Coupon].[CampaignDiscountType]
(
[CampaignID] [bigint] NOT NULL,
[DiscountTypeID] [tinyint] NOT NULL,
[DiscountValue] [decimal] (6, 2) NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CampaignDiscountType_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CampaignDiscountType_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CampaignDiscountType] ADD CONSTRAINT [PK_CampaignDiscountType_CampaignID_DiscountTypeID] PRIMARY KEY CLUSTERED  ([CampaignID], [DiscountTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CampaignDiscountType] ADD CONSTRAINT [FK_CampaignDiscountType_DiscountTypeMaster] FOREIGN KEY ([DiscountTypeID]) REFERENCES [Coupon].[DiscountTypeMaster] ([DiscountTypeId])
GO
