@echo off
setlocal enabledelayedexpansion

:: 检查 gpt_academic 文件夹是否存在
if not exist "gpt_academic" (
    echo 错误：gpt_academic 文件夹不存在，请先运行 download.bat 下载项目。
    exit /b 1
)

:: 检查是否提供了两个参数
if "%1"=="" (
    echo 使用方法: %0 <API_KEY> <MODEL_NAME>
    exit /b 1
)
if "%2"=="" (
    echo 使用方法: %0 <API_KEY> <MODEL_NAME>
    exit /b 1
)

set API_KEY=%1
set MODEL_NAME=%2

:: 提示用户检查模型是否在允许列表中
echo 请确保你的模型 '%MODEL_NAME%' 在 SiliconFlow 的允许列表中。
echo 截至 2025 年 3 月 3 日，支持的模型"至少"包括：
echo   - deepseek-ai/DeepSeek-R1
echo   - Pro/deepseek-ai/DeepSeek-R1
echo   - deepseek-ai/DeepSeek-V3
echo   - Pro/deepseek-ai/DeepSeek-V3
echo 如有更新请以官方文档为准。
echo 注意：标注Pro模型需要使用充值金额，无法使用赠送金额！
echo 更多信息请参考官方文档：
echo https://docs.siliconflow.cn/cn/api-reference/chat-completions/chat-completions
set /p CONFIRM=是否继续操作？(Y/n):

:: 如果用户输入为空（回车），则默认为 y
if "%CONFIRM%"=="" set CONFIRM=y

if /i not "%CONFIRM%"=="y" (
    echo 操作已取消。
    exit /b 0
)

cd gpt_academic || exit /b 1

:: 如果 config_private.py 不存在，则从 config.py 复制
if not exist "config_private.py" (
    copy config.py config_private.py
    echo 已从 config.py 创建 config_private.py。
) else (
    :: 如果存在，则备份 config_private.py
    set BACKUP_SUFFIX=0
    :find_backup_suffix
    if exist "config_private.py.bak.!BACKUP_SUFFIX!" (
        set /a BACKUP_SUFFIX+=1
        goto find_backup_suffix
    )
    copy config_private.py "config_private.py.bak.!BACKUP_SUFFIX!"
    echo 已备份 config_private.py 为 config_private.py.bak.!BACKUP_SUFFIX!。
)

:: 检查 config_private.py 中是否存在 SILICONFLOW_API_KEY
findstr /i /c:"SILICONFLOW_API_KEY" config_private.py >nul
if errorlevel 1 (
    echo 错误：config_private.py 中未找到 SILICONFLOW_API_KEY！
    echo 请重新拉取 SiliconFlow 支持并确保配置完整。
    exit /b 1
)

:: 显示替换前的配置
echo 替换前的配置：
echo SILICONFLOW_API_KEY 行：
findstr /i /c:"SILICONFLOW_API_KEY" config_private.py
echo LLM_MODEL 行：
findstr /i /c:"LLM_MODEL" config_private.py

:: 方法1：使用临时文件替换（最可靠的方法）
echo 正在使用临时文件方法替换配置...
set temp_file=%temp%\config_private_temp.py
copy /y NUL %temp_file% >nul

:: 逐行处理文件，精确替换目标行
for /f "tokens=*" %%a in (config_private.py) do (
    set line=%%a
    set modified_line=%%a
    if not "!line!"=="" (
        echo !line! | findstr /i /b /c:"SILICONFLOW_API_KEY" >nul
        if !errorlevel!==0 (
            set spaces=!line:~0,%%a!
            set comment=!line:*#=!
            if "!comment!"=="!line!" set comment=
            echo !spaces!SILICONFLOW_API_KEY = "%API_KEY%" !comment! >> %temp_file%
        ) else (
            echo !line! | findstr /i /b /c:"LLM_MODEL" >nul
            if !errorlevel!==0 (
                set spaces=!line:~0,%%a!
                set comment=!line:*#=!
                if "!comment!"=="!line!" set comment=
                echo !spaces!LLM_MODEL = "%MODEL_NAME%" !comment! >> %temp_file%
            ) else (
                echo !line! >> %temp_file%
            )
        )
    )
)

:: 将临时文件内容移回原文件
move /y %temp_file% config_private.py >nul

:: 显示替换后的配置
echo.
echo 替换后的配置：
echo SILICONFLOW_API_KEY 行：
findstr /i /c:"SILICONFLOW_API_KEY" config_private.py
echo LLM_MODEL 行：
findstr /i /c:"LLM_MODEL" config_private.py

:: 验证是否替换成功
echo.
echo 验证配置更新...
findstr /i /c:"SILICONFLOW_API_KEY.*\"%API_KEY%\"" config_private.py >nul
if !errorlevel!==0 (
    echo ✓ SILICONFLOW_API_KEY 已成功更新。
) else (
    echo ✗ 警告：API_KEY 未正确更新。请手动编辑 config_private.py 文件。
)

findstr /i /c:"LLM_MODEL.*\"%MODEL_NAME%\"" config_private.py >nul
if !errorlevel!==0 (
    echo ✓ LLM_MODEL 已成功更新。
) else (
    echo ✗ 警告：MODEL_NAME 未正确更新。请手动编辑 config_private.py 文件。
)

echo 配置更新完成。
exit /b 0