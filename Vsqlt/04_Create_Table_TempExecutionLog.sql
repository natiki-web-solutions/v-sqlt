IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Vsqlt' 
                 AND  TABLE_NAME = 'TempExecutionLog'))
BEGIN
	DROP TABLE [Vsqlt].[TempExecutionLog]
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Vsqlt].[TempExecutionLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TestCaseKey] [nvarchar](max) NULL,
	[TestCaseName] [nvarchar](max) NULL,
	[ObjectToTest] [nvarchar](max) NULL,
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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


