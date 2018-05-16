CREATE TABLE [Coupon].[CouponUsageType]
(
[UsageTypeID] [tinyint] NOT NULL,
[UsageName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CouponUsageType_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CouponUsageType_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponUsageType] ADD CONSTRAINT [PK_CouponUsageType] PRIMARY KEY CLUSTERED  ([UsageTypeID]) ON [PRIMARY]
GO
