CREATE TABLE [tescosubscription].[PackageExecutionHistory]
(
[PackageExecutionHistoryID] [bigint] NOT NULL IDENTITY(1, 1),
[PackageID] [smallint] NOT NULL,
[PackageStartTime] [datetime] NOT NULL,
[PackageEndTime] [datetime] NULL,
[statusID] [tinyint] NOT NULL CONSTRAINT [DF__PackageEx__statu__14270015] DEFAULT ((12))
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[PackageExecutionHistory] ADD CONSTRAINT [PK_PackageExecutionHistory] PRIMARY KEY CLUSTERED  ([PackageExecutionHistoryID] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_PackageExecutionHistory_PackageStartTime] ON [tescosubscription].[PackageExecutionHistory] ([PackageStartTime]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
