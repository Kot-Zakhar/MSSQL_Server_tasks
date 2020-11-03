use AdventureWorks2012;
go

/*
	�������� �������� ���������, ������� ����� ���������� ������� �������
	(�������� PIVOT), ������������ ������ � ���������� ����������� �������
	������ ����������� (Purchasing.PurchaseOrderHeader.EmployeeID),
	������������ ������������ ������� (Purchasing.ShipMethod).
	������ ����� �������� ��������� � ��������� ����� ������� ��������.
*/
create procedure Purchasing.GetOrderCounts (@ShipMethodsNames nvarchar(max))
as
begin
	declare @query as nvarchar(max) = '
		select EmployeeID, ' + @ShipMethodsNames + '
		from (
			select EmployeeID, PurchaseOrderID, Name
			from Purchasing.PurchaseOrderHeader as p
			join Purchasing.ShipMethod as s on p.ShipMethodID = s.ShipMethodID
		) as piv
		pivot (count(PurchaseOrderID) for piv.Name in(' + @ShipMethodsNames + ')) as pvt;
	'
	execute sp_executesql @query
end;
go

execute Purchasing.GetOrderCounts '[CARGO TRANSPORT 5],[OVERNIGHT J-FAST],[OVERSEAS - DELUXE]';