@echo off
REM Set environment for SAP MaxDB - agar GUI (Database Analyzer) bisa jalan
set "MAXDBROOT=C:\Program Files\sdb\MaxDB"
set "PATH=%MAXDBROOT%\bin;%MAXDBROOT%\runtime;%PATH%"
cd /d "%MAXDBROOT%\bin"

REM Jalankan Database Analyzer (tool GUI untuk monitoring/analisis)
start "" "%MAXDBROOT%\bin\dbanalyzer.exe" %*
