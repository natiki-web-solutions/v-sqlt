If Not Exists(select 1 from sys.schemas where name = 'VsqltHelper')
Begin
	exec('Create Schema VsqltHelper')
End