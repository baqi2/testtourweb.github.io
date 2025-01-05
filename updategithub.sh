#!/bin/bash

# 设置工作目录
WORK_DIR="D:/BaiduSyncdisk/04-toursite"

# 确保在正确的目录
cd "$WORK_DIR"

# 配置 git（如果需要的话）
git config --global user.name "baqi2"
git config --global user.email "bobwu1987@gmail.com"

# 设置远程仓库地址
git remote set-url origin https://github.com/baqi2/testtourweb.github.io.git

# 添加所有更改
git add .

# 提交更改
git commit -m "更新网站内容"

# 将 master 分支改名为 main（如果需要的话）
git branch -M main

# 推送到远程仓库
git push -u origin main

echo "更新完成！"
