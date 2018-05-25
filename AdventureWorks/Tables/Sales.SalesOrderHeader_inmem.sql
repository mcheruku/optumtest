CREATE TABLE [Sales].[SalesOrderHeader_inmem]
(
[SalesOrderID] [int] NOT NULL IDENTITY(1, 1),
[RevisionNumber] [tinyint] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_RevisionNumber] DEFAULT ((0)),
[OrderDate] [datetime2] NOT NULL,
[DueDate] [datetime2] NOT NULL,
[ShipDate] [datetime2] NULL,
[Status] [tinyint] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_Status] DEFAULT ((1)),
[OnlineOrderFlag] [bit] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_OnlineOrderFlag] DEFAULT ((1)),
[PurchaseOrderNumber] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNumber] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [int] NOT NULL,
[SalesPersonID] [int] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_SalesPersonID] DEFAULT ((-1)),
[TerritoryID] [int] NULL,
[BillToAddressID] [int] NOT NULL,
[ShipToAddressID] [int] NOT NULL,
[ShipMethodID] [int] NOT NULL,
[CreditCardID] [int] NULL,
[CreditCardApprovalCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyRateID] [int] NULL,
[SubTotal] [money] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_SubTotal] DEFAULT ((0.00)),
[TaxAmt] [money] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_TaxAmt] DEFAULT ((0.00)),
[Freight] [money] NOT NULL CONSTRAINT [IMDF_SalesOrderHeader_Freight] DEFAULT ((0.00)),
[Comment] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime2] NOT NULL,
CONSTRAINT [PK__SalesOrd__B14003C3270C320B] PRIMARY KEY NONCLUSTERED HASH  ([SalesOrderID]) WITH (BUCKET_COUNT=16777216),
INDEX [IX_CustomerID] NONCLUSTERED HASH ([CustomerID]) WITH (BUCKET_COUNT=1048576),
INDEX [IX_SalesPersonID] NONCLUSTERED HASH ([SalesPersonID]) WITH (BUCKET_COUNT=1048576)
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [Sales].[SalesOrderHeader_inmem] ADD CONSTRAINT [IMCK_SalesOrderHeader_DueDate] CHECK (([DueDate]>=[OrderDate]))
GO
ALTER TABLE [Sales].[SalesOrderHeader_inmem] ADD CONSTRAINT [IMCK_SalesOrderHeader_Freight] CHECK (([Freight]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_inmem] ADD CONSTRAINT [IMCK_SalesOrderHeader_ShipDate] CHECK (([ShipDate]>=[OrderDate] OR [ShipDate] IS NULL))
GO
ALTER TABLE [Sales].[SalesOrderHeader_inmem] ADD CONSTRAINT [IMCK_SalesOrderHeader_Status] CHECK (([Status]>=(0) AND [Status]<=(8)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_inmem] ADD CONSTRAINT [IMCK_SalesOrderHeader_SubTotal] CHECK (([SubTotal]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesOrderHeader_inmem] ADD CONSTRAINT [IMCK_SalesOrderHeader_TaxAmt] CHECK (([TaxAmt]>=(0.00)))
GO
