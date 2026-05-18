@echo off
chcp 65001 >nul
title ☤ Hermes 看板 — 开机自启设置

echo ════════════════════════════════════════════
echo  ☤ Hermes 看板 — 设置开机自启
echo ════════════════════════════════════════════
echo.
echo  这个脚本会在你的电脑开机时自动启动看板
echo  以后不用手动双击 bat 文件了
echo.

REM ── 检测看板安装位置 ──
set HUD_DIR=%USERPROFILE%\hermes-hudui
if not exist "%HUD_DIR%\backend\main.py" (
    echo   ⚠ 没找到 hermes-hudui 安装
    echo   请先运行 install-windows.bat 安装
    pause
    exit /b 1
)

echo  看板路径: %HUD_DIR%

REM ── 自动检测 Hermes 数据目录 ──
set HERMES_DIR=
for %%p in ("D:\Hermes" "%USERPROFILE%\.hermes") do (
    if exist "%%~p\state.db" set "HERMES_DIR=%%~p"
)
if not defined HERMES_DIR (
    echo   请输入你的 Hermes 数据目录路径
    echo   （默认 %USERPROFILE%\.hermes）
    set /p HERMES_DIR="路径（直接回车用默认）: "
    if not defined HERMES_DIR set "HERMES_DIR=%USERPROFILE%\.hermes"
)

echo  数据目录: %HERMES_DIR%
echo.

REM ── 创建 VBS 后台启动脚本（隐藏 CMD 窗口） ──
set VBS_FILE=%HUD_DIR%\start-hermes-hudui-background.vbs
(
echo Set WshShell = CreateObject("WScript.Shell"^)
echo WshShell.Run "cmd /c cd /d ""%HUD_DIR%"" ^&^& call ""%HUD_DIR%\venv\Scripts\activate"" ^&^& set HERMES_HOME=%HERMES_DIR:\=\\% ^&^& hermes-hudui --port 3001", 0, False
) > "%VBS_FILE%"

REM ── 注册 Windows 任务计划程序 ──
echo  正在注册开机自启任务...
schtasks /create /tn "HermesHUD启动" /tr "wscript.exe \"%VBS_FILE%\"" /sc onlogon /rl limited /f >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo ════════════════════════════════════════════
    echo  ✅ 开机自启设置成功！
    echo.
    echo  下次开机后，看板会自动启动
    echo  直接打开 http://localhost:3001 即可
    echo.
    echo  如果想取消开机自启：
    echo   按 Win+R → 输入 taskschd.msc
    echo   找到「HermesHUD启动」→ 右键删除
    echo ════════════════════════════════════════════
) else (
    echo.
    echo   ⚠ 注册失败，试试手动设置：
    echo   1. 按 Win+R → 输入 shell:startup
    echo   2. 把「启动Hermes看板.bat」的快捷方式放进去
    echo   3. 或者以管理员身份运行本脚本
)

echo.
pause
