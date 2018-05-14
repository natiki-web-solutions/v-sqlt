# v-sqlt
Microsoft SQL Server Unit Testing

Introduction
------------
This is just a simple instruction on how to use **V-Sqlt** (Virtual SQL Tester) framework. This will be an alternative unit test framework for SQL Server components such as stored procedures and functions.  The aim of this framework is to create a single template for one stored procedure of functions to be tested that will allow you to test for multiple parameters in just a single test case.  In addition, each parameter's test result will be available in the log table so everything is accounted for.


Prerequisites
-------------
As this is currently using some TSQLT components, you will need to install TSQLT first in your SQL Server database before you can use this. Furthermore, this is currently tested in SQL Server 2012 and above and there is no assurance if this will work in older version.


Features
--------
This will do more of an integration test rather than unit test in case your stored procedure/functions are calling other stored procedures/functions.  In addition, this will also provide a simple performance test because execution time of the components tested per parameter supplied will be measured in milliseconds.  This version currenlty supports asserting result sets (for stored procedures/functions that returns records) and inserted/deleted records for stored procedures that perform DML operation (but you need to provide a SQL that will return the inserted or deleted record to be used for assert).


Installation
------------
1. Run all the scripts inside Vsqlt folder. Order of execution is based on the prefix of the files.
2. Once done, you can already use it. For quick instruction on how to use it, you may refer to the sample
   test case **Sample_Proc_Test.sql** under **Help** folder. The sample test case contains instructions and notes 
   regarding how to use the framework with comments on what are the things you need to modify per section of the template
   test case.
3. Refer to **How to run test.sql** for the simple script on how to individually run the test or run all of them.

