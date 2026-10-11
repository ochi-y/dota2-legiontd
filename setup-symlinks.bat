@echo off
setlocal EnableDelayedExpansion

echo Legion TD Setup

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Requires Administrator
    pause
    exit /b 1
)

:: Define paths
set "contentSource=content"
set "gameSource=game"
set "contentTarget=C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\content\dota_addons\legiontd"
set "gameTarget=C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\legiontd"

:: Check if source directories exist
if not exist "%contentSource%" (
    echo Error: content directory not found
    pause
    exit /b 1
)

if not exist "%gameSource%" (
    echo Error: game directory not found
    pause
    exit /b 1
)

:: Step 1: Delete existing target directories
echo Cleaning target directories...
if exist "%contentTarget%" rmdir /s /q "%contentTarget%"
if exist "%gameTarget%" rmdir /s /q "%gameTarget%"

:: Step 2: Copy directories
echo Copying files...
xcopy "%contentSource%" "%contentTarget%" /E /I /H /Y >nul
if %errorLevel% neq 0 (
    echo Error: Failed to copy content
    pause
    exit /b 1
)

xcopy "%gameSource%" "%gameTarget%" /E /I /H /Y >nul
if %errorLevel% neq 0 (
    echo Error: Failed to copy game
    pause
    exit /b 1
)

:: Step 3: Delete original directories
echo Removing original directories...
rmdir /s /q "%contentSource%"
if %errorLevel% neq 0 (
    echo Error: Failed to remove content
    pause
    exit /b 1
)

rmdir /s /q "%gameSource%"
if %errorLevel% neq 0 (
    echo Error: Failed to remove game
    pause
    exit /b 1
)

:: Step 4: Create directory junctions
echo Creating junctions...

mklink /J "content" "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\content\dota_addons\legiontd" >nul
if %errorLevel% neq 0 (
    echo Error: Failed to create content junction
    pause
    exit /b 1
)

mklink /J "game" "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\legiontd" >nul
if %errorLevel% neq 0 (
    echo Error: Failed to create game junction
    pause
    exit /b 1
)

echo Done!
pause