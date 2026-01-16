# Git convenience functions

function gb { git branch }

function gbd {
    param (
        [Parameter(Mandatory=$true)]
        [string]$branch
    )
    git branch -D $branch
    git push -d origin $branch 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Remote branch '$branch' not found or already deleted" -ForegroundColor Yellow
    }
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
    $branch = git branch --show-current
    if (-not $branch) {
        Write-Host "Error: Not in a git repository or no branch detected" -ForegroundColor Red
        return
    }
    git add .
    git commit -m $message
    git push origin $branch
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

function gsc {
    param (
        [Parameter(Mandatory=$true)]
        [string]$branch
    )
    git switch -c $branch
}

function gpo {
    $branch = git branch --show-current
    if (-not $branch) {
        Write-Host "Error: Not in a git repository or no branch detected" -ForegroundColor Red
        return
    }
    git push -u origin $branch
}

function gpf {
    $branch = git branch --show-current
    if (-not $branch) {
        Write-Host "Error: Not in a git repository or no branch detected" -ForegroundColor Red
        return
    }
    git push --force-with-lease origin $branch
}

function ghsync {
    $branch = git branch --show-current
    if (-not $branch) {
        Write-Host "Error: Not in a git repository or no branch detected" -ForegroundColor Red
        return
    }
    gh repo sync
    if ($LASTEXITCODE -eq 0) {
        git push origin $branch
    }
}
