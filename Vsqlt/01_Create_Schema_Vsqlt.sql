If Not Exists(select 1 from sys.schemas where name = 'Vsqlt')
Begin
	exec('Create Schema Vsqlt')
End