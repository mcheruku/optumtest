IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'SubsUser')
CREATE LOGIN [SubsUser] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [SubsUser] FOR LOGIN [SubsUser]
GO
