CREATE TABLE [tescosubscription].[PackageMaster]
(
[PackageID] [smallint] NOT NULL,
[PackageName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackageDescription] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PackageMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PackageMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[PackageMaster] ADD CONSTRAINT [PK_PackageMaster] PRIMARY KEY CLUSTERED  ([PackageID] DESC) ON [PRIMARY]
GO
