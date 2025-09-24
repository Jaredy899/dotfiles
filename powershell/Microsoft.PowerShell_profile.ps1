# PowerShell Profile - Modular Configuration
# Similar to bash .bashrc.d structure

# Path to dotfiles repo (cross-platform)
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    # Windows: Use Documents folder or find dotfiles location
    $DOTFILES = if (Test-Path "$env:USERPROFILE\.local\share\dotfiles") {
        "$env:USERPROFILE\.local\share\dotfiles"
    } elseif (Test-Path "$env:USERPROFILE\dotfiles") {
        "$env:USERPROFILE\dotfiles"
    } else {
        # Fallback: assume dotfiles are in a common location
        "$env:USERPROFILE\dotfiles"
    }
} else {
    # Linux/macOS: Use HOME directory
    $DOTFILES = "$env:HOME/.local/share/dotfiles"
}

$ProfileModulesDir = Join-Path $DOTFILES "powershell/Profile.d"

# Load modular profile fragments if directory exists
if (Test-Path $ProfileModulesDir) {
    Get-ChildItem -Path $ProfileModulesDir -Filter "*.ps1" | 
        Sort-Object Name | 
        ForEach-Object {
            try {
                . $_.FullName
            } catch {
                Write-Warning "Failed to load profile module: $($_.Name) - $($_.Exception.Message)"
            }
        }
}