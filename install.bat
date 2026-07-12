@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

set SOURCE_DIR=%~dp0
set USER_DIR=%USERPROFILE%\.reasonix

echo === banana4.0 Installer ===
echo.

echo [1/5] Bobanana.md ...
copy /Y "%SOURCE_DIR%Bobanana.md" "%USER_DIR%\Bobanana.md" >nul
if exist "%USER_DIR%\Bobanana.md" echo   + %USER_DIR%\Bobanana.md
if exist ".reasonix" copy /Y "%SOURCE_DIR%Bobanana.md" ".reasonix\Bobanana.md" >nul

echo [2/5] Global skills ...
for %%s in (pipeline docs cycle loop install) do (
  if exist "%SOURCE_DIR%skills\%%s\SKILL.md" (
    if not exist "%USER_DIR%\skills\%%s" mkdir "%USER_DIR%\skills\%%s" >nul
    copy /Y "%SOURCE_DIR%skills\%%s\SKILL.md" "%USER_DIR%\skills\%%s\SKILL.md" >nul
    if exist "%USER_DIR%\skills\%%s\SKILL.md" echo   + ~/.reasonix/skills/%%s/SKILL.md
  )
)

echo [3/5] Global commands ...
if not exist "%USER_DIR%\commands" mkdir "%USER_DIR%\commands" >nul
if exist "%SOURCE_DIR%commands\cycle.md" copy /Y "%SOURCE_DIR%commands\cycle.md" "%USER_DIR%\commands\cycle.md" >nul
if exist "%USER_DIR%\commands\cycle.md" echo   + %USER_DIR%\commands\cycle.md
copy /Y "%USER_DIR%\commands\cycle.md" "%USER_DIR%\commands\pipeline.md" >nul
if exist "%USER_DIR%\commands\pipeline.md" echo   + %USER_DIR%\commands\pipeline.md

echo [4/5] Global binaries ...
if not exist "%USER_DIR%\bin" mkdir "%USER_DIR%\bin" >nul
if exist "%SOURCE_DIR%bin\cycle-bridge.exe" copy /Y "%SOURCE_DIR%bin\cycle-bridge.exe" "%USER_DIR%\bin\cycle-bridge.exe" >nul
if exist "%USER_DIR%\bin\cycle-bridge.exe" echo   + ~/.reasonix/bin/cycle-bridge.exe

echo [5/5] Project level ...
if not exist ".reasonix" mkdir ".reasonix"
for %%s in (pipeline docs cycle loop install) do (
  if exist "%SOURCE_DIR%skills\%%s\SKILL.md" (
    if not exist ".reasonix\skills\%%s" mkdir ".reasonix\skills\%%s" >nul
    copy /Y "%SOURCE_DIR%skills\%%s\SKILL.md" ".reasonix\skills\%%s\SKILL.md" >nul
    if exist ".reasonix\skills\%%s\SKILL.md" echo   + .reasonix/skills/%%s/SKILL.md
  )
)
if not exist ".reasonix\commands" mkdir ".reasonix\commands" >nul
if exist "%SOURCE_DIR%commands\cycle.md" copy /Y "%SOURCE_DIR%commands\cycle.md" ".reasonix\commands\cycle.md" >nul
copy /Y ".reasonix\commands\cycle.md" ".reasonix\commands\pipeline.md" >nul

echo.
echo [check] reasonix.toml ...
if exist reasonix.toml (
  findstr /C:"cycle-bridge" reasonix.toml >nul
  if errorlevel 1 (
    echo   WARN: cycle-bridge not in reasonix.toml.
    echo   Add:
    echo     [[plugins]]
    echo     name    = "cycle-bridge"
    echo     command = "%USERPROFILE%\.reasonix\bin\cycle-bridge.exe"
  ) else (
    echo   OK: cycle-bridge plugin found.
    findstr /C:"cycle-bridge" reasonix.toml | findstr /C:":\" >nul
    if not errorlevel 1 (
      echo   NOTE: path is absolute, may break in other projects.
      echo   Recommended: %USERPROFILE%\.reasonix\bin\cycle-bridge.exe
    )
  )
) else (
  echo   No reasonix.toml found. Create one with:
  echo     [[plugins]]
  echo     name    = "cycle-bridge"
  echo     command = "%USERPROFILE%\.reasonix\bin\cycle-bridge.exe"
)

:done
echo.
echo === Done ===
echo === Usage: reasonix chat -^> /pipeline your goal ===
echo === To update: git pull + install.bat ===
echo.
pause
