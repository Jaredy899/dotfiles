# Initialize starship if installed
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { starship init powershell })
}

# Ensure Terminal-Icons module is installed and working before importing
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    try {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
    } catch {
        Write-Warning "Failed to install Terminal-Icons: $($_.Exception.Message)"
    }
}

# Only import if module is available and can be loaded
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    try {
        Import-Module -Name Terminal-Icons -ErrorAction Stop
    } catch {
        Write-Warning "Failed to import Terminal-Icons: $($_.Exception.Message)"
        Write-Warning "The module may be corrupted. Try: Uninstall-Module Terminal-Icons -AllVersions; Install-Module Terminal-Icons -Scope CurrentUser -Force"
    }
}
