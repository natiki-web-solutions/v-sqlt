--To run all the test cases
exec [Vsqlt].[RUNALL] @TestTargetDatabaseName = 'Tsqlt_Example'

--To run specific test cases
exec [Vsqlt].[RUN] @TestTargetDatabaseName = 'Tsqlt_Example',@testCaseName = '[Vsqlt].[testcasename]'





