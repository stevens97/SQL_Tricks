/*
SQL - Data Mining Script
Based on original thread: https://stackoverflow.com/questions/11675669/searching-for-a-specific-id-in-a-large-database

Automatically searches for the relevant tables/columns containing a specific keyword in your database.

Remember to check the messages Tab on SQL Server to see the output.
The output will provide you with the relevant SQL query to run to find your keyword.

*/

/*Initiate Variables*/
SET NOCOUNT ON
DECLARE @keyword varchar(128), @objectOwner varchar(64)
SET @keyword = '%keyword%' -- Keyword to search for within the database
SET @objectOwner = 'dbo'

DECLARE @potentialcolumns TABLE (id int IDENTITY, sql varchar(4000))

INSERT INTO @potentialcolumns (sql)
SELECT 
    ('if exists (select 1 from [' +
    [tabs].[table_schema] + '].[' +
    [tabs].[table_name] + 
    '] (NOLOCK) where [' + 
    [cols].[column_name] + 
    '] like ''' + @keyword + ''' ) print ''SELECT * FROM [' +
    [tabs].[table_schema] + '].[' +
    [tabs].[table_name] + 
    '] (NOLOCK) WHERE [' + 
    [cols].[column_name] + 
    '] LIKE ''''' + @keyword + '''''' +
    '''') as 'sql'
/*Select all relevant information from the database information schema.*/
FROM information_schema.columns cols
    INNER JOIN information_schema.tables tabs
        ON cols.TABLE_CATALOG = tabs.TABLE_CATALOG
            AND cols.TABLE_SCHEMA = tabs.TABLE_SCHEMA
            AND cols.TABLE_NAME = tabs.TABLE_NAME
/*Declare the possible variable types the Keyword could be.*/
WHERE cols.data_type IN ('char', 'varchar', 'nvchar', 'nvarchar','text','ntext', 'uniqueidentifier')
    AND tabs.table_schema = @objectOwner
    AND tabs.TABLE_TYPE = 'BASE TABLE'
    AND (cols.CHARACTER_MAXIMUM_LENGTH >= (LEN(@keyword) - 2) OR cols.CHARACTER_MAXIMUM_LENGTH = -1)
ORDER BY tabs.table_catalog, tabs.table_name, cols.ordinal_position
/*Find the potential columns containing the keyword.*/
DECLARE @count int
SET @count = (SELECT MAX(id) FROM @potentialcolumns)
PRINT 'Found ' + CAST(@count as varchar) + ' potential columns.'
PRINT 'Beginning search...'
PRINT ''
PRINT 'These columns contain the values being searched for...'
PRINT ''

/*SQL output in Messages.*/
DECLARE @iterator int, @sql varchar(4000)
SET @iterator = 1
WHILE @iterator <= (SELECT Max(id) FROM @potentialcolumns)
BEGIN
    SET @sql = (SELECT [sql] FROM @potentialcolumns where [id] = @iterator)
    IF (@sql IS NOT NULL) and (RTRIM(LTRIM(@sql)) <> '')
    BEGIN
        --SELECT @sql --use when checking sql output
        EXEC (@sql)
    END
    SET @iterator = @iterator + 1
END
PRINT ''
PRINT 'Search completed'
