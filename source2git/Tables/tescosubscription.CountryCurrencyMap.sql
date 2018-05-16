CREATE TABLE [tescosubscription].[CountryCurrencyMap]
(
[CountryCurrencyID] [tinyint] NOT NULL,
[CountryCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryCurrency] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyDesc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CountryCurrencyMap_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_CountryCurrencyMap_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CountryCurrencyMap] ADD CONSTRAINT [PK_CountryMaster] PRIMARY KEY CLUSTERED  ([CountryCurrencyID]) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[CountryCurrencyMap] ADD CONSTRAINT [UK_CountryMaster] UNIQUE NONCLUSTERED  ([CountryCode], [CountryCurrency]) ON [PRIMARY]
GO
