@echo off
chcp 65001 >nul
title ☤ Hermes HUD 看板 — Windows 一键安装脚本

setlocal enabledelayedexpansion

echo ═══════════════════════════════════════════════════
echo  ☤ Hermes HUD 看板 — Windows 一键安装
echo  一起动手，10 分钟装好你的 AI 仪表盘
echo ═══════════════════════════════════════════════════
echo.

REM ═══════════════════════════════════════════════════
REM 阶段 1：检查环境
REM ═══════════════════════════════════════════════════

:CHECK_ENV
echo [1/6] 检查你的电脑环境...

REM ── 检查 Node.js ──
set NODE_CMD=
set NODE_VER=
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=1*" %%a in ('node --version') do set NODE_VER=%%a
    echo   ✅ Node.js !NODE_VER!
) else (
    if exist "C:\Program Files\nodejs\node.exe" (
        set "NODE_CMD=C:\Program Files\nodejs\node.exe"
        for /f "tokens=1*" %%a in ('C:\Program Files\nodejs\node.exe --version') do set NODE_VER=%%a
        echo   ✅ Node.js !NODE_VER!（Program Files 下找到）
    ) else (
        echo   ❌ 没找到 Node.js
        echo.
        echo   请先安装 Node.js（免费）：
        echo   打开 https://nodejs.org 下载 LTS 版本
        echo   安装后重新运行本脚本
        echo.
        pause
        exit /b 1
    )
)

REM ── 检查 Node.js 版本 ≥ 18 ──
for /f "tokens=1 delims=v" %%a in ("!NODE_VER!") do set NODE_CLEAN=%%a
for /f "tokens=1 delims=." %%a in ("!NODE_CLEAN!") do set NODE_MAJOR=%%a
if !NODE_MAJOR! LSS 18 (
    echo   ❌ Node.js 版本过低（!NODE_VER!），需要 18+
    echo   请到 https://nodejs.org 下载最新版
    pause
    exit /b 1
)

REM ── 检查 Python ──
set PY_VER=
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2" %%a in ('python --version') do set PY_VER=%%a
    echo   ✅ Python !PY_VER!
) else (
    echo   ❌ 没找到 Python
    echo.
    echo   请先安装 Python 3.11+：
    echo   打开 https://www.python.org/downloads/
    echo   安装时勾选 "Add Python to PATH"
    echo   安装后重新运行本脚本
    echo.
    pause
    exit /b 1
)

REM ── 检查 Python 版本 ≥ 3.11 ──
for /f "tokens=1,2 delims=." %%a in ("!PY_VER!") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
)
if !PY_MAJOR! LSS 3 (
    echo   ❌ Python 版本过低（!PY_VER!），需要 3.11+
    pause
    exit /b 1
)
if !PY_MAJOR! EQU 3 if !PY_MINOR! LSS 11 (
    echo   ❌ Python 版本过低（!PY_VER!），需要 3.11+
    pause
    exit /b 1
)

REM ── 自动检测 Hermes 数据目录 ──
echo.
echo   正在检测 Hermes 数据目录...

set HERMES_DIR=
for %%p in ("D:\Hermes" "%USERPROFILE%\.hermes" "%HOMEDRIVE%%HOMEPATH%\.hermes") do (
    if exist "%%~p\state.db" (
        set "HERMES_DIR=%%~p"
        echo   ✅ 找到 Hermes 数据：%%~p
        goto :FOUND_HERMES
    )
)

:FOUND_HERMES
if not defined HERMES_DIR (
    echo   ⚠ 没找到 Hermes 数据目录
    echo.
    echo   你的 Hermes 装在哪里了？
    echo   通常在 C:\Users\你的用户名\.hermes
    echo.
    set /p HERMES_DIR="请输入路径（例如 C:\Users\我的名字\.hermes）："
    if not defined HERMES_DIR (
        echo   ❌ 没有输入路径，安装中止
        pause
        exit /b 1
    )
    if not exist "!HERMES_DIR!\" (
        echo   ❌ 路径不存在：!HERMES_DIR!
        pause
        exit /b 1
    )
    if not exist "!HERMES_DIR!\state.db" (
        echo   ⚠ 该目录下没有找到 state.db
        echo   确认 Hermes 至少运行过一次。继续安装？（Y/N）
        set /p CONFIRM=
        if /i "!CONFIRM!" neq "Y" (
            echo   安装中止
            pause
            exit /b 1
        )
    )
)

