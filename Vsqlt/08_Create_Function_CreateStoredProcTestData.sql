IF EXISTS (SELECT 1
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[VsqltHelper].[CreateStoredProcTestData]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [VsqltHelper].[CreateStoredProcTestData]

GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [VsqltHelper].[CreateStoredProcTestData](@testCaseKey NVARCHAR(MAX),@testCaseName NVARCHAR(MAX),@objectToTest NVARCHAR(MAX), @sqlSPToTest NVARCHAR(MAX),@resultNo NVARCHAR(3),@createExpectedData bit,@tblMD5Hash NVARCHAR(MAX),@definedExpectedResult XML)  
RETURNS NVARCHAR(MAX) 
AS   
-- Returns a string that can be executed to populate the assert table with expected data in xml format.
BEGIN  
	
	DECLARE @execSPViatSQLtResultSetFilter NVARCHAR(MAX)
	DECLARE @generateXML NVARCHAR(MAX)
	DECLARE @retValue NVARCHAR(MAX)
	DECLARE @ExecutionLog NVARCHAR(MAX)
	DECLARE @formattedSqlSPToTest NVARCHAR(MAX) = (SELECT REPLACE(@sqlSPToTest,'''',''''''))

	--Do below if defined expected result is supplied
	IF(@definedExpectedResult IS NOT NULL)
		BEGIN
			SET @ExecutionLog = 'IF NOT EXISTS(SELECT 1 FROM [Vsqlt].[TempExecutionLog] WHERE TestCaseKey = ''' + @testCaseKey + ''') INSERT [Vsqlt].[TempExecutionLog] (TestCaseName,TestCaseKey,ObjectToTest,ExecSPWithParam,ResultNo,ExpectedTableHash,ExpectedResult) VALUES (''' + @testCaseName + ''',''' + @testCaseKey + ''',''' + @objectToTest + ''',''' + @formattedSqlSPToTest + ''',''' + @resultNo + ''',''' + @tblMD5Hash + ''',''' + CONVERT(NVARCHAR(MAX),@definedExpectedResult) + ''') ELSE UPDATE [Vsqlt].[TempExecutionLog] SET ExpectedResult = ''' + CONVERT(NVARCHAR(MAX),@definedExpectedResult) + ''', ObjectToTest = ''' + @objectToTest + ''', ExecSPWithParam = ''' + @formattedSqlSPToTest + '''  WHERE TestCaseKey = ''' + @testCaseKey + '''' 
			SET @retValue = @ExecutionLog
		END
	ELSE
		BEGIN
			--Generate Expected Result
			SET @execSPViatSQLtResultSetFilter = @sqlSPToTest

			--Store the result in varchar datatype but xml format
			--SET @generateXML = 'declare @results NVARCHAR(max) set @results = (select * from #TestResult Order by 1 for XML RAW)'
			SET @generateXML = 'declare @results NVARCHAR(max) set @results = (select * from #TestResult for XML RAW)'

			--Insert the expected result to the table to be used for assert. This will be created only on the first run and will not be executed in the succeeding run
			IF(@createExpectedData = 1) -- Operation is to create expected data
				SET @ExecutionLog = 'IF NOT EXISTS(SELECT 2 FROM [Vsqlt].[TempExecutionLog] WHERE TestCaseKey = ''' + @testCaseKey + ''') INSERT [Vsqlt].[TempExecutionLog] (TestCaseName,TestCaseKey,ObjectToTest,ExecSPWithParam,ResultNo,ExpectedTableHash,ExpectedResult,ActualResult) VALUES (''' + @testCaseName + ''',''' + @testCaseKey + ''',''' + @objectToTest + ''',''' + @formattedSqlSPToTest + ''',''' + @resultNo + ''',''' + @tblMD5Hash + ''',@results,'''') ELSE UPDATE [Vsqlt].[TempExecutionLog] SET ExpectedResult = @results, ExpectedTableHash = ''' + @tblMD5Hash + ''', ObjectToTest = ''' + @objectToTest + ''', ExecSPWithParam = ''' + @formattedSqlSPToTest + '''  WHERE ExpectedResult IS NULL AND TestCaseKey = ''' + @testCaseKey + '''' 
			ELSE -- Operation is to create actual data
				SET @ExecutionLog = 'IF NOT EXISTS(SELECT 3 FROM [Vsqlt].[TempExecutionLog] WHERE TestCaseKey = ''' + @testCaseKey + ''') INSERT [Vsqlt].[TempExecutionLog] (TestCaseName,TestCaseKey,ObjectToTest,ExecSPWithParam,ResultNo,ActualTableHash,ActualResult) VALUES (''' + @testCaseName + ''',''' + @testCaseKey + ''',''' + @objectToTest + ''',''' + @formattedSqlSPToTest + ''',''' + @resultNo + ''',''' + @tblMD5Hash + ''',@results' + ') ELSE UPDATE [Vsqlt].[TempExecutionLog] SET ActualResult = @results, ActualTableHash = ''' + @tblMD5Hash + '''  WHERE TestCaseKey = ''' + @testCaseKey + '''' 

			SET @retValue = @execSPViatSQLtResultSetFilter + ' ' + @generateXML + ' ' + @ExecutionLog
		END

	RETURN @retValue

END


