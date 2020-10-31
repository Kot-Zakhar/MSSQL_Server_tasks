use AdventureWorks2012;
go

/*
	a) Добавьте в таблицу dbo.Employee поля SumTotal MONEY и SumTaxAmt MONEY.
	Также создайте в таблице вычисляемое поле WithoutTax,
	вычисляющее разницу между общей суммой уплаченых налогов (SumTaxAmt)
	и общей суммой продаж (SumTotal).
*/

alter table dbo.Employee
	add SumTotal MONEY,
		SumTaxAmt MONEY,
		WithoutTax as SumTotal - SumTaxAmt;
go

/*
	b) создайте временную таблицу #Employee,
	с первичным ключом по полю BusinessEntityID.
	Временная таблица должна включать все поля таблицы dbo.Employee
	за исключением поля WithoutTax.
	
	c) заполните временную таблицу данными из dbo.Employee.
	Посчитайте сумму продаж (TotalDue) и сумму налогов (TaxAmt)
	для каждого сотрудника (EmployeeID) в таблице Purchasing.PurchaseOrderHeader
	и заполните этими значениями поля SumTotal и SumTaxAmt.
	Выберите только те записи, где SumTotal > 5 000 000.
	Подсчет суммы продаж и суммы налогов осуществите в
	Common Table Expression (CTE).
*/

with TotalDueAndTaxAmtSums as (
	select
		EmployeeID,
		SUM(TotalDue) as SumTotal,
		SUM(TaxAmt) as SumTaxAmt
	from Purchasing.PurchaseOrderHeader
	group by EmployeeID
)
update dbo.Employee
set
	SumTotal = TotalDueAndTaxAmtSums.SumTotal,
	SumTaxAmt = TotalDueAndTaxAmtSums.SumTaxAmt
from TotalDueAndTaxAmtSums
where BusinessEntityID = EmployeeID;

select
	BusinessEntityID,
	NationalIDNumber,
	LoginID,
	JobTitle,
	BirthDate,
	MaritalStatus,
	Gender,
	HireDate,
	VacationHours,
	SickLeaveHours,
	ModifiedDate,
	SumTotal,
	SumTaxAmt
into #Employee
from dbo.Employee
where SumTotal > 5000000;

select
	Employee.BusinessEntityID,
	Employee.SumTotal,
	Employee.SumTaxAmt,
	Employee.WithoutTax,
	#Employee.BusinessEntityID
from dbo.Employee
left join #Employee on #Employee.BusinessEntityID = Employee.BusinessEntityID;
go

/*
	d) удалите из таблицы dbo.Employee строки, где MaritalStatus = ‘S’
*/

delete from dbo.Employee
where MaritalStatus = 'S';
go

/*
	e) напишите Merge выражение, использующее dbo.Employee как target,
	а временную таблицу как source.
	Для связи target и source используйте BusinessEntityID.
	Если запись присутствует в source и target,
		обновите поля SumTotal и SumTaxAmt.
	Если строка присутствует во временной таблице, но не существует в target,
		добавьте строку в dbo.Employee.
	Если в dbo.Employee присутствует такая строка,
		которой не существует во временной таблице,
		удалите строку из dbo.Employee.
*/

select BusinessEntityID, SumTotal, SumTaxAmt, WithoutTax from dbo.Employee;
go

merge dbo.Employee as target
using #Employee as source
on target.BusinessEntityId = source.BusinessEntityId
when matched then
	update set	
		target.SumTotal = source.SumTotal,
		target.SumTaxAmt = source.SumTaxAmt
when not matched by target then
	insert values (
		source.BusinessEntityId,
		source.NationalIdNumber,
		source.LoginID,
		source.JobTitle,
		source.BirthDate,
		source.MaritalStatus,
		source.Gender,
		source.HireDate,
		source.VacationHours,
		source.SickLeaveHours,
		source.ModifiedDate,
		source.SumTotal,
		source.SumTaxAmt
	)
when not matched by source then
	delete
output $action, inserted.*, deleted.*;
go