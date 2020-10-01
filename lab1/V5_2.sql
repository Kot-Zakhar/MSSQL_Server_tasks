restore database AdventureWorks2012
from disk = 'D:\Documents\university\DB\AdventureWorks2012.bak'
with move 'AdventureWorks2012' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\AdventureWorks2012.mdf',
move 'AdventureWorks2012_log' to 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\AdventureWorks2012_log.ldf';
go

use AdventureWorks2012;
go

/*
	Вывести на экран список отделов, принадлежащих группе ‘Research and Development’,
	отсортированных по названию отдела в порядке A-Z.
*/
select Name, GroupName
from HumanResources.Department 
where GroupName = 'Research and Development'
order by Name asc;
go


/*
	Вывести на экран минимальное количество оставшихся больничных часов у сотрудников.
	Назовите столбец с результатом ‘MinSickLeaveHours’.
*/
select min(SickLeaveHours) as MinSickLeaveHours
from HumanResources.Employee;
go

/*
	Вывести на экран список неповторяющихся должностей в порядке A-Z.
	Вывести только первые 10 названий.
	Добавить столбец, в котором вывести первое слово из поля [JobTitle].
*/
select distinct top 10
	JobTitle,
	substring(JobTitle, 1, isnull(nullif(charindex(' ', JobTitle), 0), len(JobTitle))) as fristWord
from HumanResources.Employee
order by JobTitle asc;
go