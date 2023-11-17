------------------------------------------------------------------------------
Use [DW_WeatherTracker]
go

-- Step 2) Create Tables de Dimension : DimEvents
Create Table [DimEvents]
( [EventKey] int not null Identity
, [EventName] varchar(50) not null 
)
Go
-----------------------------------------------------------------------------
-- Step 3) Dimension Date:
drop table DimDates
CREATE TABLE dbo.DimDates (
  [DateKey] int NOT NULL PRIMARY KEY IDENTITY
, [Date] date NOT NULL  -- valeur de type datetime stockée dans la table
, [DateName] nVarchar(50)  -- nom du jour
, [Month] int NOT NULL -- numéro de mois de l'année
, [MonthName] nVarchar(50) NOT NULL -- nom du mois de l'année
, [Quarter] int NOT NULL --le numéro du trimestre (1,2,3 ou 4)
, [QuarterName] nVarchar(50) NOT NULL -- un nom de trimestre obtenu en concaténant plusieurs info
, [Year] int NOT NULL -- l'année numérique
, [YearName] nVarchar(50) NOT NULL  -- info sur l'année (en chaine de caractères)
)
Go
-----------------------------------------------------------------------------

-- Step 4) Create Fact Table
Drop table FactWeather
Create Table [FactWeather]
( [EventKey] int not null
, [DateKey] [int] NOT NULL	
, [MaxTempF] int not null
, [MinTempF] int not null 
)
Go
-----------------------------------------------------------------------------

-- Step 5) Create PKs & FKs: 

Alter Table DimEvents Add Constraint
	PK_DimEvents primary key ( [EventKey] ) 	
Go	
Alter Table FactWeather Add Constraint
	PK_FactWeathers primary key ( [Date], [EventKey] ) 		
Go
Alter Table FactWeather Add Constraint
	FK_FactWeather_DimEvents Foreign Key( [EventKey] ) 
	References dbo.DimEvents ( [EventKey] ) 
Go
Alter Table FactWeather Add Constraint
	FK_FactWeather_DimDates Foreign Key( [DateKey] ) 
	References dbo.DimDates ( [DateKey] ) 
Go

-----------------------------------------------------------------------------

-- Step 6) Create a Staging table to hold imported ETL data

CREATE TABLE [WeatherHistoryStaging] 
( [Date] varchar(50)
, [Max TemperatureF] varchar(50)
, [Min TemperatureF] varchar(50)
, [Events] varchar(50)
)