IF EXISTS (SELECT 1
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[VsqltHelper].[GenerateNonXMLParam]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [VsqltHelper].[GenerateNonXMLParam]

GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [VsqltHelper].[GenerateNonXMLParam](@paramList NVARCHAR(max), @procOperation bit)  
RETURNS nvarchar(max)   
AS   
-- Returns create table variable script.  
BEGIN  

	  DECLARE @StartIndex INT, @EndIndex INT
	  DECLARE @generatedParam NVARCHAR(MAX), @tempParam NVARCHAR(200)

	  IF(@paramList = '')
		RETURN ''
			
      SET @StartIndex = 1
      IF SUBSTRING(@paramList, LEN(@paramList) - 1, LEN(@paramList)) <> '*'
      BEGIN
            SET @paramList = @paramList + '*'
      END
	
	  SET @generatedParam  = ''
      WHILE CHARINDEX('*', @paramList) > 0
      BEGIN
            SET @EndIndex = CHARINDEX('*', @paramList)
           
            --INSERT INTO @Output(Item)
            SET @tempParam = [VsqltHelper].[GenerateNonXMLParamFormat](SUBSTRING(@paramList, @StartIndex, @EndIndex - 1),@procOperation)
           
            SET @paramList = SUBSTRING(@paramList, @EndIndex + 1, LEN(@paramList))

			IF(CHARINDEX('*', @paramList) > 0)
				SET @generatedParam = @generatedParam + @tempParam + ','			
			ELSE
				SET @generatedParam = @generatedParam + @tempParam
				
      END

	  RETURN @generatedParam; 
  
END
