CREATE TABLE [tescosubscription].[ChannelMaster]
(
[ChannelID] [tinyint] NOT NULL,
[ChannelName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_ChannelMaster_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_ChannelMaster_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[ChannelMaster] ADD CONSTRAINT [PK_ChannelMaster] PRIMARY KEY CLUSTERED  ([ChannelID]) ON [PRIMARY]
GO
