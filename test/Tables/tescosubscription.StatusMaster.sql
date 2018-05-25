CREATE TABLE [tescosubscription].[StatusMaster]
(
[StatusId] [tinyint] NOT NULL,
[StatusCode] [tinyint] NOT NULL,
[StatusName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_StatusMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_StatusMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[StatusMaster] ADD CONSTRAINT [PK_StatusMaster] PRIMARY KEY CLUSTERED  ([StatusId]) ON [PRIMARY]
GO
