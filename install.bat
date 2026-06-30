@echo off
REM cycle-install.bat — 将循环工作流插件安装到当前项目的 .reasonix/ 中
REM 用法：在目标项目目录中运行
REM   scripts\cycle-install.bat
REM
REM 之后在目标项目里就能用 reasonix cycle 或 /cycle 了

setlocal

set SOURCE_DIR=%~dp0..
set TARGET_DIR=.reasonix

if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%\skills" "%TARGET_DIR%\commands" 2>nul
)

echo 安装循环工作流 skill...
if exist "%SOURCE_DIR%\.reasonix\skills\cyclic-workflow" (
    if not exist "%TARGET_DIR%\skills\cyclic-workflow" mkdir "%TARGET_DIR%\skills\cyclic-workflow"
    copy "%SOURCE_DIR%\.reasonix\skills\cyclic-workflow\SKILL.md" "%TARGET_DIR%\skills\cyclic-workflow\SKILL.md" >nul
    echo   ✅ .reasonix\skills\cyclic-workflow\SKILL.md
) else (
    echo   ⚠ 未找到 source skill（%SOURCE_DIR%\.reasonix\skills\cyclic-workflow）
)

echo 安装 cycle 斜杠命令...
if exist "%SOURCE_DIR%\.reasonix\commands\cycle.md" (
    copy "%SOURCE_DIR%\.reasonix\commands\cycle.md" "%TARGET_DIR%\commands\cycle.md" >nul
    echo   ✅ .reasonix\commands\cycle.md
) else (
    echo   ⚠ 未找到 source command
)

echo 检查 reasonix.toml...
if not exist reasonix.toml (
    echo   注意：当前项目没有 reasonix.toml，请创建或复制一份后才可注册 cycle-bridge 插件
    echo   插件注册方式：在 [[plugins]] 段添加
    echo     name    = "cycle-bridge"
    echo     command = "bin/cycle-bridge.exe"
) else (
    findstr /C:"cycle-bridge" reasonix.toml >nul
    if %errorlevel% neq 0 (
        echo   注意：reasonix.toml 中尚未注册 cycle-bridge 插件
        echo   在 [[plugins]] 段添加：
        echo     name    = "cycle-bridge"
        echo     command = "bin/cycle-bridge.exe"
    ) else (
        echo   ✅ reasonix.toml 已配置 cycle-bridge 插件
    )
)

echo.
echo == 安装完成 ==
echo 现在在目标项目目录中执行：
echo   reasonix cycle "你的目标"
echo 或者在 TUI 中输入：
echo   /cycle 你的目标
echo.
endlocal
pause
