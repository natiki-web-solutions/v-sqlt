IF EXISTS (SELECT 1
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[VsqltHelper].[GenerateTestCaseName]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [VsqltHelper].[GenerateTestCaseName]

GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [VsqltHelper].[GenerateTestCaseName](@AProcId INT)  
RETURNS NVARCHAR(MAX) 
AS   
-- Returns a string that can be executed to populate the assert table with expected data in xml format.
BEGIN  
	
	DECLARE @TestCaseName VARCHAR(MAX) = '[' + OBJECT_SCHEMA_NAME(@AProcId) + '].[' + OBJECT_NAME(@AProcId) + ']'

	RETURN @TestCaseName

END


