# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
cd $scriptPath

# Create images directory if it doesn't exist
if (-not (Test-Path "images")) {
    New-Item -ItemType Directory -Path "images"
}
cd images

# Get search topic through interaction
$defaultQuery = "nature"
$searchQuery = Read-Host "Please enter search topic (press Enter for default '$defaultQuery')"
if ([string]::IsNullOrWhiteSpace($searchQuery)) {
    $searchQuery = $defaultQuery
}

# Define search parameters
$imageCount = 10  # Default to download 10 images
$targetWidth = 800  # Suitable width for Word documents
$targetHeight = 600  # Suitable height for Word documents

# Proxy settings
$useProxy = $false
$proxyPorts = @(1081, 1080, 10809, 10808, 7890)
$proxyHost = "127.0.0.1"
$workingProxy = $null

# Try to find working proxy
Write-Host "Testing proxy connections..."
foreach ($port in $proxyPorts) {
    $proxyAddress = "http://${proxyHost}:${port}"
    try {
        $testRequest = [System.Net.WebRequest]::Create("https://www.google.com")
        $testRequest.Proxy = [System.Net.WebProxy]::new($proxyAddress)
        $testRequest.Timeout = 5000  # 5 seconds timeout
        $response = $testRequest.GetResponse()
        $response.Close()
        $workingProxy = $proxyAddress
        Write-Host "Found working proxy at: $workingProxy"
        break
    }
    catch {
        Write-Host "Proxy $proxyAddress not working, trying next..."
        continue
    }
}

if (-not $workingProxy) {
    Write-Host "No working proxy found, trying system proxy..."
    try {
        $systemProxy = [System.Net.WebRequest]::GetSystemWebProxy()
        $workingProxy = $systemProxy.GetProxy("https://www.google.com").ToString()
        Write-Host "Using system proxy: $workingProxy"
    }
    catch {
        Write-Host "System proxy not available"
        $useProxy = $false
    }
}

Write-Host "Start downloading '$searchQuery' themed images, total $imageCount images..."

# Function to get image URLs from Pexels
function Get-ImageUrls {
    param(
        [string]$Query,
        [int]$Count
    )
    
    $urls = @()
    
    # Using Pexels API
    $pexelsApiKey = "Th4VPaQgTVtyl8HJiyqRfSU7R1nOl6QBD91hJfPZogkA8B7cwhfNuI65"  # Get from https://www.pexels.com/api/
    $encodedQuery = [uri]::EscapeDataString($Query)
    $apiUrl = "https://api.pexels.com/v1/search?query=$encodedQuery&per_page=$Count"
    
    try {
        $headers = @{
            "Authorization" = $pexelsApiKey
        }
        
        Write-Host ("Searching for images with query: {0}" -f $Query)
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
        
        foreach ($photo in $response.photos) {
            # Get the closest size to our target dimensions
            $urls += $photo.src.large
        }
    }
    catch {
        Write-Host ("Error searching Pexels: {0}" -f $_.Exception.Message)
    }
    
    return $urls
}

# Function to resize image
function Resize-Image {
    param(
        [string]$ImagePath,
        [int]$Width,
        [int]$Height
    )
    
    try {
        Add-Type -AssemblyName System.Drawing
        
        $img = [System.Drawing.Image]::FromFile($ImagePath)
        $ratioW = $Width / $img.Width
        $ratioH = $Height / $img.Height
        $ratio = if ($ratioW -lt $ratioH) { $ratioW } else { $ratioH }
        
        $newWidth = [int]($img.Width * $ratio)
        $newHeight = [int]($img.Height * $ratio)
        
        $bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graph = [System.Drawing.Graphics]::FromImage($bmp)
        
        $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        # Save the resized image, first dispose of the original file
        $img.Dispose()
        $graph.Dispose()
        
        # Save with new filename to avoid file lock issues
        $newPath = [System.IO.Path]::ChangeExtension($ImagePath, "resized.jpg")
        $bmp.Save($newPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $bmp.Dispose()
        
        # Replace original with resized version
        Remove-Item $ImagePath
        Rename-Item $newPath $ImagePath
        
        Write-Host "Image resized successfully"
    }
    catch {
        Write-Host ("Error resizing image: {0}" -f $_.Exception.Message)
    }
}

# Get and process images
$imageUrls = Get-ImageUrls -Query $searchQuery -Count $imageCount

if ($imageUrls) {
    $index = 1
    foreach ($imageUrl in $imageUrls) {
        $fileName = "photo_${searchQuery}_$index.jpg"
        
        # Check if file exists
        if (-not (Test-Path $fileName)) {
            Write-Host ("Downloading {0} of {1}: {2}" -f $index, $imageCount, $fileName)
            try {
                # Print the actual URL being accessed
                Write-Host ("Accessing URL: {0}" -f $imageUrl)
                
                # Add headers to simulate browser request
                $headers = @{
                    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
                    "Accept" = "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8"
                }
                
                Invoke-WebRequest -Uri $imageUrl -OutFile $fileName -Headers $headers -UseBasicParsing
                Start-Sleep -Seconds 1  # Short delay between downloads
                
                Write-Host ("Resizing {0}" -f $fileName)
                Resize-Image -ImagePath $fileName -Width $targetWidth -Height $targetHeight
            }
            catch {
                Write-Host ("Error processing {0} - {1}" -f $fileName, $_.Exception.Message)
                Write-Host ("Failed URL: {0}" -f $imageUrl)
            }
        }
        else {
            Write-Host ("${fileName} already exists, skipping download")
        }
        $index++
    }
}

Write-Host "Image processing completed!"
Write-Host "Images saved in: $(Get-Location)"

cd ..