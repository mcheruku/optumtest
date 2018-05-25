CREATE TABLE [Demo].[DemoSalesOrderHeaderSeed]
(
[DueDate] [datetime2] NOT NULL,
[CustomerID] [int] NOT NULL,
[SalesPersonID] [int] NOT NULL,
[BillToAddressID] [int] NOT NULL,
[ShipToAddressID] [int] NOT NULL,
[ShipMethodID] [int] NOT NULL,
[LocalID] [int] NOT NULL IDENTITY(1, 1),
CONSTRAINT [PK__DemoSale__499359DA31897820] PRIMARY KEY NONCLUSTERED  ([LocalID])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
