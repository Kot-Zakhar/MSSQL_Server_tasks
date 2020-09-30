use AdventureWorks2012;
go

/*
	a) �������� ������� dbo.Employee � ����� �� ���������� ��� HumanResources.Employee,
	����� ����� OrganizationLevel, SalariedFlag, CurrentFlag,
	� ����� ����� ����� � ����� hierarchyid, uniqueidentifier,
	�� ������� �������, ����������� � ��������;
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
	b) ��������� ���������� ALTER TABLE,
	�������� ��� ������� dbo.Employee ����������� UNIQUE ��� ���� NationalIDNumber;
*/
alter table dbo.Employee
	add constraint UC_Employee_NationalIDNumber
	unique(NationalIDNumber);
go

/*
	c) ��������� ���������� ALTER TABLE,
	�������� ��� ������� dbo.Employee ����������� ��� ���� VacationHours,
	����������� ���������� ����� ���� ���������� �������� ��� ������� 0;
*/
alter table dbo.Employee
	add constraint CHECK_Employee_VacationHours
	check (VacationHours > 0);
go

/*
	d) ��������� ���������� ALTER TABLE,
	�������� ��� ������� dbo.Employee ����������� DEFAULT ��� ���� VacationHours,
	������� �������� �� ��������� 144;
*/
alter table dbo.Employee
	add constraint DEFAULT_Employee_VacationHours
	default '144' for VacationHours;
go

/*
	e) ��������� ����� ������� ������� �� HumanResources.Employee
	� ����������� �� ������� �Buyer�.
	�� ���������� ��� ������� ���� VacationHours,
	����� ��� ����������� ���������� �� ���������;
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
	f) �������� ��� ���� ModifiedDate �� DATE
	� ��������� ���������� null �������� ��� ����.
*/
alter table dbo.Employee
	drop constraint DF__Employee__Modifi__269AB60B;
go

alter table dbo.Employee 
	alter column ModifiedDate date null;
go

alter table dbo.Employee
	add constraint DEFAULT_Employee_ModifiedDate
	default (getdate()) for ModifiedDate;
go
