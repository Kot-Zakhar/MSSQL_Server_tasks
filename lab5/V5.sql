use AdventureWorks2012;
go

/*
	�������� scalar-valued �������,
	������� ����� ��������� � �������� �������� ���������
	id ������ ��� �������� (Production.ProductModel.ProductModelID)
	� ���������� ��������� ��������� ��������� ������ ������
	(Production.Product.ListPrice).
*/
create function Production.GetSumPriceOfProduct(@ProductModelID int)
returns money
as
begin
	declare @result money
	select @result = SUM(Product.ListPrice)
	from Production.Product
	where Product.ProductModelID = @ProductModelID
	return @result
end;
go

select *, Production.GetSumPriceOfProduct(ProductModelID) as SumPriceOfProduct from Production.ProductModel;
go

/*
	�������� inline table-valued �������,
	������� ����� ��������� � �������� �������� ���������
	id ��������� (Sales.Customer.CustomerID),
	� ���������� 2 ��������� ������,
	����������� ���������� �� Sales.SalesOrderHeader.
*/
create function Sales.GetTwoLastOrders(@CustomerID int)
returns table
as
return (
	select top(2) *
	from Sales.SalesOrderHeader
	where CustomerID = @CustomerID
	order by OrderDate desc
);
go

/*
	�������� ������� ��� ������� ���������,
	�������� �������� CROSS APPLY.
	�������� ������� ��� ������� ���������,
	�������� �������� OUTER APPLY.
*/
select * from Sales.Customer cross apply Sales.GetTwoLastOrders(CustomerID);
select * from Sales.Customer outer apply Sales.GetTwoLastOrders(CustomerID);
go

/*
	�������� ��������� inline table-valued �������,
	������ �� multistatement table-valued.
*/
create function Sales.GetTwoLastOrdersMulti(@CustomerID int)
returns @result table(
	SalesOrderID int,
	RevisionNumber tinyint,
	OrderDate datetime,
	DueDate datetime,
	ShipDate datetime,
	Status tinyint,
	OnlineOrderFlag dbo.Flag,
	SalesOrderNumber nvarchar(23),
	PurchaseOrderNumber dbo.OrderNumber,
	AccountNumber dbo.AccountNumber,
	CustomerID int,
	SalesPersonID int,
	TerritoryID int,
	BillToAddressID int,
	ShipToAddressID int,
	ShipMethodID int,
	CreditCardID int,
	CreditCardApprovalCode varchar(15),
	CurrencyRateID int,
	SubTotal money,
	TaxAmt money,
	Freight money,
	TotalDue int,
	Comment nvarchar(128),
	rowguid uniqueidentifier rowguidcol,
	ModifiedDate datetime
)
as
begin
	insert into @result
	select top(2) *
	from Sales.SalesOrderHeader
	where CustomerID = @CustomerID
	order by OrderDate desc
	return
end;
go

select c.CustomerID, SalesOrderID
from Sales.Customer as c
cross apply Sales.GetTwoLastOrdersMulti(CustomerID)
order by CustomerID;