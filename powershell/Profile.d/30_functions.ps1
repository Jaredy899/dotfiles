# Utility functions

function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function rmd {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    Remove-Item -Path $Path -Recurse -Force
}

function mkdirg {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# Archive extraction function (PowerShell equivalent)
function Extract {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ArchivePath
    )
    
    if (-not (Test-Path $ArchivePath)) {
        Write-Error "File '$ArchivePath' does not exist"
        return
    }
    
    $extension = [System.IO.Path]::GetExtension($ArchivePath).ToLower()
    
    switch ($extension) {
        '.zip' { Expand-Archive -Path $ArchivePath -DestinationPath (Get-Location) }
        '.7z' { 
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                7z x $ArchivePath
            } else {
                Write-Error "7z not found. Please install 7-Zip"
            }
        }
        default { Write-Error "Unsupported archive format: $extension" }
    }
}

# Find text in files recursively
function Find-Text {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Pattern
    )
    Get-ChildItem -Recurse -File | Select-String -Pattern $Pattern -CaseSensitive:$false
}

# Copy with progress (PowerShell equivalent)
function Copy-WithProgress {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    
    if (-not (Test-Path $Source)) {
        Write-Error "Source path '$Source' does not exist"
        return
    }
    
    Copy-Item -Path $Source -Destination $Destination -Verbose
}

# Move and go
function Move-Go {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    
    Move-Item -Path $Source -Destination $Destination
    if (Test-Path $Destination -PathType Container) {
        Set-Location $Destination
    } else {
        Set-Location (Split-Path $Destination -Parent)
    }
}

# Copy and go
function Copy-Go {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    
    Copy-Item -Path $Source -Destination $Destination
    if (Test-Path $Destination -PathType Container) {
        Set-Location $Destination
    } else {
        Set-Location (Split-Path $Destination -Parent)
    }
}

# Up N directories
function Up {
    param(
        [int]$Levels = 1
    )
    
    $path = ".."
    for ($i = 1; $i -lt $Levels; $i++) {
        $path = Join-Path $path ".."
    }
    Set-Location $path
}

# Get current directory tail
function Get-PwdTail {
    $currentPath = Get-Location
    $parts = $currentPath.Path -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
    if ($parts.Length -ge 2) {
        return $parts[-2] + [System.IO.Path]::DirectorySeparatorChar + $parts[-1]
    }
    return $parts[-1]
}

# What's my IP (PowerShell version)
function Get-MyIP {
    Write-Host "Internal IP: " -NoNewline
    try {
        $networkAdapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }
        if ($networkAdapters) {
            Write-Host $networkAdapters[0].IPAddress
        } else {
            Write-Host "N/A"
        }
    } catch {
        Write-Host "N/A"
    }
    
    Write-Host "External IP: " -NoNewline
    try {
        $externalIP = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content.Trim()
        Write-Host $externalIP
    } catch {
        try {
            $externalIP = (Invoke-WebRequest -Uri "http://ipinfo.io/ip" -UseBasicParsing).Content.Trim()
            Write-Host $externalIP
        } catch {
            Write-Host "N/A"
        }
    }
}

# Trim whitespace
function Trim-String {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$InputObject
    )
    return $InputObject.Trim()
}
