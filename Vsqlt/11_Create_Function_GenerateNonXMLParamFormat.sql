IF EXISTS (SELECT 1
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[VsqltHelper].[GenerateNonXMLParamFormat]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [VsqltHelper].[GenerateNonXMLParamFormat]

GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [VsqltHelper].[GenerateNonXMLParamFormat](@param NVARCHAR(100), @procOperation bit)  
RETURNS NVARCHAR(200) 
AS   
-- Returns a formatted parameter based on its datatype
BEGIN  
	
    DECLARE @SeparatorPosition INT =  CHARINDEX('|',@param)
	DECLARE @formattedParam NVARCHAR(100) = null

	IF(@SeparatorPosition > 0)
		BEGIN
			DECLARE @tmpParam NVARCHAR(100) = (SELECT LEFT(@param,@SeparatorPosition - 1))
			DECLARE @datatype NVARCHAR(100) = (SELECT SUBSTRING(@param,@SeparatorPosition + 1,LEN(@param) - @SeparatorPosition))
			
			IF(@datatype LIKE '%int%' OR @datatype LIKE '%bit%' OR @datatype LIKE '%dec%' OR @datatype LIKE '%num%' OR @datatype LIKE '%float%' OR @datatype LIKE '%money%' OR @datatype LIKE '%real%')
				SET @formattedParam = @tmpParam
			ELSE
				BEGIN
					IF(@procOperation = 1)
						SET @formattedParam = '''''' + @tmpParam + ''''''
					ELSE
						SET @formattedParam = '''' + @tmpParam + ''''
				
				END

			
		END
	
	RETURN @formattedParam

END

