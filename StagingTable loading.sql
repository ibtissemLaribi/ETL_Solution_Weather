Use [DW_WeatherTracker]
go

BULK INSERT WeatherHistoryStaging
FROM 'C:\temp\donneesTemperatures.txt' --location with filename
WITH
(
FIELDTERMINATOR = '\t',
ROWTERMINATOR = '\n',
FIRSTROW = 2
)
GO

select * from WeatherHistoryStaging
go