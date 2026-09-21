@echo off
setlocal EnableDelayedExpansion
title Command Centre

cd /d "%~dp0"

REM ---------- List projects from projects.json ----------
set "PROJECTS="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Get-Content '%~dp0projects.json' -Raw | ConvertFrom-Json).PSObject.Properties.Name"`) do (
    set "PROJECTS=!PROJECTS! %%A"
)

if "%PROJECTS%"=="" (
    echo No projects found in projects.json
    pause
    exit /b 1
)

:menu
cls
echo ============================================================
echo                     COMMAND CENTRE
echo ============================================================
echo  Projects: %PROJECTS%
echo.
set /p "PROJ=Enter project name: "

if "%PROJ%"=="" goto menu

echo.
echo  Select mode:
echo    [1] all       - every tab
echo    [2] auto      - services only
echo    [3] cmd       - terminals only
echo.
set /p "MODECHOICE=Choice [1-3]: "

if "%MODECHOICE%"=="1" set "MODE=all"
if "%MODECHOICE%"=="2" set "MODE=auto"
if "%MODECHOICE%"=="3" set "MODE=cmd"
if not defined MODE set "MODE=all"

echo.
echo Launching %PROJ% (mode: %MODE%)...
powershell -ExecutionPolicy Bypass -File "%~dp0command_centre.ps1" %PROJ% %MODE%

endlocal