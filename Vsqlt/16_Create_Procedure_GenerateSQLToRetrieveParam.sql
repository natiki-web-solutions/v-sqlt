IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE object_id = OBJECT_ID(N'VsqltHelper.GenerateSQLToRetrieveParam'))
BEGIN
    DROP PROCEDURE [VsqltHelper].[GenerateSQLToRetrieveParam]
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [VsqltHelper].[GenerateSQLToRetrieveParam]
(
@selectSQLParam NVARCHAR(MAX) OUTPUT
)
AS   
BEGIN  
	
	IF OBJECT_ID('tempdb..#tmpSQLParamHelper') IS NOT NULL
	BEGIN
		DROP TABLE #tmpSQLParamHelper
	END
	
	SELECT 
    c.name 'ColumnName',
    t.Name 'Datatype'
	INTO #tmpSQLParamHelper
	FROM    
    tempdb.sys.columns c
	INNER JOIN 
    tempdb.sys.types t ON c.user_type_id = t.user_type_id
	LEFT OUTER JOIN 
    tempdb.sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
	LEFT OUTER JOIN 
    tempdb.sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
	WHERE c.object_id = OBJECT_ID('tempdb..#TestCases')
	AND c.name NOT IN ('ExpectedResult','ResultNumber','SQLForExpectedResult') 

	DECLARE @ctr INT = 0
	DECLARE @ColumnName NVARCHAR(100)
	DECLARE @Datatype NVARCHAR(100)

	SET @selectSQLParam = ''

	IF((SELECT COUNT(1) FROM #tmpSQLParamHelper) > 0) 
		BEGIN

			WHILE(SELECT COUNT(1) FROM #tmpSQLParamHelper) > 0
			BEGIN
				SELECT TOP 1 @ColumnName = ColumnName, @Datatype = Datatype FROM #tmpSQLParamHelper

				IF(@ColumnName NOT IN ('ExpectedResult','ResultNumber'))
					BEGIN
						IF(@ctr = 0)
							SET @selectSQLParam = @selectSQLParam + ' CONVERT(NVARCHAR(MAX),' + @ColumnName +  ') + ' + '''' + '|'  + @Datatype + ''
						ELSE
							SET @selectSQLParam = @selectSQLParam  + '*'''  +  ' + CONVERT(NVARCHAR(MAX),' + @ColumnName +  ') + ' + ''''  + '|'  + @Datatype  + ''
				
						SET @ctr = @ctr + 1			
					END
	
				DELETE TOP (1) FROM #tmpSQLParamHelper
			END
		END

	SET @selectSQLParam = @selectSQLParam + ''''

END