echo.
echo ========================================
echo  环境检查全部通过，准备安装！
echo  Node.js : !NODE_VER!
echo  Python  : !PY_VER!
echo  数据目录: !HERMES_DIR!
echo ========================================
echo.
pause

REM ═══════════════════════════════════════════════════
REM 阶段 2：克隆/更新仓库
REM ═══════════════════════════════════════════════════

:CLONE_REPO
echo.
echo [2/6] 下载 hermes-hudui...

set HUD_DIR=%USERPROFILE%\hermes-hudui

if exist "%HUD_DIR%" (
    echo   目录已存在，尝试更新...
    cd /d "%HUD_DIR%"
    git pull 2>nul
    if %errorlevel% equ 0 (
        echo   ✅ 更新完成
    ) else (
        echo   ⚠ 更新失败，可能是自己修改过文件
        echo   跳过更新，使用已有代码
    )
    goto :INSTALL_DONE
)

REM ── 先尝试 git clone，失败则下载 zip ──
echo   正在从 GitHub 下载...
git clone https://github.com/joeynyc/hermes-hudui.git "%HUD_DIR%" 2>nul
if %errorlevel% equ 0 (
    echo   ✅ 下载完成
) else (
    echo   ⚠ git clone 失败，尝试备用下载方式...
    
    REM ── 下载 zip 方案 ──
    powershell -Command "& { try { $wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://github.com/joeynyc/hermes-hudui/archive/refs/heads/main.zip', '%TEMP%\hermes-hudui.zip'); exit 0 } catch { exit 1 } }"
    if !errorlevel! neq 0 (
        echo   ❌ 下载失败，请检查网络连接
        echo   提示：中国大陆用户可以尝试开代理后重试
        pause
        exit /b 1
    )
    powershell -Command "& { try { Expand-Archive -Path '%TEMP%\hermes-hudui.zip' -DestinationPath '%USERPROFILE%' -Force; Rename-Item -Path '%USERPROFILE%\hermes-hudui-main' -NewName 'hermes-hudui' -ErrorAction SilentlyContinue; exit 0 } catch { exit 1 } }"
    if !errorlevel! neq 0 (
        echo   ❌ 解压失败
        pause
        exit /b 1
    )
    echo   ✅ 下载并解压完成（zip 方式）
)

:INSTALL_DONE
cd /d "%HUD_DIR%"

REM ═══════════════════════════════════════════════════
REM 阶段 3：安装 Python 后端
REM ═══════════════════════════════════════════════════

echo.
echo [3/6] 安装 Python 后端...

if not exist "%HUD_DIR%\venv" (
    echo   正在创建虚拟环境...
    python -m venv "%HUD_DIR%\venv"
    if %errorlevel% neq 0 (
        echo   ❌ 创建虚拟环境失败
        pause
        exit /b 1
    )
    echo   ✅ 虚拟环境已创建
) else (
    echo   ⚡ 虚拟环境已存在，跳过创建
)

echo   正在安装依赖包...
call "%HUD_DIR%\venv\Scripts\activate"
pip install -e "%HUD_DIR%" -q 2>&1
if %errorlevel% neq 0 (
    echo   ❌ 安装依赖失败
    echo   尝试：pip install --upgrade pip
    pause
    exit /b 1
)
echo   ✅ Python 后端安装完成

REM ═══════════════════════════════════════════════════
REM 阶段 4：打 Windows 兼容补丁
REM ═══════════════════════════════════════════════════

echo.
echo [4/6] 安装 Windows 兼容补丁...

set PATCH_OK=0

