CREATE TABLE [Coupon].[CouponAttributes]
(
[CouponID] [bigint] NOT NULL,
[AttributeID] [smallint] NOT NULL,
[AttributeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponAttributes_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponAttributes_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponAttributes] ADD CONSTRAINT [PK_CouponAttributes] PRIMARY KEY CLUSTERED  ([CouponID], [AttributeID]) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponAttributes] ADD CONSTRAINT [FK_CouponAttributes_Coupon] FOREIGN KEY ([CouponID]) REFERENCES [Coupon].[Coupon] ([CouponID])
GO
