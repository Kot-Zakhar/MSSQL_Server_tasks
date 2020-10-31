use AdventureWorks2012;
go

/*
	a) создайте таблицу dbo.Employee с такой же структурой как HumanResources.Employee,
	кроме полей OrganizationLevel, SalariedFlag, CurrentFlag,
	а также кроме полей с типом hierarchyid, uniqueidentifier,
	не включая индексы, ограничения и триггеры;
*/
create table dbo.Employee(
	BusinessEntityID int NOT NULL,
	NationalIDNumber nvarchar(15) NOT NULL,
	LoginID nvarchar(256) NOT NULL,
	JobTitle nvarchar(50) NOT NULL,
	BirthDate date NOT NULL,
	MaritalStatus nchar(1) NOT NULL,
	Gender nchar(1) NOT NULL,
	HireDate date NOT NULL,
	VacationHours smallint NOT NULL,
	SickLeaveHours smallint NOT NULL DEFAULT ((0)),
	ModifiedDate datetime NOT NULL DEFAULT (getdate())
);
go

/*
	b) используя инструкцию ALTER TABLE,
	создайте для таблицы dbo.Employee ограничение UNIQUE для поля NationalIDNumber;
*/
alter table dbo.Employee
	add constraint UC_Employee_NationalIDNumber
	unique(NationalIDNumber);
go

/*
	c) используя инструкцию ALTER TABLE,
	создайте для таблицы dbo.Employee ограничение для поля VacationHours,
	запрещающее заполнение этого поля значениями меньшими или равными 0;
*/
alter table dbo.Employee
	add constraint CHECK_Employee_VacationHours
	check (VacationHours > 0);
go

/*
	d) используя инструкцию ALTER TABLE,
	создайте для таблицы dbo.Employee ограничение DEFAULT для поля VacationHours,
	задайте значение по умолчанию 144;
*/
alter table dbo.Employee
	add constraint DEFAULT_Employee_VacationHours
	default '144' for VacationHours;
go

/*
	e) заполните новую таблицу данными из HumanResources.Employee
	о сотрудниках на позиции ‘Buyer’.
	Не указывайте для выборки поле VacationHours,
	чтобы оно заполнилось значениями по умолчанию;
*/
insert into dbo.Employee (
	BusinessEntityID,
	NationalIDNumber,
	LoginID,
	JobTitle,
	BirthDate,
	MaritalStatus,
	Gender,
	HireDate,
	SickLeaveHours,
	ModifiedDate)
select 
	BusinessEntityID,
	NationalIDNumber,
	LoginID,
	JobTitle,
	BirthDate,
	MaritalStatus,
	Gender,
	HireDate,
	SickLeaveHours,
	ModifiedDate
from HumanResources.Employee
	where JobTitle = 'Buyer';
go

select * from dbo.Employee;
go

/*
	f) измените тип поля ModifiedDate на DATE
	и разрешите добавление null значений для него.
*/
alter table dbo.Employee
	drop constraint DF__Employee__Modifi__39AD8A7F;
go

alter table dbo.Employee 
	alter column ModifiedDate date null;
go

alter table dbo.Employee
	add constraint DEFAULT_Employee_ModifiedDate
	default (getdate()) for ModifiedDate;
go
