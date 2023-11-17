---1--- Create DW Base de donnee:
USE [master]
GO

IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'DW_WeatherTracker')
  BEGIN
     -- Close connections to the DW_College database 
    ALTER DATABASE [DW_WeatherTracker] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [DW_WeatherTracker]
  END
GO

CREATE DATABASE [DW_WeatherTracker] ON  PRIMARY 
( NAME = N'DW_WeatherTracker'
, FILENAME = N'C:\temp\DW_WeatherTracker.mdf' )
 LOG ON 
( NAME = N'DW_WeatherTracker_log'
, FILENAME = N'C:\temp\DW_WeatherTracker_log.LDF' )
GO
-----------------------------------------------------------------------------------


