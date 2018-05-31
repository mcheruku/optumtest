CREATE TABLE [Coupon].[CampaignTypeMaster]
(
[CampaignTypeID] [int] NOT NULL IDENTITY(1, 1),
[CampaignTypeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_CampaignTypeMaster_IsActive] DEFAULT ((0)),
[UTCCreatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CampaignTypeMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CampaignTypeMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CampaignTypeMaster] ADD CONSTRAINT [PK_CampaignTypeMaster] PRIMARY KEY CLUSTERED  ([CampaignTypeID]) ON [PRIMARY]
GO
