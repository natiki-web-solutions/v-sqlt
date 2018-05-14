IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Vsqlt' 
                 AND  TABLE_NAME = 'TableTemplate'))
BEGIN
	DROP TABLE [Vsqlt].[TableTemplate]
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Vsqlt].[TableTemplate](
	[BigIntField] [bigint] NULL,
	[IntField] [int] NULL,
	[SmallIntField] [smallint] NULL,
	[BinaryField] [binary](1) NULL,
	[BitField] [bit] NULL,
	[DatetimeField] [datetime] NULL,
	[SmalldatetimeField] [smalldatetime] NULL,
	[DecimalField] [decimal](18, 0) NULL,
	[FloatField] [float] NULL,
	[MoneyField] [money] NULL,
	[SmallmoneyField] [smallmoney] NULL,
	[NvarcharField] [nvarchar](max) NULL,
	[VarcharField] [varchar](max) NULL,
	[XmlField] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


