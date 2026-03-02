# Utility functions

function Get-PubIP
{
  (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function rmd
{
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )
  Remove-Item -Path $Path -Recurse -Force
}

function mkdirg
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$Path
  )
  New-Item -ItemType Directory -Path $Path -Force | Out-Null
  Set-Location $Path
}

# cat: use glow for .md files when available, otherwise bat or Get-Content
if (Test-Path Alias:cat) { Remove-Item Alias:cat }
function cat
{
  $useGlow = $false
  $isTerminal = $true
  try { $isTerminal = -not [Console]::IsOutputRedirected } catch {}
  if ($isTerminal -and (Get-Command glow -ErrorAction SilentlyContinue))
  {
    foreach ($arg in $args)
    {
      if ($arg -like '*.md') { $useGlow = $true; break }
    }
  }
  if ($useGlow)
  {
    glow @args
  }
  elseif (Get-Command bat -ErrorAction SilentlyContinue)
  {
    bat @args
  }
  else
  {
    Get-Content @args
  }
}

# catp: plain output for piping
if (Get-Command bat -ErrorAction SilentlyContinue)
{
  function catp { bat --plain --paging=never @args }
}
else
{
  function catp { Write-Warning "bat not found — catp unavailable." }
}

# Archive extraction function (PowerShell equivalent)
function Extract
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$ArchivePath
  )
    
  if (-not (Test-Path $ArchivePath))
  {
    Write-Error "File '$ArchivePath' does not exist"
    return
  }
    
  $extension = [System.IO.Path]::GetExtension($ArchivePath).ToLower()
    
  switch ($extension)
  {
    '.zip'
    { Expand-Archive -Path $ArchivePath -DestinationPath (Get-Location) 
    }
    '.7z'
    { 
      if (Get-Command 7z -ErrorAction SilentlyContinue)
      {
        7z x $ArchivePath
      } else
      {
        Write-Error "7z not found. Please install 7-Zip"
      }
    }
    default
    { Write-Error "Unsupported archive format: $extension" 
    }
  }
}

# Find text in files recursively
function Find-Text
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$Pattern
  )
  Get-ChildItem -Recurse -File | Select-String -Pattern $Pattern -CaseSensitive:$false
}

# Copy with progress (PowerShell equivalent)
function Copy-WithProgress
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$Source,
    [Parameter(Mandatory=$true)]
    [string]$Destination
  )
    
  if (-not (Test-Path $Source))
  {
    Write-Error "Source path '$Source' does not exist"
    return
  }
    
  Copy-Item -Path $Source -Destination $Destination -Verbose
}

# Move and go
function Move-Go
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$Source,
    [Parameter(Mandatory=$true)]
    [string]$Destination
  )
    
  Move-Item -Path $Source -Destination $Destination
  if (Test-Path $Destination -PathType Container)
  {
    Set-Location $Destination
  } else
  {
    Set-Location (Split-Path $Destination -Parent)
  }
}

# Copy and go
function Copy-Go
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$Source,
    [Parameter(Mandatory=$true)]
    [string]$Destination
  )
    
  Copy-Item -Path $Source -Destination $Destination
  if (Test-Path $Destination -PathType Container)
  {
    Set-Location $Destination
  } else
  {
    Set-Location (Split-Path $Destination -Parent)
  }
}

# Up N directories
function Up
{
  param(
    [int]$Levels = 1
  )
    
  $path = ".."
  for ($i = 1; $i -lt $Levels; $i++)
  {
    $path = Join-Path $path ".."
  }
  Set-Location $path
}

# Get current directory tail
function Get-PwdTail
{
  $currentPath = Get-Location
  $parts = $currentPath.Path -split [regex]::Escape([System.IO.Path]::DirectorySeparatorChar)
  if ($parts.Length -ge 2)
  {
    return $parts[-2] + [System.IO.Path]::DirectorySeparatorChar + $parts[-1]
  }
  return $parts[-1]
}

# What's my IP (PowerShell version)
function Get-MyIP
{
  Write-Host "Internal IP: " -NoNewline
  try
  {
    $networkAdapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }
    if ($networkAdapters)
    {
      Write-Host $networkAdapters[0].IPAddress
    } else
    {
      Write-Host "N/A"
    }
  } catch
  {
    Write-Host "N/A"
  }
    
  Write-Host "External IP: " -NoNewline
  try
  {
    $externalIP = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content.Trim()
    Write-Host $externalIP
  } catch
  {
    try
    {
      $externalIP = (Invoke-WebRequest -Uri "http://ipinfo.io/ip" -UseBasicParsing).Content.Trim()
      Write-Host $externalIP
    } catch
    {
      Write-Host "N/A"
    }
  }
}

# Trim whitespace
function Trim-String
{
  param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$InputObject
  )
  return $InputObject.Trim()
}

# Continuous ping (like ping /t in CMD)
function ping
{
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Target,
    
    [Parameter(Mandatory=$false)]
    [int]$Count = 0
  )
  
  # If Count is 0 or not specified, do continuous ping (default behavior)
  if ($Count -eq 0) {
    Write-Host "Pinging $Target with 32 bytes of data:" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    try {
      # Use -Continuous if available (PowerShell 5.1+)
      Test-Connection -ComputerName $Target -Continuous -ErrorAction Stop
    } catch {
      # Fallback for older PowerShell versions - loop continuously
      while ($true) {
        $result = Test-Connection -ComputerName $Target -Count 1 -ErrorAction SilentlyContinue
        if ($result) {
          $timestamp = Get-Date -Format "HH:mm:ss"
          Write-Host "[$timestamp] Reply from $($result.Address): bytes=32 time=$($result.ResponseTime)ms TTL=$($result.ResponseTimeToLive)" -ForegroundColor Green
        } else {
          $timestamp = Get-Date -Format "HH:mm:ss"
          Write-Host "[$timestamp] Request timed out." -ForegroundColor Red
        }
        Start-Sleep -Seconds 1
      }
    }
  } else {
    # Regular ping with specified count
    Test-Connection -ComputerName $Target -Count $Count
  }
}
