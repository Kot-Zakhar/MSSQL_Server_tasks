use AdventureWorks2012;
go

/*
	¬ывести значени€ полей [LocationID], [Name] и [CostRate]
	из таблицы [Production].[Location] в виде xml,
	сохраненного в переменную.
	‘ормат xml должен соответствовать примеру:

	<Locations>
	  <Location ID="1" Name="Tool Crib" Cost="0.0000" />
	  <Location ID="2" Name="Sheet Metal Racks" Cost="0.0000" />
	</Locations>

	—оздать временную таблицу и заполнить еЄ данными из переменной,
	содержащей xml.
*/
declare @xml_var xml = (
	select
		LocationID as '@ID',
		Name as '@Name',
		CostRate as '@Cost'
	from Production.Location
	for xml path ('Location'), root ('Locations')
)

select
    xc.value('@ID', 'int') as LocationID,
    xc.value('@Name', 'nvarchar(100)') as Name,
    xc.value('@Cost', 'smallmoney') as CostRate
into dbo.#Location
from @xml_var.nodes('//Location') as XmlData(xc);

select * from dbo.#Location;
go