REM ── memory.py 检查是否需要打补丁 ──
findstr "FcntlStub" "%HUD_DIR%\backend\api\memory.py" >nul 2>&1
if %errorlevel% neq 0 (
    echo   正在修补 memory.py ...
    powershell -ExecutionPolicy Bypass -Command "& {
        $c = Get-Content '%HUD_DIR%\backend\api\memory.py' -Raw
        $patch = @'
import os
import tempfile

import platform
if platform.system() == 'Windows':
    import msvcrt
    class _FcntlStub:
        LOCK_EX = 1
        LOCK_UN = 2
        @staticmethod
        def flock(fd, op):
            if isinstance(fd, int): fno = fd
            else: fno = fd.fileno()
            if op == _FcntlStub.LOCK_EX:
                try: fd.seek(0)
                except: pass
                msvcrt.locking(fno, msvcrt.LK_LOCK, 2147483647)
            elif op == _FcntlStub.LOCK_UN:
                try: fd.seek(0)
                except: pass
                msvcrt.locking(fno, msvcrt.LK_UNLCK, 2147483647)
    fcntl = _FcntlStub()
else:
    import fcntl
'@
        if ($c -match 'import fcntl') {
            $newC = $c -replace 'import fcntl\s*', $patch
            Set-Content '%HUD_DIR%\backend\api\memory.py' $newC -NoNewline
            $c2 = Get-Content '%HUD_DIR%\backend\api\memory.py' -Raw
            $c2 = $c2 -replace 'open\(lock, \"r\"\)', 'open(lock, \"rb\")'
            Set-Content '%HUD_DIR%\backend\api\memory.py' $c2 -NoNewline
        }
    }"
    echo   ✅ memory.py 补丁完成
    set /a PATCH_OK+=1
) else (
    echo   ⚡ memory.py 已打过补丁，跳过
)

REM ── profiles.py 检查是否需要打补丁 ──
findstr "FcntlStub" "%HUD_DIR%\backend\api\profiles.py" >nul 2>&1
if %errorlevel% neq 0 (
    echo   正在修补 profiles.py ...
    powershell -ExecutionPolicy Bypass -Command "& {
        $c = Get-Content '%HUD_DIR%\backend\api\profiles.py' -Raw
        $patch = @'
import os
import re
import tempfile

import platform
if platform.system() == 'Windows':
    import msvcrt
    class _FcntlStub:
        LOCK_EX = 1
        LOCK_UN = 2
        @staticmethod
        def flock(fd, op):
            if isinstance(fd, int): fno = fd
            else: fno = fd.fileno()
            if op == _FcntlStub.LOCK_EX:
                try: fd.seek(0)
                except: pass
                msvcrt.locking(fno, msvcrt.LK_LOCK, 2147483647)
            elif op == _FcntlStub.LOCK_UN:
                try: fd.seek(0)
                except: pass
                msvcrt.locking(fno, msvcrt.LK_UNLCK, 2147483647)
    fcntl = _FcntlStub()
else:
    import fcntl
'@
        if ($c -match 'import fcntl') {
            $newC = $c -replace 'import fcntl\s*', $patch
            Set-Content '%HUD_DIR%\backend\api\profiles.py' $newC -NoNewline
            $c2 = Get-Content '%HUD_DIR%\backend\api\profiles.py' -Raw
            $c2 = $c2 -replace 'open\(lock_path, \"r\", encoding=\"utf-8\"\)', 'open(lock_path, \"rb\")'
            Set-Content '%HUD_DIR%\backend\api\profiles.py' $c2 -NoNewline
        }
    }"
    echo   ✅ profiles.py 补丁完成
    set /a PATCH_OK+=1
) else (
    echo   ⚡ profiles.py 已打过补丁，跳过
)

echo   ✅ Windows 兼容补丁处理完毕

REM ═══════════════════════════════════════════════════
REM 阶段 5：安装 5 套皮肤
REM ═══════════════════════════════════════════════════

echo.
echo [5/6] 安装 5 套自定义皮肤...

set THEMES_FILE=%~dp0themes\custom-themes.css
if exist "%THEMES_FILE%" (
    echo   找到皮肤文件，正在部署...
    copy /Y "%THEMES_FILE%" "%HUD_DIR%\backend\static\assets\" >nul
    if %errorlevel% equ 0 (
        echo   ✅ 5 套皮肤已部署
    ) else (
        echo   ⚠ 皮肤部署失败，但不影响核心功能
    )
) else (
    echo   ⚠ 没找到皮肤文件（%THEMES_FILE%）
    echo   跳过皮肤安装，不影响程序运行
)

REM ═══════════════════════════════════════════════════
REM 阶段 6：构建前端 + 部署
REM ═══════════════════════════════════════════════════

