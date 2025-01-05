cd D:\BaiduSyncdisk\04-toursite

git config --global user.name "baqi2"
git config --global user.email "bobwu1987@gmail.com"

git remote set-url origin https://github.com/baqi2/testtourweb.github.io.git

git add .
git commit -m "更新"

# 将 master 分支改名为 main
git branch -M main

# 推送
git push -u origin main
