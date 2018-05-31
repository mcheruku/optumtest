CREATE TABLE [Coupon].[CampaignAttributes]
(
[Campaign] [bigint] NOT NULL,
[Attribute] [smallint] NOT NULL,
[AttributeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CampaignAttributes_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CampaignAttributes_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CampaignAttributes] ADD CONSTRAINT [PK_CampaignAttributes] PRIMARY KEY CLUSTERED  ([CampaignID], [AttributeID]) ON [PRIMARY]
GO
