use AdventureWorks2012;
go

/*
	a) добавьте в таблицу dbo.Employee поле EmpNum типа int;
*/
alter table dbo.Employee
	add EmpNum int;
go

/*
	b) объявите табличную переменную с такой же структурой
	как dbo.Employee и заполните ее данными из dbo.Employee.
	Поле VacationHours заполните из таблицы HumanResources.Employee.
	Поле EmpNum заполните последовательными номерами строк
	(примените оконные функции или создайте SEQUENCE);
*/

declare @dboEmployee table (
	BusinessEntityID int not null,
	NationalIDNumber nvarchar(15) not null,
	LoginID nvarchar(256) not null,
	JobTitle nvarchar(50) not null,
	BirthDate date not null,
	MaritalStatus nchar(1) not null,
	Gender nchar(1) not null,
	HireDate date not null,
	VacationHours smallint not null,
	SickLeaveHours smallint not null,
	ModifiedDate date null,
	EmpNum int null
);

insert into @dboEmployee (
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
	EmpNum
)
select
	Employee.BusinessEntityID,
	Employee.NationalIDNumber,
	Employee.LoginID,
	Employee.JobTitle,
	Employee.BirthDate,
	Employee.MaritalStatus,
	Employee.Gender,
	Employee.HireDate,
	hrEmployee.VacationHours,
	Employee.SickLeaveHours,
	Employee.ModifiedDate,
	ROW_NUMBER() OVER(order by Employee.BusinessEntityID) as EmpNum
from dbo.Employee
inner join HumanResources.Employee as hrEmployee
	on Employee.BusinessEntityID = hrEmployee.BusinessEntityID;

/*
	c) обновите поля VacationHours и EmpNum в dbo.Employee
	данными из табличной переменной.
	Если значение в табличной переменной в поле VacationHours = 0 —
	оставьте старое значение;
*/

update dbo.Employee
set
	VacationHours = iif(dboEmployee.VacationHours = 0, dboEmployee.VacationHours, dboEmployee.VacationHours),
	EmpNum = dboEmployee.EmpNum
from dbo.Employee
inner join @dboEmployee as dboEmployee
	on Employee.BusinessEntityID = dboEmployee.BusinessEntityID;
go

select 
	BusinessEntityID, VacationHours, EmpNum
from dbo.Employee;
go

/*
	d) удалите данные из dbo.Employee,
	EmailPromotion которых равен 0 в таблице Person.Person;
*/

select BusinessEntityID, EmailPromotion from Person.Person;
go

delete from dbo.Employee
where exists(
	select EmailPromotion
	from Person.Person
	where  Employee.BusinessEntityID = Person.BusinessEntityID
		and Person.EmailPromotion = 0
);
go

select * from dbo.Employee;
go

/*
	e) удалите поле EmpName из таблицы,
	удалите все созданные ограничения и значения по умолчанию.
*/

alter table dbo.Employee
	drop column EmpNum;
go

-- Поиск ограничений
select
	con.name as constraint_name,
    col.name as column_name,
    con.definition
from sys.check_constraints con
	inner join sys.objects t
		on con.parent_object_id = t.object_id
	inner join sys.all_columns col
		on con.parent_column_id = col.column_id
		and con.parent_object_id = col.object_id
	where schema_name(t.schema_id) = 'dbo' and t.name = 'Employee'
	order by con.name;

alter table dbo.Employee
	drop constraint CHECK_Employee_VacationHours;
go

-- Поиск значений по умолчанию
select
	con.name as constraint_name,
    col.name as column_name,
    con.definition
from sys.default_constraints con
	inner join sys.objects t
		on con.parent_object_id = t.object_id
	inner join sys.all_columns col
		on con.parent_column_id = col.column_id
		and con.parent_object_id = col.object_id
	where schema_name(t.schema_id) = 'dbo' and t.name = 'Employee'
	order by con.name;

alter table dbo.Employee
drop
	constraint DEFAULT_Employee_ModifiedDate,
	constraint DEFAULT_Employee_VacationHours,
	constraint DF__Employee__SickLe__25A691D2;
go

/*
	f) удалите таблицу dbo.Employee.
*/

drop table dbo.Employee;
go
