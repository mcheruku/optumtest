SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConvertListToTable]
(
	@List NVARCHAR(MAX),
	@Delim NVARCHAR
)
RETURNS
	@ParsedList TABLE
	(
		Item NVARCHAR(44)
	)
AS
BEGIN
	DECLARE @item NVARCHAR(44), @Pos INT
	SET @List = LTRIM(RTRIM(@List))+ @Delim
	SET @Pos = CHARINDEX(@Delim, @List, 1)
	WHILE @Pos > 0
	BEGIN
		SET @item = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
		IF @item <> ''
		BEGIN
			INSERT INTO @ParsedList (Item)
			VALUES (CAST(@Item AS NVARCHAR(44)))
		END
		SET @List = RIGHT(@List, LEN(@List) - @Pos)
		SET @Pos = CHARINDEX(@Delim, @List, 1)
	END

	RETURN
END

GO
