# Licensed under the WTFPL License

$url = 'https://storage.googleapis.com/panels-api/data/20240916/media-1a-i-p~s'

function Delay-Milliseconds {
    param([int]$milliseconds)
    Start-Sleep -Milliseconds $milliseconds
}

function Download-Image {
    param(
        [string]$imageUrl,
        [string]$filePath
    )
    if (Test-Path $filePath) {
        Write-Host "⏭️ File already exists: $filePath. Skipping download."
        return
    try {
        Invoke-WebRequest -Uri $imageUrl -OutFile $filePath
        Write-Host "🖼️ Saved image to $filePath"
    } catch {
        Write-Host "Error downloading image: $_"
    }
}

function Main {
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get

        if (-not $response.data) {
            throw "⛔ JSON does not have a 'data' property at its root."
        }

        $downloadDir = Join-Path $PWD "downloads"
        if (-not (Test-Path $downloadDir)) {
            New-Item -ItemType Directory -Path $downloadDir | Out-Null
            Write-Host "📁 Created directory: $downloadDir"
        }

        $fileIndex = 1
        foreach ($key in $response.data.PSObject.Properties.Name) {
            $subproperty = $response.data.$key
            if ($subproperty -and $subproperty.dhd) {
                $imageUrl = $subproperty.dhd
                Write-Host "🔍 Found image URL!"
                $parsedUrl = [System.Uri]::new($imageUrl)
                $ext = [System.IO.Path]::GetExtension($parsedUrl.AbsolutePath)
                if (-not $ext) { $ext = ".jpg" }
                $filename = "$fileIndex$ext"
                $filePath = Join-Path $downloadDir $filename
                Download-Image -imageUrl $imageUrl -filePath $filePath
                $fileIndex++
                Delay-Milliseconds -milliseconds 250
            }
        }
    } catch {
        Write-Host "Error: $_"
    }
}

function Show-AsciiArt {
    $asciiArt = @"
 /`$`$      /`$`$ /`$`$   /`$`$ /`$`$`$`$`$`$`$   /`$`$`$`$`$`$  /`$`$`$`$`$`$`$
| `$`$`$    /`$`$`$| `$`$  /`$`$/| `$`$__  `$`$ /`$`$__  `$`$| `$`$__  `$`$
| `$`$`$`$  /`$`$`$`$| `$`$ /`$`$/ | `$`$  \ `$`$| `$`$  \__/| `$`$  \ `$`$
| `$`$ `$`$/`$`$ `$`$| `$`$`$`$`$/  | `$`$`$`$`$`$`$ |  `$`$`$`$`$`$ | `$`$  | `$`$
| `$`$  `$`$`$| `$`$| `$`$  `$`$  | `$`$__  `$`$ \____  `$`$| `$`$  | `$`$
| `$`$\  `$ | `$`$| `$`$\  `$`$ | `$`$  \ `$`$ /`$`$  \ `$`$| `$`$  | `$`$
| `$`$ \/  | `$`$| `$`$ \  `$`$| `$`$`$`$`$`$`$/|  `$`$`$`$`$`$/| `$`$`$`$`$`$`$/
|__/     |__/|__/  \__/|_______/  \______/ |_______/
"@
    Write-Host $asciiArt
    Write-Host ""
    Write-Host "🤑 Starting downloads from your favorite sellout grifter's wallpaper app..."
}

Show-AsciiArt
Start-Sleep -Seconds 5
Main
