IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Vsqlt' 
                 AND  TABLE_NAME = 'TestResult'))
BEGIN
	DROP TABLE [Vsqlt].[TestResult]
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Vsqlt].[TestResult](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TestCaseKey] [nvarchar](max) NULL,
	[TestCaseName] [nvarchar](max) NULL,
	[Duration_In_Ms] [int] NULL,
	[Status] [nvarchar](10) NULL,
	[ErrorMessage] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


