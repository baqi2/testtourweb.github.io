# Set working directory
$WORK_DIR = "D:\BaiduSyncdisk\04-toursite"

# Change to correct directory
Set-Location $WORK_DIR

Write-Host "Updating Git repository..."

# Configure git
git config --global user.name "baqi2"
git config --global user.email "bobwu1987@gmail.com"

# Set remote repository URL
git remote set-url origin https://github.com/baqi2/testtourweb.github.io.git

# Add all changes
git add .

# Commit changes
git commit -m "Update website content"

# Rename master branch to main
git branch -M main

# Push to remote repository
git push -u origin main

Write-Host "Update completed!" 