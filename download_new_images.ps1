# Set working directory
cd D:\BaiduSyncdisk\04-toursite
mkdir -p images
cd images

Write-Host "Starting to download new images..."

# Define new images list
$newImages = @{
    "paris.jpg" = @{
        url = "https://images.unsplash.com/photo-1502602898657-3e91760cbb34"
        width = 600
        height = 400
    }
    "tokyo.jpg" = @{
        url = "https://images.unsplash.com/photo-1513407030348-c983a97b98d8"
        width = 600
        height = 400
    }
    "bali.jpg" = @{
        url = "https://images.unsplash.com/photo-1539367628448-4bc5c9d171c8"
        width = 600
        height = 400
    }
    "avatar1.jpg" = @{
        url = "https://randomuser.me/api/portraits/men/1.jpg"
        width = 200
        height = 200
    }
}

# Add System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Define image resize function
function Resize-Image {
    param(
        [string]$ImagePath,
        [int]$Width,
        [int]$Height
    )
    
    try {
        $fullPath = Join-Path -Path (Get-Location) -ChildPath $ImagePath
        
        if (Test-Path $fullPath) {
            Write-Host "Processing: $fullPath"
            
            $tempPath = [System.IO.Path]::GetTempFileName()
            $tempPath = [System.IO.Path]::ChangeExtension($tempPath, [System.IO.Path]::GetExtension($ImagePath))
            
            $img = [System.Drawing.Image]::FromFile($fullPath)
            $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($img, 0, 0, $Width, $Height)
            
            $bitmap.Save($tempPath, $img.RawFormat)
            
            $graphics.Dispose()
            $bitmap.Dispose()
            $img.Dispose()
            
            Move-Item -Path $tempPath -Destination $fullPath -Force
            
            Write-Host "Successfully resized $ImagePath to ${Width}x${Height}"
        }
    }
    catch {
        Write-Host "Error processing $ImagePath : $_"
    }
}

# Download and process each new image
foreach ($image in $newImages.GetEnumerator()) {
    $fileName = $image.Key
    $imageInfo = $image.Value
    
    # Check if file exists
    if (-not (Test-Path $fileName)) {
        Write-Host "Downloading $fileName..."
        try {
            Invoke-WebRequest -Uri $imageInfo.url -OutFile $fileName
            Start-Sleep -Seconds 1  # Wait for file to be written
            
            Write-Host "Resizing $fileName..."
            Resize-Image -ImagePath $fileName -Width $imageInfo.width -Height $imageInfo.height
        }
        catch {
            Write-Host "Error processing $fileName : $_"
        }
    }
    else {
        Write-Host "$fileName already exists, skipping download"
    }
}

Write-Host "New images processing completed!"

# Return to parent directory
cd .. 