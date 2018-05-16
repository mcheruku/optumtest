CREATE TABLE [tescosubscription].[PackageErrorLog]
(
[PackageErrorLogID] [bigint] NOT NULL IDENTITY(1, 1),
[PackageExecutionHistoryID] [bigint] NOT NULL,
[ErrorID] [bigint] NULL,
[ErrorDescription] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[PackageErrorLog] ADD CONSTRAINT [PK_PackageErrorLog] PRIMARY KEY CLUSTERED  ([PackageErrorLogID] DESC) ON [PRIMARY]
GO
