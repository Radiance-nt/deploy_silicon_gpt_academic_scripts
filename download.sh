#!/bin/bash

# 检查 gpt_academic 文件夹是否存在
if [ ! -d "gpt_academic" ]; then
    echo "正在克隆 gpt_academic 仓库..."
    git clone https://github.com/binary-husky/gpt_academic
    cd gpt_academic
else
    echo "gpt_academic 文件夹已存在，跳过克隆步骤。"
    cd gpt_academic
fi

# 添加 amonysh 远程仓库并拉取更新

git remote add amonysh https://github.com/samonysh/gpt_academic 2>/dev/null || echo "远程仓库 amonysh 已存在，跳过添加步骤。"

echo "正在从 amonysh 拉取 silicon flow 硅基流动支持..."
git pull amonysh master --no-edit

# 检查 git pull 是否成功
if [ $? -ne 0 ]; then
    echo "错误：拉取失败！请检查网络连接或远程仓库地址是否正确。"
    exit 1
fi

echo "仓库下载成功！"

echo "开始配置 Python 虚拟环境..."

# 创建并激活 Python 虚拟环境
python3 -m venv venv
source venv/bin/activate

# 提示用户默认使用中科大源安装环境
echo "默认使用中科大源安装依赖包..."
pip install -r requirements.txt -i https://pypi.mirrors.ustc.edu.cn/simple/

echo "环境配置完成！"
echo "所有设置已成功完成！"