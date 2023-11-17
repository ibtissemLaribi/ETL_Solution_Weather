Use [DW_WeatherTracker]
GO

--1) Drop Foreign Keys 
Alter Table [dbo].[FactWeather] Drop Constraint [FK_FactWeather_DimDates]
Alter Table [dbo].[FactWeather] Drop Constraint [FK_FactWeather_DimEvents]
Go
----------------------------------------------------------------------
--2) Clear all tables data warehouse tables and reset their Identity Auto Number 
Truncate Table [dbo].[FactWeather]
Truncate Table [dbo].[DimEvents]
Truncate Table [dbo].[DimDates]
go

select * from [dbo].[FactWeather]
select * from [dbo].[DimEvents]
select * from [dbo].[DimDates]

-------------------------------------------------------------
--3) Insert into DimEvents

Insert into [dbo].[DimEvents]
Select distinct
  [EventName] = Cast( Events as nVarchar(50) )
  
From [dbo].[WeatherHistoryStaging]
Go

select * from [dbo].[DimEvents]
go
-----------------------------------------------------------------
-- Verifier le Format_Date:

GO
SET DATEFORMAT mdy; 
go

--4) Create values for DimDates:

-- Create variables to hold the start and end date
Declare @StartDate datetime = '01/01/2011'
Declare @EndDate datetime = '01/01/2012' 

-- Use a while loop to add dates to the table
Declare @DateInProcess datetime
Set @DateInProcess = @StartDate

While @DateInProcess <= @EndDate
 Begin
 -- Add a row into the date dimension table for this date
 Insert Into DimDates 
 ( [Date], [DateName], [Month], [MonthName], [Quarter], [QuarterName], [Year], [YearName] )
 Values ( 
  @DateInProcess -- [Date]
  , DateName( weekday, @DateInProcess )  -- [DateName]  
  , Month( @DateInProcess ) -- [Month]   
  , DateName( month, @DateInProcess ) -- [MonthName]
  , DateName( quarter, @DateInProcess ) -- [Quarter]
  , 'Q' + DateName( quarter, @DateInProcess ) + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50) ) -- [QuarterName] 
  , Year( @DateInProcess )
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [YearName] 
  
  )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End
-- 2e) Add additional lookup values to DimDates

Set Identity_Insert [dbo].[DimDates] On

Insert Into [dbo].[DimDates] 
  ( [DateKey]
  , [Date]
  , [DateName]
  , [Month]
  , [MonthName]
  , [Quarter]
  , [QuarterName]
  , [Year], [YearName] )
  Select 
    [DateKey] = -1
  , [Date] =  Cast('01/01/1900' as nVarchar(50) )
  , [DateName] = Cast('Unknown Day' as nVarchar(50) )
  , [Month] = -1
  , [MonthName] = Cast('Unknown Month' as nVarchar(50) )
  , [Quarter] =  -1
  , [QuarterName] = Cast('Unknown Quarter' as nVarchar(50) )
  , [Year] = -1
  , [YearName] = Cast('Unknown Year' as nVarchar(50) )
  Union
  Select 
    [DateKey] = -2
  , [Date] = Cast('02/01/1900' as nVarchar(50) )
  , [DateName] = Cast('Corrupt Day' as nVarchar(50) )
  , [Month] = -2
  , [MonthName] = Cast('Corrupt Month' as nVarchar(50) )
  , [Quarter] =  -2
  , [QuarterName] = Cast('Corrupt Quarter' as nVarchar(50) )
  , [Year] = -2
  , [YearName] = Cast('Corrupt Year' as nVarchar(50) )

  Set Identity_Insert [DW_WeatherTracker].[dbo].[DimDates] Off
Go

select * from DimDates
----------------------------------------------------
--5) Create values for FactWeather:

Insert into dbo.FactWeather
Select 
	EventKey = dbo.DimEvents.EventKey,
	DateKey=  dbo.DimDates.DateKey,
	MaxTemp = dbo.WeatherHistoryStaging.[Max TemperatureF],
	MinTemp = dbo.WeatherHistoryStaging.[Min TemperatureF]
From 
	dbo.WeatherHistoryStaging
JOIN 
	dbo.DimEvents
  On 
	dbo.WeatherHistoryStaging.Events = dbo.DimEvents.EventName
JOIN 
	dbo.DimDates
  On 
	dbo.WeatherHistoryStaging.Date = dbo.DimDates.Date
go

select * from FactWeather
go
----------------------------------
--6) Re-Add the Foreign Keys:

Alter Table dbo.FactWeather With Check Add Constraint [FK_FactWeather_DimDates] 
Foreign Key (DateKey) References dbo.DimDates (Datekey)

Alter Table dbo.FactWeather With Check Add Constraint [FK_FactWeather_DimEvents] 
Foreign Key (EventKey) References dbo.DimEvents (Eventkey)
----------------------------------------------------------------
		------------FIN---------------------






