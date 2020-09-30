use AdventureWorks2012;
go

/*
	Вывести на экран время работы каждого сотрудника.
*/
select Employee.BusinessEntityID, JobTitle, Name, StartTime, EndTime
from HumanResources.Employee
inner join HumanResources.EmployeeDepartmentHistory
	on Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
inner join HumanResources.Shift
	on EmployeeDepartmentHistory.ShiftID = Shift.ShiftID;
go

/*
	Вывести на экран количество сотрудников в каждой группе отделов.
*/
select Department.GroupName,
	COUNT(EmployeeDepartmentHistory.BusinessEntityID) as EmpCount
from HumanResources.Department
inner join HumanResources.EmployeeDepartmentHistory
	on EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
where EmployeeDepartmentHistory.EndDate is null
group by Department.GroupName;
go

/*
	Вывести на экран почасовые ставки сотрудников,
	с указанием максимальной ставки для каждого отдела в столбце [MaxInDepartment].
	В рамках каждого отдела разбейте все ставки на группы, таким образом,
	чтобы ставки с одинаковыми значениями входили в состав одной группы.
*/
select Name, DepHist.BusinessEntityID, Rate, MaxInDepartment,
	dense_rank() over(partition by Dep.DepartmentID order by Rate) RateGroup
from HumanResources.EmployeeDepartmentHistory as DepHist
inner join HumanResources.Department as Dep
	on DepHist.DepartmentID = Dep.DepartmentID
inner join HumanResources.EmployeePayHistory as PayHist
	on DepHist.BusinessEntityID = PayHist.BusinessEntityID
inner join (/*Calculating MaxInDepartment value for each Dep*/
	select DepartmentID, MAX(Rate) as MaxInDepartment
	from HumanResources.EmployeeDepartmentHistory as DepHist
	inner join HumanResources.EmployeePayHistory as PayHist
		on DepHist.BusinessEntityID = PayHist.BusinessEntityID
	where DepHist.EndDate is null
	group by DepartmentID
) MaxInDeps
on Dep.DepartmentID = MaxInDeps.DepartmentID
where DepHist.EndDate is null
order by Name, Rate;
go

/*
P.S.:
How can i reuse first two inner joins inside of the subquery?
smth like the following:

select ...

from (
	select * from HumanResources.EmployeeDepartmentHistory as DepHist
	inner join HumanResources.Department as Dep
		on DepHist.DepartmentID = Dep.DepartmentID
	inner join HumanResources.EmployeePayHistory as PayHist
		on DepHist.BusinessEntityID = PayHist.BusinessEntityID
) as Rates

inner join (
	select DepartmentID, MAX(Rate) as MaxInDepartment
	from Rates
	group by DepartmentID
) MaxInDeps
on Rates.DepartmentID = MaxInDeps.DepartmentID
...;

*/