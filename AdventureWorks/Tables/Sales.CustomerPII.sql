CREATE TABLE [Sales].[CustomerPII]
(
[CustomerID] [int] NOT NULL,
[FirstName] [dbo].[Name] NOT NULL,
[LastName] [dbo].[Name] NOT NULL,
[SSN] [nvarchar] (11) COLLATE Latin1_General_BIN2 NULL,
[CreditCardNumber] [nvarchar] (25) COLLATE Latin1_General_BIN2 NULL,
[EmailAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS MASKED WITH (FUNCTION = 'email()') NULL,
[PhoneNumber] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS MASKED WITH (FUNCTION = 'default()') NULL,
[TerritoryID] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [Sales].[CustomerPII] TO [SalesManagers]
GO
GRANT INSERT ON  [Sales].[CustomerPII] TO [SalesManagers]
GO
GRANT SELECT ON  [Sales].[CustomerPII] TO [SalesManagers]
GO
GRANT UPDATE ON  [Sales].[CustomerPII] TO [SalesManagers]
GO
GRANT DELETE ON  [Sales].[CustomerPII] TO [SalesPersons]
GO
GRANT INSERT ON  [Sales].[CustomerPII] TO [SalesPersons]
GO
GRANT SELECT ON  [Sales].[CustomerPII] TO [SalesPersons]
GO
GRANT UPDATE ON  [Sales].[CustomerPII] TO [SalesPersons]
GO
