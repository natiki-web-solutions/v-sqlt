IF EXISTS(SELECT 1 FROM sys.procedures 
          WHERE object_id = OBJECT_ID(N'testcase_uspRetrieveData'))
BEGIN
    DROP PROCEDURE [Vsqlt].[testcase_uspRetrieveData]
END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Vsqlt].[testcase_uspRetrieveData]
(
     @ATestTargetDatabaseName NVARCHAR(100),         --Target database where the stored proc to test resides
     @ATestTargetServerName NVARCHAR(100) = NULL     --Target server but this is not yet implemented
)
AS

BEGIN

    -- *************************************** ARRANGE ***************************************************
   DECLARE @SpUnderTestName NVARCHAR(200) = '[dbo].[uspRetrieveData]'  --Name of the stored procedure to test (schema = dbo and sp = uspRetrieveData)
   
   -- Start: Step1 Setup Result Schema ------------------------------------------------------------------------
   -- Note: This is the area where you need to setup the table schema that is expected to capture the resultset returned by your sp. This will basically provide the structure
   --       of raw xml that will capture the result set of the stored procudure. The left side of fields in the create table represents the data types which are pre defined in
   --       the template table [Vsqlt].[TableTemplate]. IntField represents integer, DateTimeField represents Datetime, etc...
   SELECT IntField as Id,
	DatetimeField as FinishDateTime,
	DatetimeField as StartDateTime,
	IntField as SupplierId,
	IntField as IsActive,
	IntField as IsDeleted,
	IntField as DeleterUserId,
	DatetimeField as DeletionTime,
	DatetimeField as LastModificationTime, 
	DatetimeField as LastModifierUserId,
	DatetimeField as CreationTime,
	DatetimeField as CreatorUserId
   INTO #TestResult
   FROM [Vsqlt].[TableTemplate]
   WHERE 1=2
   -- End Step1 Setup Result Schema -----------------------------------------------------------------------

   -- Start: Step2 Define Test Case Parameter(s) --------------------------------------------------------------
   -- Note: This is the area where you need to setup the parameters. This is essential because this will allow you to test stored procedure or function with different parameter
   --       and you don't need to create different test case for each.  After you create fields in #TestCases which basically represents the parameters of stored procedure or
   --       or function, you only need to supply the values for them and test will be executed using them.
   --       The sample parameters are explained below but take note that they will vary depending on the number of parameters your stored procedure or functions have.
   --       1. ExpectedResult - the expected result your sp returns (needs to be represented as xml). This will be compared against the actual result. Note that
   --          this is not part of stored procedure or function parameter but more of a mandatory field in the #TestCases that must be supplied.
   --       2. ResultNumber - result number you want to test. Stored procedures might have 1 or more result set so this is where this will come in handy. Note that
   --          this is not part of stored procedure or function parameter but more of a mandatory field in the #TestCases that must be supplied.
   --       3. ParamId - is the parameter of the stored procedure. Note that you can have one or many parameters so after ResultNumber, you can define all the parameters
   --          required by your stored procedure
   SELECT 
	XmlField as ExpectedResult,
	IntField as ResultNumber,
	IntField as ParamId
   INTO #TestCases
   FROM [Vsqlt].[TableTemplate]
   WHERE 1=2
   -- End : Step2 Define Test Case Parameter(s) -------------------------------------------------------------


   -- Start : Step3  Setup Expected Results ---------------------------------------------------------------------
   -- Note : This is where you need to supply the values for the fields you defined in #TestCases.
	DECLARE @expectedResult XML = '<row Id="10019" FinishDateTime="2024-08-16T19:03:00" StartDateTime="2018-01-13T16:00:00" SupplierId="10034" IsActive="1" IsDeleted="0" LastModificationTime="2018-03-25T10:03:52.637" LastModifierUserId="1900-01-02T00:00:00" CreationTime="2018-04-08T23:29:00.237" CreatorUserId="1900-01-02T00:00:00" />'
	INSERT #TestCases VALUES (@expectedResult,1,10019)
   -- End : Step3  Setup Expected Results ---------------------------------------------------------------------

  
   -- ******************************************* EXECUTE AND ASSERT *****************************************
   --Start : Execute and Assert
   --Note : Note that this is where test will happen. There is no need for you to do in this section as this will process all the inputs you provided above.
   DECLARE @TestCaseName NVARCHAR(MAX) =  [VsqltHelper].[GenerateTestCaseName](@@PROCID) 
   EXEC [VsqltHelper].[DoTest] @ATargetDatabaseName = @ATestTargetDatabaseName, @ASPFunctionName = @SpUnderTestName,@ATestCaseName = @TestCaseName
   --End : Execute and Assert


END
