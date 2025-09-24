# PowerShell Profile - Modular Configuration
# Similar to bash .bashrc.d structure

# Path to dotfiles repo (same as bash configuration)
$DOTFILES = "$env:HOME/.local/share/dotfiles"
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