# Create images directory if not exists
cd D:\BaiduSyncdisk\04-toursite
mkdir -p images
# Change to images directory
cd images

Write-Host "Starting download..."

# Download logo
Write-Host "Downloading logo.png..."
Invoke-WebRequest -Uri "https://cdn.pixabay.com/photo/2022/09/08/15/16/travel-agency-7441867_1280.png" -OutFile "logo.png"

# Download banner
Write-Host "Downloading banner.jpg..."
Invoke-WebRequest -Uri "https://images.unsplash.com/photo-1506905925346-21bda4d32df4" -OutFile "banner.jpg"

# Download about
Write-Host "Downloading about.jpg..."
Invoke-WebRequest -Uri "https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg" -OutFile "about.jpg"

# Download project1 (Europe/Paris)
Write-Host "Downloading project1.jpg..."
Invoke-WebRequest -Uri "https://images.unsplash.com/photo-1511739001486-6bfe10ce785f" -OutFile "project1.jpg"

# Download project2 (Southeast Asia Beach)
Write-Host "Downloading project2.jpg..."
Invoke-WebRequest -Uri "https://images.unsplash.com/photo-1537956965359-7573183d1f57" -OutFile "project2.jpg"

# Download project3 (Japan Mt.Fuji)
Write-Host "Downloading project3.jpg..."
Invoke-WebRequest -Uri "https://images.unsplash.com/photo-1545569341-9eb8b30979d9" -OutFile "project3.jpg"

Write-Host "Downloads completed!"

# Add System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Get current directory
$currentDir = Get-Location

# Define image resize function
function Resize-Image {
    param(
        [string]$ImagePath,
        [int]$Width,
        [int]$Height
    )
    
    try {
        # Get full path
        $fullPath = Join-Path -Path $currentDir -ChildPath $ImagePath
        
        if (Test-Path $fullPath) {
            Write-Host "Processing: $fullPath"
            
            # Create temp file path
            $tempPath = [System.IO.Path]::GetTempFileName()
            $tempPath = [System.IO.Path]::ChangeExtension($tempPath, [System.IO.Path]::GetExtension($ImagePath))
            
            # Load and process image
            $img = [System.Drawing.Image]::FromFile($fullPath)
            $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            
            # Set high quality interpolation mode
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($img, 0, 0, $Width, $Height)
            
            # Save to temp file
            $bitmap.Save($tempPath, $img.RawFormat)
            
            # Dispose resources
            $graphics.Dispose()
            $bitmap.Dispose()
            $img.Dispose()
            
            # Replace original file
            Move-Item -Path $tempPath -Destination $fullPath -Force
            
            Write-Host "Successfully resized $ImagePath to ${Width}x${Height}"
        } else {
            Write-Host "File not found: $fullPath"
        }
    }
    catch {
        Write-Host "Error processing $ImagePath : $_"
    }
}

Write-Host "Starting image resizing..."
Write-Host "Current directory: $currentDir"

# Wait for files to be ready
Start-Sleep -Seconds 2

# Resize all images
try {
    Resize-Image -ImagePath "logo.png" -Width 200 -Height 50
    Resize-Image -ImagePath "banner.jpg" -Width 1920 -Height 1080
    Resize-Image -ImagePath "about.jpg" -Width 800 -Height 600
    Resize-Image -ImagePath "project1.jpg" -Width 600 -Height 400
    Resize-Image -ImagePath "project2.jpg" -Width 600 -Height 400
    Resize-Image -ImagePath "project3.jpg" -Width 600 -Height 400
    
    Write-Host "All images resized successfully!"
}
catch {
    Write-Host "Error during image resizing: $_"
}

# Return to parent directory
cd ..