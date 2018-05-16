CREATE TABLE [Coupon].[CouponCustomerMap]
(
[CouponID] [bigint] NOT NULL,
[CustomerID] [bigint] NOT NULL,
[UTCCreatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponCustomerMap_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponCustomerMap_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponCustomerMap] ADD CONSTRAINT [PK_CouponCustomerMap] PRIMARY KEY CLUSTERED  ([CouponID], [CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponCustomerMap] ADD CONSTRAINT [FK_CouponCustomerMap_Coupon_CouponID] FOREIGN KEY ([CouponID]) REFERENCES [Coupon].[Coupon] ([CouponID])
GO
