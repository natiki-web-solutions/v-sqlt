IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE object_id = OBJECT_ID(N'VsqltHelper.DoDMLProcTest'))
BEGIN
    DROP PROCEDURE [VsqltHelper].[DoDMLProcTest]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [VsqltHelper].[DoDMLProcTest]
(
@ATargetDatabaseName NVARCHAR(100),
@ASPFunctionName NVARCHAR(100),
@ATestCaseName NVARCHAR(100)
)
AS
BEGIN

SET NOCOUNT ON

DECLARE	@generatedSQL NVARCHAR(MAX),
        @CreateExpectedData BIT, -- 1 = Generate Expected data, 2 = Generate Actual data
		@ExpectedResult NVARCHAR(MAX),
		@ActualResult NVARCHAR(MAX),
		@TestCaseKey NVARCHAR(100),
		@sequenceNo INT = 0,
		@ExpectedTableHash VARCHAR(200),
		@ActualTableHash VARCHAR(200),
		@ResultNo NVARCHAR(3),
		@DefinedExpectedResult XML,
		@ErrNo INT = 0

BEGIN TRY

	IF OBJECT_ID('tempdb..#SQLAndParam') IS NOT NULL
	BEGIN
		DROP TABLE #SQLAndParam
	END

	CREATE TABLE #SQLAndParam
	(
	SPFunctionName NVARCHAR(1000) NOT NULL,
	TestParameters NVARCHAR(MAX) NOT NULL,
	SQLForExpectedResult NVARCHAR(MAX) NOT NULL, --This should contain the select statement neccessary to generate the result of SP with DML operation
	ExpectedResult XML NULL
	)


	--Table Value variable that will hold the content of [Vsqlt].[TempExecutionLog]. This will be the source of the actual test log while content of [Vsqlt].[TempExecutionLog]
	--will be rolledback along with the execution of the sp to be tested so that there will be no harm than or changes made to the datababase while executing
	--sp or function to be tested.
	DECLARE @ExecutionLog TABLE
	(
	[TestCaseKey] [nvarchar](max) NULL,
	[TestCaseName] [nvarchar](max) NULL,
	[ExecSPWithParam] [nvarchar](max) NOT NULL,
	[ResultNo] [nvarchar](3) NULL,
	[ExpectedTableHash] [nvarchar](max) NULL,
	[ActualTableHash] [nvarchar](max) NULL,
	[ExpectedResult] [xml] NULL,
	[ActualResult] [xml] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Status] [nvarchar](10) NULL,
	[ErrorMessage] [nvarchar](max) NULL
	)

	DECLARE @selectSQLParam NVARCHAR(MAX)
	EXEC [VsqltHelper].[GenerateSQLToRetrieveParam] @selectSQLParam OUTPUT

	DECLARE @testData NVARCHAR(MAX) 
	
	IF(@selectSQLParam = '')
		SET @testData = 'INSERT #SQLAndParam SELECT ''' + @ASPFunctionName + ''','''',SQLForExpectedResult,ExpectedResult FROM #TestCases'	
	ELSE
		SET @testData = 'INSERT #SQLAndParam SELECT ''' + @ASPFunctionName + ''', ' + @selectSQLParam + ',SQLForExpectedResult,ExpectedResult FROM #TestCases'
	
	EXEC(@testData)

	DECLARE @spFunctionSQL NVARCHAR(MAX),
	        @tblMD5Hash NVARCHAR(MAX),
			@ObjectType NVARCHAR(30),
			@errorMessage NVARCHAR(1000),
			@procOperation BIT = 1

	--Generate hash based on result table definition
	EXEC [VsqltHelper].[GenerateTableHash] @tblMD5Hash OUTPUT

	WHILE(SELECT COUNT(1) FROM #SQLAndParam) > 0
		BEGIN
			
			SET @sequenceNo= @sequenceNo + 1
			SET @TestCaseKey = @ATestCaseName + '[' + CONVERT(NVARCHAR(30),@sequenceNo) + ']'

			SELECT TOP 1 
					@DefinedExpectedResult = ExpectedResult
			FROM #SQLAndParam

			EXEC [VsqltHelper].[DetermineObjectType] @ATargetDatabaseName,@ASPFunctionName,@ObjectType OUTPUT
			
			--Generate SQL based on @IsTestForSP. 1 = We are testing SP, 0 = We are testing Function
			IF(@ObjectType = 'STORED_PROCEDURE')
				BEGIN

					SET @spFunctionSQL = (SELECT TOP 1 'EXEC(' + '''' + SPFunctionName + ' ' +  [VsqltHelper].[GenerateNonXMLParam](TestParameters,@procOperation) + '''' +  ') INSERT into #TestResult ' +  SQLForExpectedResult + ' declare @results NVARCHAR(max) set @results = (select * from #TestResult for XML RAW)' FROM #SQLAndParam)					

					BEGIN TRAN OZTEST1 --Checkpoint to start transaction so that all operation below can be rollback after test execution
				
						--Execute creation of Expected Data
						SET @CreateExpectedData = 1
						TRUNCATE TABLE #TestResult --Cleanup temp table that holds data to be converted to xml
						SET @generatedSQL = [VsqltHelper].[CreateStoredProcWithDMLTestData](@TestCaseKey,@ATestCaseName,@spFunctionSQL,@CreateExpectedData,@tblMD5Hash,@DefinedExpectedResult) 
						--SELECT @generatedSQL,'@generatedSQL1'
						EXEC(@generatedSQL)

						--Execute creation of Actual Data
						SET @CreateExpectedData = 0
						TRUNCATE TABLE #TestResult --Cleanup temp table that holds data to be converted to xml
						SET @generatedSQL = [VsqltHelper].[CreateStoredProcWithDMLTestData](@TestCaseKey,@ATestCaseName,@spFunctionSQL,@CreateExpectedData,@tblMD5Hash,NULL)  
						UPDATE [Vsqlt].[TempExecutionLog] SET StartDate=SYSUTCDATETIME() WHERE TestCaseKey = @TestCaseKey --Update the start date
						--SELECT @generatedSQL,'@generatedSQL2'
						EXEC(@generatedSQL)
						UPDATE [Vsqlt].[TempExecutionLog] SET EndDate=SYSUTCDATETIME() WHERE TestCaseKey = @TestCaseKey --Update the end date
			
						--Call the SP helper that will do the actual assert
						EXEC [VsqltHelper].[PerformAssert] @ASPFunctionName,@ATestCaseName,@TestCaseKey,Null

						--Insert the content of temp table to the table variable so that changes will not be lost when we do rollback
						INSERT @ExecutionLog (TestCaseKey,TestCaseName,ExecSPWithParam,ResultNo,ExpectedTableHash,ActualTableHash,ExpectedResult,ActualResult,StartDate,EndDate,Status,ErrorMessage) SELECT TestCaseKey,TestCaseName,ExecSPWithParam,ResultNo,ExpectedTableHash,ActualTableHash,ExpectedResult,ActualResult,StartDate,EndDate,Status,ErrorMessage FROM [Vsqlt].[TempExecutionLog]

						ROLLBACK TRAN OZTEST1 --This is to rollback all operations above which include execution of the sp to be tested so that no changes will be done to the table affected by sp run.
					END
				ELSE --If object supplied to be tested is not catered for testing
					BEGIN
						IF(@ObjectType = 'OTHER_OBJECTS')
							SET @errorMessage = 'Object to be tested is not yet catered by this framework. Please inform the administrator.'

						IF(@ObjectType = 'NOT_EXIST')
							SET @errorMessage = 'Object to be tested does not exist.'

						EXEC [VsqltHelper].[CreateRunLog] @TestCaseKey,@ATestCaseName,@ASPFunctionName,Null,'ERROR',@errorMessage

					END

			

			DELETE TOP(1) FROM #SQLAndParam		
		END


		--Now that we have the result of the test to a table variable after we rollback the changes made by the actual execution of the test, we can
		--now store it in the actual table log.
		INSERT Vsqlt.ExecutionLog (TestCaseKey,TestCaseName,ExecSPWithParam,ResultNo,ExpectedTableHash,ActualTableHash,ExpectedResult,ActualResult,StartDate,EndDate,Status,ErrorMessage)
		SELECT TestCaseKey,TestCaseName,ExecSPWithParam,ResultNo,ExpectedTableHash,ActualTableHash,ExpectedResult,ActualResult,StartDate,EndDate,Status,ErrorMessage 
		FROM @ExecutionLog varE WHERE NOT EXISTS
		(
		SELECT 1 FROM Vsqlt.ExecutionLog el WHERE el.TestCaseKey = varE.TestCaseKey
		)

		UPDATE Vsqlt.ExecutionLog
		SET TestCaseName = varE.TestCaseName,
			ExecSPWithParam = varE.ExecSPWithParam,
			ResultNo = varE.ResultNo,
			ExpectedTableHash = varE.ExpectedTableHash,
			ActualTableHash = varE.ActualTableHash,
			ExpectedResult = varE.ExpectedResult,
			ActualResult = varE.ActualResult,
			StartDate = varE.StartDate,
			EndDate = varE.EndDate,
			Status = varE.Status,
			ErrorMessage = varE.ErrorMessage
		FROM Vsqlt.ExecutionLog el
		INNER JOIN @ExecutionLog varE
		ON el.TestCaseKey = varE.TestCaseKey

END TRY


BEGIN CATCH
	SET @errorMessage = (SELECT ERROR_MESSAGE())
	EXEC [VsqltHelper].[CreateRunLog] @TestCaseKey,@ATestCaseName,@ASPFunctionName,Null,'ERROR',@errorMessage
END CATCH


SET NOCOUNT OFF

END