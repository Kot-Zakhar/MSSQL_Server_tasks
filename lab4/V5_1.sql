use AdventureWorks2012;
go

/*
	a) —оздайте таблицу Sales.CreditCardHst, котора€ будет хранить информацию об изменени€х в таблице Sales.CreditCard.

	ќб€зательные пол€, которые должны присутствовать в таблице:
		ID Ч первичный ключ IDENTITY(1,1);
		Action Ч совершенное действие (insert, update или delete);
		ModifiedDate Ч дата и врем€, когда была совершена операци€;
		SourceID Ч первичный ключ исходной таблицы;
		UserName Ч им€ пользовател€, совершившего операцию.
	—оздайте другие пол€, если считаете их нужными.
*/

create table Sales.CreditCardHst (
	ID			 int identity (1, 1) primary key,
	Action		 char(6)		not null check (Action IN ('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate datetime not null,
	SourceID	 int	  not null,
	UserName varchar(50)  not null
);
go

/*
	b) —оздайте один AFTER триггер дл€ трех операций
	INSERT, UPDATE, DELETE дл€ таблицы Sales.CreditCard.
	“риггер должен заполн€ть таблицу Sales.CreditCardHst
	с указанием типа операции в поле Action
	в зависимости от оператора, вызвавшего триггер.
*/
create trigger Sales.CreditCard_after_action_trigger on Sales.CreditCard
after INSERT, UPDATE, DELETE as
insert into Sales.CreditCardHst
	select
		case
			when inserted.CreditCardID is null
				then 'DELETE'
			when deleted.CreditCardId is null
				then 'INSERT'
			else 'UPDATE' 
		end as Action,
		getdate() as ModifiedDate,
		coalesce(inserted.CreditCardID, deleted.CreditCardID) AS SourceID,
		user_name() as UserName
	from inserted
	full outer join deleted
	on inserted.CreditCardID = deleted.CreditCardID;
go

/*
	c) —оздайте представление VIEW, отображающее все пол€ таблицы Sales.CreditCard.
*/
create view Sales.View_CreditCard as
	select * from Sales.CreditCard;
go

/*
	d) ¬ставьте новую строку в Sales.CreditCard через представление.
	ќбновите вставленную строку. ”далите вставленную строку.
	”бедитесь, что все три операции отображены в Sales.CreditCardHst.
*/
insert into Sales.View_CreditCard values ('New Card Type', '1', '12', '2020', getdate());
go

select * from Sales.CreditCard where CardNumber = '1';
go

update Sales.View_CreditCard
	set CardNumber = '2'
	where CardNumber = '1';
go

select * from Sales.CreditCard where CardNumber = '2';
go

delete from Sales.CreditCard where CardNumber = '2';
go