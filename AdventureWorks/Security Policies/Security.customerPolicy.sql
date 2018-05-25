CREATE SECURITY POLICY [Security].[customerPolicy]
ADD FILTER PREDICATE [Security].[customerAccessPredicate]([TerritoryID])
ON [Sales].[CustomerPII],
ADD BLOCK PREDICATE [Security].[customerAccessPredicate]([TerritoryID])
ON [Sales].[CustomerPII] 
WITH (STATE = ON)

GO
