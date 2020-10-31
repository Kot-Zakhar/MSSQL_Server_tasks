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
	on EmployeeDepartmentHistory.ShiftID = Shift.ShiftID
where EmployeeDepartmentHistory.EndDate is null;
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
with data as (
	select Dep.DepartmentID, PayHist.BusinessEntityID, Name, Rate, DepHist.EndDate
	from HumanResources.EmployeeDepartmentHistory as DepHist
	inner join HumanResources.Department as Dep
		on DepHist.DepartmentID = Dep.DepartmentID
	inner join HumanResources.EmployeePayHistory as PayHist
		on DepHist.BusinessEntityID = PayHist.BusinessEntityID
)
select Name, BusinessEntityID, Rate, MaxInDepartment,
	dense_rank() over(partition by data.DepartmentID order by Rate) RateGroup
from data
inner join (/*Calculating MaxInDepartment value for each Dep*/
	select DepartmentID, MAX(Rate) as MaxInDepartment
	from data
	where EndDate is null
	group by DepartmentID
) MaxInDeps
on data.DepartmentID = MaxInDeps.DepartmentID
where EndDate is null
order by Name, Rate;
go