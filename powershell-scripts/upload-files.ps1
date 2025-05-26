# Import required modules
Import-Module ImportExcel
Import-Module Microsoft.Graph

# Define variables
$ExcelFilePath = "C:\Path\To\UsersAndPasswords.xlsx" # Path to the Excel file
$FolderToUpload = "C:\Path\To\FolderToUpload"       # Path to the folder to upload

# Connect to Microsoft Graph using Device Code Flow
Write-Host "Authenticating with Microsoft Graph..."
Connect-MgGraph -Scopes "Files.ReadWrite.All"

# Function to upload a folder to OneDrive
function Upload-FolderToOneDrive {
    param (
        [string]$UserId,
        [string]$FolderPath
    )
    $Files = Get-ChildItem -Path $FolderPath -Recurse
    foreach ($File in $Files) {
        $RelativePath = $File.FullName.Substring($FolderPath.Length).TrimStart("\")
        $UploadUrl = "https://graph.microsoft.com/v1.0/users/$UserId/drive/root:/$RelativePath:/content"
        Write-Host "Uploading $RelativePath..."
        Invoke-RestMethod -Uri $UploadUrl -Method PUT -Headers @{ Authorization = "Bearer $(Get-MgContext).AccessToken" } -InFile $File.FullName -ContentType "application/octet-stream"
    }
}

# Read the Excel file
$Users = Import-Excel -Path $ExcelFilePath

# Loop through each user and upload the folder
foreach ($User in $Users) {
    $Username = $User.Username

    Write-Host "Fetching user ID for $Username..."
    $UserId = (Get-MgUser -Filter "userPrincipalName eq '$Username'").Id

    if ($null -ne $UserId) {
        Write-Host "Uploading folder to OneDrive for $Username..."
        Upload-FolderToOneDrive -UserId $UserId -FolderPath $FolderToUpload
    } else {
        Write-Host "User $Username not found in Azure AD."
    }
}

Write-Host "Folder upload completed for all users."