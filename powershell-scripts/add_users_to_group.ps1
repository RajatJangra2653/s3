# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Define the group ID and the list of user emails
$groupId = "your-group-id"
$userEmails = @("user1@example.com", "user2@example.com", "user3@example.com")

# Loop through each user email and add them to the group
foreach ($userEmail in $userEmails) {
    # Get the user object
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$userEmail'"
    
    if ($user) {
        # Check if the user is already in the group
        $isMember = Get-AzureADGroupMember -ObjectId $groupId | Where-Object { $_.ObjectId -eq $user.ObjectId }
        
        if ($isMember) {
            Write-Output "User $userEmail is already a member of group $groupId"
        } else {
            # Add the user to the group
            Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $user.ObjectId
            Write-Output "Added $userEmail to group $groupId"
        }
    } else {
        Write-Output "User $userEmail not found"
    }
}


Set-ExecutionPolicy Bypass -Scope Process -Force
# Import the AzureAD and ImportExcel modules
Import-Module AzureAD
Import-Module ImportExcel

# Connect to Azure AD
Connect-AzureAD

# Define the group ID
$groupId = "8fae6278-d992-4497-bc4f-4a4674f1e044"

# Import user emails from the Excel file
$excelFilePath = "C:\Users\RajatKumar\Downloads\AIHackathon-Singapore.xlsx"
$sheetName = "Environment Detail"
$userEmails = Import-Excel -Path $excelFilePath -WorksheetName $sheetName | Select-Object -ExpandProperty UPN

# Loop through each user email and add them to the group
foreach ($userEmail in $userEmails) {
    # Get the user object
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$userEmail'"
    
    if ($user) {
        # Check if the user is already in the group
        $isMember = Get-AzureADGroupMember -ObjectId $groupId | Where-Object { $_.ObjectId -eq $user.ObjectId }
        
        if ($isMember) {
            Write-Output "User $userEmail is already a member of group $groupId"
        } else {
            # Add the user to the group
            Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $user.ObjectId
            Write-Output "Added $userEmail to group $groupId"
        }
    } else {
        Write-Output "User $userEmail not found"
    }
}

