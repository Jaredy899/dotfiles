# Git convenience functions

function gb { git branch }

function gbd {
    param (
        [Parameter(Mandatory=$true)]
        [string]$branch
    )
    git branch -D $branch
}

function gcom {
    param (
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    git add .
    git commit -m $message
}

function lazyg {
    param (
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    git add .
    git commit -m $message
    git push
}

function newb {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('b')]
        [string] $Branch,

        [Parameter(Mandatory = $true)]
        [Alias('m')]
        [string] $Message
    )

    git checkout -b $Branch
    if ($LASTEXITCODE -ne 0) { return }

    git add .
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) { return }

    git push -u origin $Branch
}

function gs {
    $branch = git branch --all --color=never |
        ForEach-Object { $_.Trim().TrimStart('*').Trim() } |
        Sort-Object |
        fzf --prompt="Switch to branch: "

    if ($branch) {
        # Remove "remotes/" prefix if present
        if ($branch -like "remotes/*") {
            $branch = $branch -replace "^remotes/", ""
        }

        if ($branch -like "origin/*") {
            $localBranch = $branch -replace "^origin/", ""
            git switch -c $localBranch --track $branch
        }
        else {
            git switch $branch
        }
    }
}

# Remove default gp alias if it exists
if (Get-Alias gp -ErrorAction SilentlyContinue) {
    Remove-Item Alias:gp -Force
}

function gp {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    git pull @Args
}
