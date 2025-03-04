@echo off
setlocal enabledelayedexpansion

:: 检查 gpt_academic 文件夹是否存在
if not exist "gpt_academic" (
    echo 错误：gpt_academic 文件夹不存在，请先运行 download.bat 下载项目。
    exit /b 1
)

:: 进入 gpt_academic 文件夹
cd gpt_academic || (
    echo 错误：无法进入 gpt_academic 文件夹。
    exit /b 1
)

:: 检查虚拟环境是否存在
if not exist "venv" (
    echo 错误：虚拟环境文件夹 'venv' 不存在，请先运行 download.bat 配置虚拟环境。
    exit /b 1
)

:: 激活虚拟环境
call venv\Scripts\activate || (
    echo 错误：无法激活虚拟环境。
    exit /b 1
)

:: 检查 main.py 是否存在
if not exist "main.py" (
    echo 错误：main.py 文件不存在，项目可能不完整。
    exit /b 1
)

:: 检查 Python 依赖是否安装
pip show -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo 错误：Python 依赖未安装或安装不完整，请先运行 download.bat 安装依赖。
    exit /b 1
)

:: 启动 GPT Academic
echo 正在启动 GPT Academic...
python main.py || (
    echo 错误：启动 GPT Academic 失败。
    exit /b 1
)

exit /b 0