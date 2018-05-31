CREATE TABLE [tescosubscription].[BusinessMaster]
(
[BusinessID] [tinyint] NOT NULL,
[BusinessName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_BusinessMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_BusinessMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[BusinessMaster] ADD CONSTRAINT [PK_BusinessMaster] PRIMARY KEY CLUSTERED  ([BusinessID]) ON [PRIMARY]
GO
