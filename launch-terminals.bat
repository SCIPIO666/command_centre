@echo off
if "%~1"=="" (echo Usage: launch-terminals.bat PROJECT_NAME & pause & exit /b 1)
powershell -ExecutionPolicy Bypass -File "%~dp0command_centre.ps1" %1 cmd