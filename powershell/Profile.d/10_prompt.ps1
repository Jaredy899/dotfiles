# Initialize starship if installed
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { starship init powershell })
}

# Note: Terminal-Icons is not needed when using eza (which provides its own icons)
