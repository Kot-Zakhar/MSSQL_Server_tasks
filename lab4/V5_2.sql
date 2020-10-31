use AdventureWorks2012;
go

/*
	a) —оздайте представление VIEW, отображающее данные из таблиц
	Sales.CreditCard и Sales.PersonCreditCard.
	—делайте невозможным просмотр исходного кода представлени€.
	—оздайте уникальный кластерный индекс в представлении
	по полю CreditCardID.
*/

create view Sales.View_CreditCard_PersonCreditCard (
	CreditCardID,
	CardType,
	CardNumber,
	ExpMonth,
	ExpYear,
	CCModifiedDate,
	BusinessEntityID,
	PCCModifiedDate
) with encryption, schemabinding as
select 
	cc.CreditCardID,
	CardType,
	CardNumber,
	ExpMonth,
	ExpYear,
	cc.ModifiedDate,
	pcc.BusinessEntityID,
	pcc.ModifiedDate
from Sales.CreditCard as cc
join Sales.PersonCreditCard as pcc on cc.CreditCardID = pcc.CreditCardID;
go

create unique clustered index AK_View_CreditCard_PersonCreditCard_CreditCardID
	on Sales.View_CreditCard_PersonCreditCard (CreditCardID);
go

/*
	b) —оздайте три INSTEAD OF триггера дл€ представлени€
	на операции INSERT, UPDATE, DELETE.
	 аждый триггер должен выполн€ть соответствующие операции
	в таблицах Sales.CreditCard и Sales.PersonCreditCard
	дл€ указанного BusinessEntityID.
	ќбновление должно происходить только в таблице Sales.CreditCard.
	”даление строк из таблицы Sales.CreditCard производите
	только в том случае, если удал€емые строки больше не ссылаютс€
	на Sales.PersonCreditCard.
	
	c) ¬ставьте новую строку в представление,
	указав новые данные дл€ CreditCard дл€ существующего BusinessEntityID (например 1).
	“риггер должен добавить новые строки
	в таблицы Sales.CreditCard и Sales.PersonCreditCard.
	ќбновите вставленные строки через представление. ”далите строки.
*/
drop trigger Sales.Trigger_View_CreditCard_PersonCreditCard_Instead_Insert;
go
create trigger Sales.Trigger_View_CreditCard_PersonCreditCard_Instead_Insert
	on Sales.View_CreditCard_PersonCreditCard
instead of insert as
begin
	insert into Sales.CreditCard (
		CardType,
		CardNumber,
		ExpMonth,
		ExpYear,
		ModifiedDate
	)
	select
		CardType,
		CardNumber,
		ExpMonth,
		ExpYear,
		CCModifiedDate as ModifiedDate
	from inserted
	insert into Sales.PersonCreditCard
	select
		BusinessEntityID,
		c.CreditCardID,
		PCCModifiedDate as ModifiedDate
	from inserted
	join Sales.CreditCard as c on inserted.CardNumber = c.CardNumber
end;
go

insert into Sales.View_CreditCard_PersonCreditCard
(
	CardType,
	CardNumber,
	ExpMonth,
	ExpYear,
	CCModifiedDate,
	BusinessEntityID,
	PCCModifiedDate
)
values (
	'SomeType',
	2,
	11,
	2020,
	getdate(),
	293,
	getdate());

select *
from Sales.PersonCreditCard as p
full outer join Sales.CreditCard as c
	on p.CreditCardID = c.CreditCardID
where CardType = 'SomeType';
go


create trigger Sales.Trigger_View_CreditCard_PersonCreditCard_Instead_Update
	on Sales.View_CreditCard_PersonCreditCard
instead of update as
begin
	update Sales.CreditCard
	set
		CardType = inserted.CardType,
		CardNumber = inserted.CardNumber,
		ExpMonth = inserted.ExpMonth,
		ExpYear = inserted.ExpYear,
		ModifiedDate = inserted.CCModifiedDate
	from inserted
	where CreditCard.CreditCardID = inserted.CreditCardID
end;
go

update Sales.View_CreditCard_PersonCreditCard
set 
	CardType = 'SomeTypeNew',
	CardNumber = 3,
	CCModifiedDate = getdate(),
	PCCModifiedDate = getdate()
where CardType = 'SomeType';
go

select *
from Sales.PersonCreditCard as p
full outer join Sales.CreditCard as c
	on p.CreditCardID = c.CreditCardID
where CardType = 'SomeTypeNew';
go


create trigger Sales.Trigger_View_CreditCard_PersonCreditCard_Instead_Delete
	on Sales.View_CreditCard_PersonCreditCard
instead of delete as
begin
	delete from Sales.PersonCreditCard
		where BusinessEntityID in (
			select BusinessEntityID
			from deleted
		)
	delete from Sales.CreditCard
		where CreditCardID in (
			select CreditCardID
			from deleted
		) and 
		CreditCardID not in (
			select CreditCardID
			from Sales.PersonCreditCard
		)
end;
go

delete from Sales.View_CreditCard_PersonCreditCard
where CardType = 'SomeTypeNew';
go
