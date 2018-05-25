CREATE TABLE [Production].[Product_ondisk]
(
[ProductID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductNumber] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MakeFlag] [bit] NOT NULL CONSTRAINT [ODDF_Product_MakeFlag] DEFAULT ((1)),
[FinishedGoodsFlag] [bit] NOT NULL CONSTRAINT [ODDF_Product_FinishedGoodsFlag] DEFAULT ((1)),
[Color] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyStockLevel] [smallint] NOT NULL,
[ReorderPoint] [smallint] NOT NULL,
[StandardCost] [money] NOT NULL,
[ListPrice] [money] NOT NULL,
[Size] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SizeUnitMeasureCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeightUnitMeasureCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (8, 2) NULL,
[DaysToManufacture] [int] NOT NULL,
[ProductLine] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Class] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Style] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductSubcategoryID] [int] NULL,
[ProductModelID] [int] NULL,
[SellStartDate] [datetime2] NOT NULL,
[SellEndDate] [datetime2] NULL,
[DiscontinuedDate] [datetime2] NULL,
[ModifiedDate] [datetime2] NOT NULL CONSTRAINT [ODDF_Product_ModifiedDate] DEFAULT (sysdatetime())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_DaysToManufacture] CHECK (([DaysToManufacture]>=(0)))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_ListPrice] CHECK (([ListPrice]>=(0.00)))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_ReorderPoint] CHECK (([ReorderPoint]>(0)))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_SafetyStockLevel] CHECK (([SafetyStockLevel]>(0)))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_SellEndDate] CHECK (([SellEndDate]>=[SellStartDate] OR [SellEndDate] IS NULL))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_StandardCost] CHECK (([StandardCost]>=(0.00)))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_Weight] CHECK (([Weight]>(0.00)))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_Class] CHECK ((upper([Class])='H' OR upper([Class])='M' OR upper([Class])='L' OR [Class] IS NULL))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_ProductLine] CHECK ((upper([ProductLine])='R' OR upper([ProductLine])='M' OR upper([ProductLine])='T' OR upper([ProductLine])='S' OR [ProductLine] IS NULL))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODCK_Product_Style] CHECK ((upper([Style])='U' OR upper([Style])='M' OR upper([Style])='W' OR [Style] IS NULL))
GO
ALTER TABLE [Production].[Product_ondisk] ADD CONSTRAINT [ODPK_Product_ProductID] PRIMARY KEY CLUSTERED  ([ProductID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Name] ON [Production].[Product_ondisk] ([Name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductNumber] ON [Production].[Product_ondisk] ([ProductNumber]) ON [PRIMARY]
GO
