CREATE TABLE [Sales].[SpecialOffer_ondisk]
(
[SpecialOfferID] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DiscountPct] [smallmoney] NOT NULL CONSTRAINT [ODDF_SpecialOffer_DiscountPct] DEFAULT ((0.00)),
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime2] NOT NULL,
[EndDate] [datetime2] NOT NULL,
[MinQty] [int] NOT NULL CONSTRAINT [ODDF_SpecialOffer_MinQty] DEFAULT ((0)),
[MaxQty] [int] NULL,
[ModifiedDate] [datetime2] NOT NULL CONSTRAINT [ODDF_SpecialOffer_ModifiedDate] DEFAULT (sysdatetime())
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SpecialOffer_ondisk] ADD CONSTRAINT [ODCK_SpecialOffer_DiscountPct] CHECK (([DiscountPct]>=(0.00)))
GO
ALTER TABLE [Sales].[SpecialOffer_ondisk] ADD CONSTRAINT [ODCK_SpecialOffer_EndDate] CHECK (([EndDate]>=[StartDate]))
GO
ALTER TABLE [Sales].[SpecialOffer_ondisk] ADD CONSTRAINT [ODCK_SpecialOffer_MaxQty] CHECK (([MaxQty]>=(0)))
GO
ALTER TABLE [Sales].[SpecialOffer_ondisk] ADD CONSTRAINT [ODCK_SpecialOffer_MinQty] CHECK (([MinQty]>=(0)))
GO
ALTER TABLE [Sales].[SpecialOffer_ondisk] ADD CONSTRAINT [ODPK_SpecialOffer_SpecialOfferID] PRIMARY KEY CLUSTERED  ([SpecialOfferID]) ON [PRIMARY]
GO
