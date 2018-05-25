CREATE TABLE [Production].[Product_inmem]
(
[ProductID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductNumber] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MakeFlag] [bit] NOT NULL CONSTRAINT [IMDF_Product_MakeFlag] DEFAULT ((1)),
[FinishedGoodsFlag] [bit] NOT NULL CONSTRAINT [IMDF_Product_FinishedGoodsFlag] DEFAULT ((1)),
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
[ModifiedDate] [datetime2] NOT NULL CONSTRAINT [IMDF_Product_ModifiedDate] DEFAULT (sysdatetime()),
CONSTRAINT [IMPK_Product_ProductID] PRIMARY KEY NONCLUSTERED HASH  ([ProductID]) WITH (BUCKET_COUNT=1048576),
INDEX [IX_Name] NONCLUSTERED ([Name]),
INDEX [IX_ProductNumber] NONCLUSTERED ([ProductNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_Class] CHECK (([Class]='H' OR [Class]='h' OR [Class]='M' OR [Class]='m' OR [Class]='L' OR [Class]='l' OR [Class] IS NULL))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_DaysToManufacture] CHECK (([DaysToManufacture]>=(0)))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_ListPrice] CHECK (([ListPrice]>=(0.00)))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_ProductLine] CHECK (([ProductLine]='R' OR [ProductLine]='r' OR [ProductLine]='M' OR [ProductLine]='m' OR [ProductLine]='T' OR [ProductLine]='t' OR [ProductLine]='S' OR [ProductLine]='s' OR [ProductLine] IS NULL))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_ReorderPoint] CHECK (([ReorderPoint]>(0)))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_SafetyStockLevel] CHECK (([SafetyStockLevel]>(0)))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_SellEndDate] CHECK (([SellEndDate]>=[SellStartDate] OR [SellEndDate] IS NULL))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_StandardCost] CHECK (([StandardCost]>=(0.00)))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_Style] CHECK (([Style]='U' OR [Style]='u' OR [Style]='M' OR [Style]='m' OR [Style]='W' OR [Style]='w' OR [Style] IS NULL))
GO
ALTER TABLE [Production].[Product_inmem] ADD CONSTRAINT [IMCK_Product_Weight] CHECK (([Weight]>(0.00)))
GO
