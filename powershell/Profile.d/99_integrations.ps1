# Tool integrations and final setup

# Initialize mise
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (mise activate pwsh | Out-String) })
}

# Initialize zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Set up PowerShell completion
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}

# Set up better error handling
$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"

# Set up better history
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
