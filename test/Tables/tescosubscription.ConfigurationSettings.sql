CREATE TABLE [tescosubscription].[ConfigurationSettings]
(
[SettingName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SettingValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PersonalizedSavingsConfig_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_PersonalizedSavingsConfig_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[ConfigurationSettings] ADD CONSTRAINT [PK_SettingName] PRIMARY KEY CLUSTERED  ([SettingName]) ON [PRIMARY]
GO
