#!/bin/bash

# 检查 gpt_academic 文件夹是否存在
if [ ! -d "gpt_academic" ]; then
    echo "错误：gpt_academic 文件夹不存在，请先运行 download.sh 下载项目。"
    exit 1
fi

cd gpt_academic || { echo "错误：无法进入 gpt_academic 文件夹。"; exit 1; }

# 检查虚拟环境是否存在
if [ ! -d "venv" ]; then
    echo "错误：虚拟环境文件夹 'venv' 不存在，请先运行 download.sh 配置虚拟环境。"
    exit 1
fi

# 激活虚拟环境
source venv/bin/activate || { echo "错误：无法激活虚拟环境。"; exit 1; }

# 检查 main.py 是否存在
if [ ! -f "main.py" ]; then
    echo "错误：main.py 文件不存在，项目可能不完整。"
    exit 1
fi

# 检查 Python 依赖是否安装
if ! pip show -q -r requirements.txt; then
    echo "错误：Python 依赖未安装或安装不完整，请先运行 download.sh 安装依赖。"
    exit 1
fi

# 启动 GPT Academic
echo "正在启动 GPT Academic..."
python main.py || { echo "错误：启动 GPT Academic 失败。"; exit 1; }