@echo off
chcp 65001 >nul 2>&1
setlocal

set SOURCE_DIR=%~dp0
set USER_DIR=%USERPROFILE%\.reasonix

echo === banana4.0 Installer ===
echo.

REM --- Bobanana.md ---
echo [1/4] Bobanana.md ...
copy "%SOURCE_DIR%Bobanana.md" "%USER_DIR%\Bobanana.md" >nul 2>&1
if exist "%USER_DIR%\Bobanana.md" echo   + %USER_DIR%\Bobanana.md
if exist ".reasonix" copy "%SOURCE_DIR%Bobanana.md" ".reasonix\Bobanana.md" >nul 2>&1

REM --- Global skills ---
echo [2/4] Global skills ...
for %%s in (pipeline docs cycle loop install) do (
  if exist "%SOURCE_DIR%skills\%%s\SKILL.md" (
    if not exist "%USER_DIR%\skills\%%s" mkdir "%USER_DIR%\skills\%%s"
    copy "%SOURCE_DIR%skills\%%s\SKILL.md" "%USER_DIR%\skills\%%s\SKILL.md" >nul
    echo   + ~/.reasonix/skills/%%s/SKILL.md
  )
)

REM --- Global commands ---
echo [3/4] Global commands ...
if not exist "%USER_DIR%\commands" mkdir "%USER_DIR%\commands"
if exist "%SOURCE_DIR%commands\cycle.md" copy "%SOURCE_DIR%commands\cycle.md" "%USER_DIR%\commands\cycle.md" >nul
if exist "%USER_DIR%\commands\cycle.md" echo   + %USER_DIR%\commands\cycle.md

REM --- Project-level ---
echo [4/4] Project level ...
if not exist ".reasonix" mkdir ".reasonix"
for %%s in (pipeline docs cycle loop install) do (
  if exist "%SOURCE_DIR%skills\%%s\SKILL.md" (
    if not exist ".reasonix\skills\%%s" mkdir ".reasonix\skills\%%s"
    copy "%SOURCE_DIR%skills\%%s\SKILL.md" ".reasonix\skills\%%s\SKILL.md" >nul
    echo   + .reasonix/skills/%%s/SKILL.md
  )
)
if not exist ".reasonix\commands" mkdir ".reasonix\commands"
if exist "%SOURCE_DIR%commands\cycle.md" copy "%SOURCE_DIR%commands\cycle.md" ".reasonix\commands\cycle.md" >nul

REM --- reasonix.toml check ---
echo.
echo [check] reasonix.toml ...

if not exist reasonix.toml (
    echo   WARN: no reasonix.toml found.
    echo   Create one with:
    echo     [[plugins]]
    echo     name    = "cycle-bridge"
    echo     command = "bin/cycle-bridge.exe"
    echo.
    goto :done
)

findstr /C:"cycle-bridge" reasonix.toml >nul
if %errorlevel% neq 0 (
    echo   WARN: cycle-bridge plugin not configured.
    echo   Add to reasonix.toml:
    echo     [[plugins]]
    echo     name    = "cycle-bridge"
    echo     command = "bin/cycle-bridge.exe"
) else (
    echo   OK: cycle-bridge plugin found.
)

:done
echo.
echo === Done ===
echo.
echo Usage:
echo   reasonix chat  ->  /pipeline your goal
echo   terminal       ->  reasonix cycle "your goal"
echo.
echo To update later: git pull + install.bat
echo.
endlocal
pause
