CREATE TABLE [Coupon].[Coupon]
(
[CouponID] [bigint] NOT NULL IDENTITY(1, 1),
[CouponCode] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescriptionShort] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DescriptionLong] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [money] NOT NULL,
[RedeemCount] [int] NOT NULL CONSTRAINT [DF_Coupon_RedeemCount] DEFAULT ((0)),
[IsActive] [bit] NOT NULL CONSTRAINT [DF_Coupon_IsActive] DEFAULT ((0)),
[UTCCreatedeDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_Coupon_UTCCreatedeDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_Coupon_UTCUpdatedDateTime] DEFAULT (getutcdate()),
[CampaignID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[Coupon] ADD CONSTRAINT [PK_Coupon] PRIMARY KEY CLUSTERED  ([CouponID]) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[Coupon] ADD CONSTRAINT [UQ_Coupon_CouponCode] UNIQUE NONCLUSTERED  ([CouponCode]) ON [PRIMARY]
GO
