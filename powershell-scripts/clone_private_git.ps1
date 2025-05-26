# Script to clone a private Git repository
# 
# This script clones a private Git repository using either personal access token (PAT) or username/password authentication.
# You can use the parameters to customize the repository URL, local directory, and authentication method.

param (
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$LocalDir,
    
    [Parameter(Mandatory=$false)]
    [string]$PersonalAccessToken
    
    # Removed Username and UsePAT parameters since we're only using PAT
)

# Validate Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in PATH. Please install Git and try again."
    exit 1
}

# Create local directory if it doesn't exist
if (-not $LocalDir) {
    $repoName = $RepoUrl -split '/' | Select-Object -Last 1 -ErrorAction SilentlyContinue
    $repoName = $repoName -replace '\.git$', ''
    if (-not $repoName) {
        $repoName = "GitRepository"
    }
    $LocalDir = Join-Path (Get-Location) $repoName
}
else {
    # Ensure path is absolute
    if (-not [System.IO.Path]::IsPathRooted($LocalDir)) {
        $LocalDir = Join-Path (Get-Location) $LocalDir
    }
}

if (-not (Test-Path $LocalDir)) {
    New-Item -Path $LocalDir -ItemType Directory | Out-Null
    Write-Host "Created directory: $LocalDir"
}
else {
    if ((Get-ChildItem $LocalDir | Measure-Object).Count -gt 0) {
        Write-Error "Directory '$LocalDir' is not empty. Please specify an empty directory."
        exit 1
    }
}

# Clone with authentication
try {
    # Create authentication URL
    $AuthUrl = $RepoUrl
    if ($UsePAT) {
        if (-not $PersonalAccessToken) {
            $PersonalAccessToken = Read-Host -Prompt "Enter your Personal Access Token (PAT)" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PersonalAccessToken)
            $PersonalAccessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }
          # Format: https://token@github.com/username/repo.git (GitHub-specific format)
        if ($RepoUrl -match "^https://") {
            $AuthUrl = $RepoUrl -replace "^https://", "https://$PersonalAccessToken@"
        }
        elseif ($RepoUrl -match "^http://") {
            # Not recommended for security reasons, but supported
            $AuthUrl = $RepoUrl -replace "^http://", "http://$PersonalAccessToken@"
        }
        else {
            Write-Host "Using PAT with SSH URL. The token will be used for authentication if prompted."
        }
    }
    else {
        # Username & password authentication
        if (-not $Username) {
            $Username = Read-Host -Prompt "Enter your Git username"
        }
        $Password = Read-Host -Prompt "Enter your Git password" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        if ($RepoUrl -match "^https://") {
            $AuthUrl = $RepoUrl -replace "^https://", "https://$Username`:$PlainPassword@"
        }
        elseif ($RepoUrl -match "^http://") {
            $AuthUrl = $RepoUrl -replace "^http://", "http://$Username`:$PlainPassword@"
        }
        else {
            Write-Host "Using username/password with SSH URL. Credentials will be used if prompted."
        }
    }

    # Clone the repository
    Write-Host "Cloning repository to $LocalDir..."
    if ($UsePAT) {
        # Using PAT
        git clone $AuthUrl $LocalDir
    }
    else {
        # Using Username/Password
        git clone $AuthUrl $LocalDir
    }

    # Check if clone was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repository cloned successfully to $LocalDir"
    }
    else {
        Write-Error "Failed to clone repository. Check your credentials and repository URL."
        exit 1
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}

# Examples of usage:
# 
# Using PAT (recommended):
# .\clone_private_git.ps1 -RepoUrl "https://github.com/username/repo.git" -PersonalAccessToken "your_token" -LocalDir "C:\Projects\MyRepo"
# 
# Using username/password:
# .\clone_private_git.ps1 -RepoUrl "https://github.com/username/repo.git" -Username "your_username" -UsePAT:$false