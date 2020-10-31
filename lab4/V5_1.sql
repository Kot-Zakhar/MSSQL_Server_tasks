use AdventureWorks2012;
go

/*
	a) �������� ������� Sales.CreditCardHst, ������� ����� ������� ���������� �� ���������� � ������� Sales.CreditCard.

	������������ ����, ������� ������ �������������� � �������:
		ID � ��������� ���� IDENTITY(1,1);
		Action � ����������� �������� (insert, update ��� delete);
		ModifiedDate � ���� � �����, ����� ���� ��������� ��������;
		SourceID � ��������� ���� �������� �������;
		UserName � ��� ������������, ������������ ��������.
	�������� ������ ����, ���� �������� �� �������.
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
	b) �������� ���� AFTER ������� ��� ���� ��������
	INSERT, UPDATE, DELETE ��� ������� Sales.CreditCard.
	������� ������ ��������� ������� Sales.CreditCardHst
	� ��������� ���� �������� � ���� Action
	� ����������� �� ���������, ���������� �������.
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
	c) �������� ������������� VIEW, ������������ ��� ���� ������� Sales.CreditCard.
*/
create view Sales.View_CreditCard as
	select * from Sales.CreditCard;
go

/*
	d) �������� ����� ������ � Sales.CreditCard ����� �������������.
	�������� ����������� ������. ������� ����������� ������.
	���������, ��� ��� ��� �������� ���������� � Sales.CreditCardHst.
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