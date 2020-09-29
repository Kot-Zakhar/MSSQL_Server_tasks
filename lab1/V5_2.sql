restore database AdventureWorks2012
from disk = 'D:\Documents\university\DB\AdventureWorks2012.bak'
with move 'AdventureWorks2012' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\AdventureWorks2012.mdf',
move 'AdventureWorks2012_log' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\AdventureWorks2012_log.ldf';
go

use AdventureWorks2012;
go

/*
	������� �� ����� ������ �������, ������������� ������ �Research and Development�,
	��������������� �� �������� ������ � ������� A-Z.
*/
select Name, GroupName
from HumanResources.Department 
where GroupName = 'Research and Development'
order by Name asc;
go


/*
	������� �� ����� ����������� ���������� ���������� ���������� ����� � �����������.
	�������� ������� � ����������� �MinSickLeaveHours�.
*/
select min(SickLeaveHours) as MinSickLeaveHours
from HumanResources.Employee;
go

/*
	������� �� ����� ������ ��������������� ���������� � ������� A-Z.
	������� ������ ������ 10 ��������.
	�������� �������, � ������� ������� ������ ����� �� ���� [JobTitle].
*/
select distinct top 10
	JobTitle,
	substring(JobTitle, 1, isnull(nullif(charindex(' ', JobTitle), 0), len(JobTitle))) as fristWord
from HumanResources.Employee
order by JobTitle asc;
go