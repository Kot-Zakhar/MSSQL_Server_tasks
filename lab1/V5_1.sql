create database NewDatabase;
go

use NewDatabase;
go

create schema sales;
go
create schema personas;
go

create table sales.Orders(OrderNum int null);
go

backup database NewDatabase
to disk = 'D:\Documents\university\DB\labs\lab1\ZAKHAR_KOT.bak';
go

use master;
go

drop database NewDatabase;
go

restore database NewDatabase
from disk = 'D:\Documents\university\DB\labs\lab1\ZAKHAR_KOT.bak';
go