# PowerShell Profile - Modular Configuration
# Similar to bash .bashrc.d structure

# Path to dotfiles repo (cloned in home directory)
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    $DOTFILES = "$env:USERPROFILE\dotfiles"
} else {
    # Linux/macOS: Use home directory
    $DOTFILES = "$env:HOME/dotfiles"
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