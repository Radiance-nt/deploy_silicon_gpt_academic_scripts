#!/bin/bash

# 检查 gpt_academic 文件夹是否存在
if [ ! -d "gpt_academic" ]; then
    echo "错误：gpt_academic 文件夹不存在，请先运行 download.sh 下载项目。"
    exit 1
fi

# 检查是否提供了两个参数
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <API_KEY> <MODEL_NAME>"
    exit 1
fi

API_KEY=$1
MODEL_NAME=$2

# 提示用户检查模型是否在允许列表中
echo "请确保你的模型 '$MODEL_NAME' 在 SiliconFlow 的允许列表中。"
echo "截至 2025 年 3 月 3 日，支持的模型"至少"包括："
echo "  - deepseek-ai/DeepSeek-R1"
echo "  - Pro/deepseek-ai/DeepSeek-R1"
echo "  - deepseek-ai/DeepSeek-V3"
echo "  - Pro/deepseek-ai/DeepSeek-V3"
echo "如有更新请以官方文档为准。"
echo "注意：标注Pro模型需要使用充值金额，无法使用赠送金额！"
echo "更多信息请参考官方文档："
echo "https://docs.siliconflow.cn/cn/api-reference/chat-completions/chat-completions"
echo "是否继续操作？(Y/n)"
read -r CONFIRM

# 如果用户输入为空（回车），则默认为 y
if [ -z "$CONFIRM" ]; then
    CONFIRM="y"
fi

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "操作已取消。"
    exit 0
fi

cd gpt_academic || exit 1

# 如果 config_private.py 不存在，则从 config.py 复制
if [ ! -f "config_private.py" ]; then
    cp config.py config_private.py
    echo "已从 config.py 创建 config_private.py。"
else
    # 如果存在，则备份 config_private.py
    BACKUP_SUFFIX=0
    while [ -f "config_private.py.bak.$BACKUP_SUFFIX" ]; do
        BACKUP_SUFFIX=$((BACKUP_SUFFIX + 1))
    done
    cp config_private.py "config_private.py.bak.$BACKUP_SUFFIX"
    echo "已备份 config_private.py 为 config_private.py.bak.$BACKUP_SUFFIX。"
fi

# 检查 config_private.py 中是否存在 SILICONFLOW_API_KEY
if ! grep -q "SILICONFLOW_API_KEY" config_private.py; then
    echo "错误：config_private.py 中未找到 SILICONFLOW_API_KEY！"
    echo "请重新拉取 SiliconFlow 支持并确保配置完整。"
    exit 1
fi

# 显示替换前的配置
echo "替换前的配置："
echo "SILICONFLOW_API_KEY 行："
grep "SILICONFLOW_API_KEY" config_private.py
echo "LLM_MODEL 行："
grep "LLM_MODEL" config_private.py

# 方法1：使用临时文件替换（最可靠的方法）
echo "正在使用临时文件方法替换配置..."
temp_file=$(mktemp)

# 逐行处理文件，精确替换目标行
while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*SILICONFLOW_API_KEY[[:space:]]*= ]]; then
        # 保留前导空格、变量名、等号，以及尾部注释（如果有）
        spaces=$(echo "$line" | sed -E 's/^([[:space:]]*)SILICONFLOW_API_KEY.*/\1/')
        comment=$(echo "$line" | grep -o '#.*$' || echo "")
        echo "${spaces}SILICONFLOW_API_KEY = \"$API_KEY\" $comment" >> "$temp_file"
    elif [[ $line =~ ^[[:space:]]*LLM_MODEL[[:space:]]*= ]]; then
        # 保留前导空格、变量名、等号，以及尾部注释（如果有）
        spaces=$(echo "$line" | sed -E 's/^([[:space:]]*)LLM_MODEL.*/\1/')
        comment=$(echo "$line" | grep -o '#.*$' || echo "")
        echo "${spaces}LLM_MODEL = \"$MODEL_NAME\" $comment" >> "$temp_file"
    else
        echo "$line" >> "$temp_file"
    fi
done < config_private.py

# 将临时文件内容移回原文件
mv "$temp_file" config_private.py

# 显示替换后的配置
echo -e "\n替换后的配置："
echo "SILICONFLOW_API_KEY 行："
grep "SILICONFLOW_API_KEY" config_private.py
echo "LLM_MODEL 行："
grep "LLM_MODEL" config_private.py

# 验证是否替换成功
echo -e "\n验证配置更新..."
if grep -q "SILICONFLOW_API_KEY.*\"$API_KEY\"" config_private.py; then
    echo "✓ SILICONFLOW_API_KEY 已成功更新。"
else
    echo "✗ 警告：API_KEY 未正确更新。请手动编辑 config_private.py 文件。"
fi

if grep -q "LLM_MODEL.*\"$MODEL_NAME\"" config_private.py; then
    echo "✓ LLM_MODEL 已成功更新。"
else
    echo "✗ 警告：MODEL_NAME 未正确更新。请手动编辑 config_private.py 文件。"
fi

echo "配置更新完成。"