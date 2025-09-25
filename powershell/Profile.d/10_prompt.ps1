# Initialize starship if installed
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { starship init powershell })
}

# Ensure Terminal-Icons module is installed before importing
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons
