CREATE TABLE [HumanResources].[Employee_Temporal]
(
[BusinessEntityID] [int] NOT NULL,
[NationalIDNumber] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoginID] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrganizationNode] [sys].[hierarchyid] NULL,
[OrganizationLevel] AS ([OrganizationNode].[GetLevel]()),
[JobTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BirthDate] [date] NOT NULL,
[MaritalStatus] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HireDate] [date] NOT NULL,
[VacationHours] [smallint] NOT NULL,
[SickLeaveHours] [smallint] NOT NULL,
[ValidFrom] [datetime2] GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
[ValidTo] [datetime2] GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
CONSTRAINT [PK_Employee_History_BusinessEntityID] PRIMARY KEY CLUSTERED  ([BusinessEntityID]) ON [PRIMARY]
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [HumanResources].[Employee_Temporal_History])
)
GO
CREATE CLUSTERED INDEX [ix_Employee_Temporal_History] ON [HumanResources].[Employee_Temporal_History] ([BusinessEntityID], [ValidFrom], [ValidTo]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
