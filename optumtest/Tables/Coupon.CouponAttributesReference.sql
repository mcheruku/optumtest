CREATE TABLE [Coupon].[CouponAttributesReference]
(
[AttributeID] [smallint] NOT NULL,
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTCCreatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponAttributesReference_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [smalldatetime] NOT NULL CONSTRAINT [DF_CouponAttributesReference_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Coupon].[CouponAttributesReference] ADD CONSTRAINT [PK_CouponAttributesReference] PRIMARY KEY CLUSTERED  ([AttributeID]) ON [PRIMARY]
GO
