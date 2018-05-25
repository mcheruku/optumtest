CREATE TABLE [Sales].[SalesOrderHeader_ondisk]
(
[SalesOrderID] [int] NOT NULL IDENTITY(1, 1),
[RevisionNumber] [tinyint] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_RevisionNumber] DEFAULT ((0)),
[OrderDate] [datetime2] NOT NULL,
[DueDate] [datetime2] NOT NULL,
[ShipDate] [datetime2] NULL,
[Status] [tinyint] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_Status] DEFAULT ((1)),
[OnlineOrderFlag] [bit] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_OnlineOrderFlag] DEFAULT ((1)),
[PurchaseOrderNumber] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNumber] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [int] NOT NULL,
[SalesPersonID] [int] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_SalesPersonID] DEFAULT ((-1)),
[TerritoryID] [int] NULL,
[BillToAddressID] [int] NOT NULL,
[ShipToAddressID] [int] NOT NULL,
[ShipMethodID] [int] NOT NULL,
[CreditCardID] [int] NULL,
[CreditCardApprovalCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyRateID] [int] NULL,
[SubTotal] [money] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_SubTotal] DEFAULT ((0.00)),
[TaxAmt] [money] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_TaxAmt] DEFAULT ((0.00)),
[Freight] [money] NOT NULL CONSTRAINT [ODDF_SalesOrderHeader_Freight] DEFAULT ((0.00)),
[Comment] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [ODCK_SalesOrderHeader_DueDate] CHECK (([DueDate]>=[OrderDate]))
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [ODCK_SalesOrderHeader_Freight] CHECK (([Freight]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [ODCK_SalesOrderHeader_ShipDate] CHECK (([ShipDate]>=[OrderDate] OR [ShipDate] IS NULL))
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [ODCK_SalesOrderHeader_Status] CHECK (([Status]>=(0) AND [Status]<=(8)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [ODCK_SalesOrderHeader_SubTotal] CHECK (([SubTotal]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [ODCK_SalesOrderHeader_TaxAmt] CHECK (([TaxAmt]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_ondisk] ADD CONSTRAINT [PK__SalesOrd__B14003C2B181FB70] PRIMARY KEY CLUSTERED  ([SalesOrderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerID] ON [Sales].[SalesOrderHeader_ondisk] ([CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SalesPersonID] ON [Sales].[SalesOrderHeader_ondisk] ([SalesPersonID]) ON [PRIMARY]
GO
