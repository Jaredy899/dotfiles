# Development tools and integrations

# Cargo run function
function cr {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    cargo run @Args
}

# Web-based tool functions
function jc {
    Invoke-RestMethod jaredcervantes.com/win | Invoke-Expression
}

function winutil {
    Invoke-RestMethod christitus.com/win | Invoke-Expression
}

function os {
    Invoke-RestMethod jaredcervantes.com/winos | Invoke-Expression
}

# FZF integration (if available)
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # FZF file finder with editor
    function nfzf {
        $selectedFile = fzf -m --preview="bat --color=always {}"
        if ($selectedFile) {
            if (Get-Command nvim -ErrorAction SilentlyContinue) {
                nvim $selectedFile
            } elseif (Get-Command code -ErrorAction SilentlyContinue) {
                code $selectedFile
            } else {
                notepad $selectedFile
            }
        }
    }
}

# Update function (Windows equivalent)
function update {
    winget update --all --include-unknown --force
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco upgrade all -y
    }
}

# File conversion helpers
function Convert-Image {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputPath,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )
    
    if (Get-Command magick -ErrorAction SilentlyContinue) {
        magick $InputPath $OutputPath
    } elseif (Get-Command convert -ErrorAction SilentlyContinue) {
        convert $InputPath $OutputPath
    } else {
        Write-Error "ImageMagick not found. Please install ImageMagick or GraphicsMagick"
    }
}

# Network and system info
function Get-OpenPorts {
    netstat -an | Where-Object { $_ -match "LISTENING" }
}

function Get-DiskSpace {
    Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}
}

# Process helpers
function Get-TopCPU {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, Id
}

function Get-TopMemory {
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}, Id
}

# Search helpers
function Search-Process {
    param([string]$Pattern)
    Get-Process | Where-Object { $_.ProcessName -like "*$Pattern*" }
}

function Search-History {
    param([string]$Pattern)
    Get-History | Where-Object { $_.CommandLine -like "*$Pattern*" }
}
