@echo off
REM install.bat — 将循环工作流插件装到 全局 ~/.reasonix/ + 当前项目
REM 用法：在目标项目目录中运行
REM   ..\bobanana4.0\install.bat
REM
REM 装一次，以后所有项目都能用 /cycle
REM 换项目后只需 /skill cycle-install（全局 skill 已就绪）

setlocal

set SOURCE_DIR=%~dp0
set USER_DIR=%USERPROFILE%\.reasonix

echo 🍌 banana4.0 — 安装循环工作流插件
echo ====================================
echo.

REM ── 安装到全局（所有项目可见） ──────────────────────

echo [1/3] 安装全局 skill...
if not exist "%USER_DIR%\skills\cyclic-workflow" mkdir "%USER_DIR%\skills\cyclic-workflow"
copy "%SOURCE_DIR%skills\cyclic-workflow\SKILL.md" "%USER_DIR%\skills\cyclic-workflow\SKILL.md" >nul
echo   ✅ ~\.reasonix\skills\cyclic-workflow\SKILL.md

if not exist "%USER_DIR%\skills\cycle-install" mkdir "%USER_DIR%\skills\cycle-install"
copy "%SOURCE_DIR%skills\cycle-install\SKILL.md" "%USER_DIR%\skills\cycle-install\SKILL.md" >nul
echo   ✅ ~\.reasonix\skills\cycle-install\SKILL.md
if not exist "%USER_DIR%\skills\iterative-loop" mkdir "%USER_DIR%\skills\iterative-loop"
copy "%SOURCE_DIR%skills\iterative-loop\SKILL.md" "%USER_DIR%\skills\iterative-loop\SKILL.md" >nul
echo   ✅ ~\.reasonix\skills\iterative-loop\SKILL.md

echo [2/3] 安装全局命令...
if not exist "%USER_DIR%\commands" mkdir "%USER_DIR%\commands"
copy "%SOURCE_DIR%commands\cycle.md" "%USER_DIR%\commands\cycle.md" >nul
echo   ✅ ~\.reasonix\commands\cycle.md

REM ── 安装到当前项目（可选但有更好） ──────────────────

echo [3/3] 安装到当前项目...
if not exist ".reasonix" mkdir ".reasonix"
if not exist ".reasonix\skills\cyclic-workflow" mkdir ".reasonix\skills\cyclic-workflow"
copy "%SOURCE_DIR%skills\cyclic-workflow\SKILL.md" ".reasonix\skills\cyclic-workflow\SKILL.md" >nul
echo   ✅ .reasonix\skills\cyclic-workflow\SKILL.md
if not exist ".reasonix\skills\cycle-install" mkdir ".reasonix\skills\cycle-install"
copy "%SOURCE_DIR%skills\cycle-install\SKILL.md" ".reasonix\skills\cycle-install\SKILL.md" >nul
echo   ✅ .reasonix\skills\cycle-install\SKILL.md
if not exist ".reasonix\skills\iterative-loop" mkdir ".reasonix\skills\iterative-loop"
copy "%SOURCE_DIR%skills\iterative-loop\SKILL.md" ".reasonix\skills\iterative-loop\SKILL.md" >nul
echo   ✅ .reasonix\skills\iterative-loop\SKILL.md

if not exist ".reasonix\commands" mkdir ".reasonix\commands"
copy "%SOURCE_DIR%commands\cycle.md" ".reasonix\commands\cycle.md" >nul
echo   ✅ .reasonix\commands\cycle.md

REM ── 检查 reasonix.toml 插件配置 ────────────────────

echo.
echo [检查] reasonix.toml...

if not exist reasonix.toml (
    echo   ⚠ 当前项目没有 reasonix.toml
    echo     创建后添加：
    echo       [[plugins]]
    echo       name    = "cycle-bridge"
    echo       command = "bin/cycle-bridge.exe"
    echo.
    goto :done
)

findstr /C:"cycle-bridge" reasonix.toml >nul
if %errorlevel% neq 0 (
    echo   ⚠ 未找到 cycle-bridge 插件配置
    echo     在 reasonix.toml 的 [[plugins]] 段添加：
    echo       name    = "cycle-bridge"
    echo       command = "bin/cycle-bridge.exe"
) else (
    echo   ✅ 已配置 cycle-bridge 插件
)

:done
echo.
echo ====================================
echo 🍌 安装完成！
echo.
echo 现在在任何 Reasonix 前端中输入：
echo   /cycle 你的目标              ← 三阶段大循环
echo   /skill iterative-loop ...    ← 🆕 小循环逼近
echo.
echo 终端中运行：
echo   reasonix cycle "你的目标"
echo.
echo 【更新】以后当 bobanana4.0 发布新版本时：
echo   1. git pull 拉取最新仓库
echo   2. 重新运行 install.bat（覆盖更新已有文件，新增 skill 自动补上）
echo.
endlocal
pause