echo.
echo [6/6] 构建前端界面（这步需要耐心等 1-2 分钟）...

cd /d "%HUD_DIR%\frontend"

REM ── npm install ──
echo   安装前端依赖...
set MAX_RETRY=3
set RETRY_COUNT=0

:RETRY_NPM
call npm install --silent 2>&1
if %errorlevel% neq 0 (
    set /a RETRY_COUNT+=1
    if !RETRY_COUNT! LSS !MAX_RETRY! (
        echo   ⚠ 安装超时，第 !RETRY_COUNT! 次重试...
        goto :RETRY_NPM
    )
    echo   ❌ npm install 失败
    echo   试试手动运行：cd %HUD_DIR%\frontend ^&^& npm install
    pause
    exit /b 1
)
echo   ✅ 前端依赖安装完成

REM ── npm run build ──
echo   正在构建（约 30 秒）...
call npm run build 2>&1
if %errorlevel% neq 0 (
    echo   ❌ 构建失败，错误信息如上
    pause
    exit /b 1
)
echo   ✅ 前端构建完成

REM ── 部署静态文件 ──
cd /d "%HUD_DIR%"
if not exist "backend\static\assets" mkdir backend\static\assets
copy /Y frontend\dist\index.html backend\static\ >nul
copy /Y frontend\dist\assets\* backend\static\assets\ >nul
echo   ✅ 静态文件部署完成

REM ═══════════════════════════════════════════════════
REM 收尾：创建启动脚本
REM ═══════════════════════════════════════════════════

echo.
echo ── 创建启动快捷方式 ──

set START_BAT=%USERPROFILE%\Desktop\启动Hermes看板.bat

REM ── 检测皮肤 CSS 路径 ──
set CSS_PATH=%HUD_DIR%\backend\static\assets\custom-themes.css
if exist "!CSS_PATH!" (
    set HAS_CSS=1
) else (
    set HAS_CSS=0
)

(
echo @echo off
echo chcp 65001 ^>nul
echo title ☤ Hermes HUD 看板
echo cd /d "%HUD_DIR%"
echo.
echo REM ── 自动释放端口 ──
echo for /f "tokens=5" %%%%a in ('netstat -ano ^| find ":3001" ^| find "LISTEN"') do ^(
echo   taskkill /F /PID %%%%a 2^>nul
echo ^)
echo timeout /t 1 /nobreak ^>nul
echo.
echo REM ── 启动 ──
echo call "%HUD_DIR%\venv\Scripts\activate"
echo set HERMES_HOME=!HERMES_DIR!
echo echo ☤ Hermes 看板启动中...
echo echo.
echo echo   访问 http://localhost:3001
echo echo   按 t 键切换皮肤
) > "%START_BAT%"

REM ── 如果安装了皮肤，在 bat 里加提示 ──
if !HAS_CSS! equ 1 (
    echo echo   5套自定义皮肤已安装 ^(科技/学院/元宇宙/动漫/国风^) >> "%START_BAT%"
)

echo echo.
echo echo   按 Ctrl+C 关闭服务
echo hermes-hudui --port 3001
echo pause
) >> "%START_BAT%"

echo   ✅ 桌面已生成「启动Hermes看板.bat」

REM ═══════════════════════════════════════════════════
REM 完成
REM ═══════════════════════════════════════════════════

echo.
echo ═══════════════════════════════════════════════════
echo  ✅ 全部完成！
echo.
echo  📌 启动方式
echo     双击桌面「启动Hermes看板.bat」
echo     浏览器打开 http://localhost:3001
echo     按键盘 t 键切换皮肤
echo.
echo  📌 安装位置
echo     %HUD_DIR%
echo.
echo  📌 数据目录
echo     !HERMES_DIR!
echo.
if !HAS_CSS! equ 1 (
echo  📌 已安装 5 套皮肤
echo     深空科技 / 学院典藏 / 元宇宙棱镜 / 动漫次元 / 青绿国风
echo.
)
echo  📌 如需开机自启
echo     在桌面找到「启动Hermes看板.bat」
echo     右键 → 发送到 → 桌面快捷方式
echo     按 Win+R → 输入 shell:startup → 把快捷方式放进去
echo.
echo ═══════════════════════════════════════════════════
echo.
pause
