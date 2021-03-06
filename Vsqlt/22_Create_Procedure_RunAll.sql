IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE object_id = OBJECT_ID(N'Vsqlt.RUNALL'))
BEGIN
    DROP PROCEDURE [Vsqlt].[RUNALL]
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Vsqlt].[RUNALL]
(
@TestTargetDatabaseName NVARCHAR(MAX)
)
AS

BEGIN

DECLARE @SPName NVARCHAR(200),
        @ExpectedTestSchema NVARCHAR(50) =  'Vsqlt'

DECLARE @tblRunAll TABLE(SPName NVARCHAR(200))
INSERT INTO @tblRunAll 
SELECT '[' + @ExpectedTestSchema +'].[' + name + ']'
FROM sys.procedures
WHERE SCHEMA_NAME([schema_id]) = @ExpectedTestSchema
AND name NOT IN ('RUNALL','RUN') --Do not include main sp for execution


--This table variable will be used to filter the test result to be shown to the user. Only executed test case will be shown.
DECLARE @tblRunResultFilter TABLE(SPName NVARCHAR(200))
INSERT @tblRunResultFilter SELECT SPName FROM @tblRunAll

DECLARE @ExecSql NVARCHAR(1000)

IF(SELECT COUNT(1) FROM  @tblRunAll) > 0
BEGIN
	WHILE (SELECT COUNT(1) FROM @tblRunAll) > 0
		BEGIN
		
			--Get sp to execute
			SELECT @SPName = SPName
			FROM @tblRunAll

			--Perform actual execution
			SET @ExecSql = 'EXEC ' + @SPName + ' ''' + @TestTargetDatabaseName + ''''

			--Perform actual execution
			EXEC(@ExecSql)
		
			--Delete record of the sp already executed
			DELETE FROM @tblRunAll WHERE SpName = @SPName
		END

	--Clean the content of [Vsqlt].[TestResult] every run
	TRUNCATE TABLE [Vsqlt].[TestResult]

	--Populate it with the current run
	INSERT [Vsqlt].[TestResult] (TestCaseKey,TestCaseName,Duration_In_Ms ,Status,ErrorMessage)
	SELECT TestCaseKey,TestCaseName,DATEDIFF (millisecond ,StartDate,EndDate),Status,ErrorMessage FROM [Vsqlt].ExecutionLog WHERE TestCaseName IN (SELECT SPName FROM @tblRunResultFilter)

	--Retrieve result of testing
	SELECT * FROM [Vsqlt].[TestResult]


	END
ELSE
	BEGIN
		PRINT 'There are no Test Cases to be executed.'
	END

END
