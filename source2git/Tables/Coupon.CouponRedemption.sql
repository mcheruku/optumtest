CREATE TABLE [Coupon].[CouponRedemption]
(
[CouponCode] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerID] [bigint] NOT NULL,
[UTCCreatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponRedemption_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponRedemption_UTCUpdatedDateTime] DEFAULT (getutcdate()),
[Ro_No] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponRedemption] ADD CONSTRAINT [PK_Coupon_CouponRedemption_Ro_No] PRIMARY KEY NONCLUSTERED  ([Ro_No]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CI_CouponRedemption_CustomerID_CouponCode] ON [Coupon].[CouponRedemption] ([CustomerID], [CouponCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponRedemption] ADD CONSTRAINT [FK_CouponRedemption_Coupon] FOREIGN KEY ([CouponCode]) REFERENCES [Coupon].[Coupon] ([CouponCode])
GO
