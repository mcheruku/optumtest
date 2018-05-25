CREATE TABLE [dbo].[Tblperson]
(
[ID] [int] NOT NULL,
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Email] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tblperson] ADD CONSTRAINT [PK_Tblperson] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tblperson] ADD CONSTRAINT [tblperson_GenderId] FOREIGN KEY ([GenderId]) REFERENCES [dbo].[TblGender] ([ID])
GO
