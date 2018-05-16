CREATE TABLE [Coupon].[DiscountTypeMaster]
(
[DiscountTypeId] [tinyint] NOT NULL,
[DiscountName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_DiscountTypeMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_DiscountTypeMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[DiscountTypeMaster] ADD CONSTRAINT [PK_CouponDiscountType] PRIMARY KEY CLUSTERED  ([DiscountTypeId]) ON [PRIMARY]
GO
