# Set working directory
$WORK_DIR = "D:\BaiduSyncdisk\04-toursite"

# Change to correct directory
Set-Location $WORK_DIR

Write-Host "Updating Git repository..."

# Configure git
git config --global user.name "baqi2"
git config --global user.email "bobwu1987@gmail.com"

# Configure git with SSL verification and timeout settings
git config --global http.sslVerify false
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 300

# Set remote repository URL
git remote set-url origin https://github.com/baqi2/testtourweb.github.io.git

# Add all changes
git add .

# Commit changes
git commit -m "Update website content-v1.0"

# Rename master branch to main
git branch -M main

# Push to remote repository with retry logic
$maxRetries = 3
$retryCount = 0
$success = $false
$proxyPorts = @(1081, 1080, 10808, 10809)  # Define the ports to try
$usedPorts = @()  # Keep track of used ports

while (-not $success -and $retryCount -lt $maxRetries) {
    $pushResult = git push -u origin main 2>&1
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    } else {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "Push failed, retrying with system proxy... (Attempt $retryCount/$maxRetries)" -ForegroundColor Yellow
            
            # Get system proxy settings and configure git
            $proxy = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
            if ($proxy) {
                Write-Host "Using system proxy: $proxy" -ForegroundColor Yellow
                git config --global http.proxy "http://$proxy"
                git config --global https.proxy "http://$proxy"
            }

            # Try additional ports if not already used
            foreach ($port in $proxyPorts) {
                if (-not $usedPorts.Contains($port)) {
                    Write-Host "Retrying with port $port..." -ForegroundColor Yellow
                    git config --global http.proxy "http://127.0.0.1:$port"
                    git config --global https.proxy "http://127.0.0.1:$port"
                    $pushResult = git push -u origin main 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $success = $true
                        break
                    }
                    $usedPorts += $port  # Mark this port as used
                }
            }
            
            # Additional retry configurations
            git config --global core.compression 0
            git config --global http.postBuffer 524288000
        }
    }
}

if (-not $success) {
    Write-Host "Push failed! Retried $maxRetries times. Last error message:" -ForegroundColor Red
    Write-Host $pushResult -ForegroundColor Red
    
    # Clean up proxy settings
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    
    exit 1
}

# Clean up proxy settings if successful
git config --global --unset http.proxy
git config --global --unset https.proxy

Write-Host "Update completed successfully!" -ForegroundColor Green