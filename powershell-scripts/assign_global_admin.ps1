# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.Read.All", "RoleManagement.ReadWrite.Directory", "Group.Read.All"

# Variables
$groupName = "AI Hackathon - Singapore Admins"
$roleName = "Global Administrator"

# Get the group object
$group = Get-MgGroup -Filter "displayName eq '$groupName'"

# Get the role definition
$roleDefinition = Get-MgDirectoryRole -Filter "displayName eq '$roleName'"

# Assign the role to the group
New-MgRoleManagementDirectoryRoleAssignment -RoleDefinitionId $roleDefinition.Id -PrincipalId $group.Id -DirectoryScopeID "/"

Write-Output "Global Administrator role assigned to group: $groupName"






Import-Module Microsoft.Graph.Users -Function Get-MgUser
Import-Module Microsoft.Graph.Identity.DirectoryManagement -Function Get-MgDirectoryRole
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.Read.All", "RoleManagement.ReadWrite.Directory", "User.Read.All"
Set-ExecutionPolicy Bypass -Scope Process -Force
# Variables
$roleName = "Global Reader"
$excelFilePath = "C:\Path\To\Your\ExcelFile.xlsx"
$sheetName = "Sheet1"
$userColumn = "A" # Column where UserPrincipalNames are stored


Import-Module ImportExcel

# Read the user list from the Excel file
try {
    $users = Import-Excel -Path $excelFilePath -WorksheetName $sheetName | Select-Object -ExpandProperty $userColumn
} catch {
    Write-Output "Error reading Excel file: $_"
}

# Get the role definition for Global Reader
$roleDefinition = Get-MgDirectoryRole -Filter "displayName eq '$roleName'"

if (-not $roleDefinition) {
    Write-Output "Role '$roleName' not found."
}

# Loop through each user and assign the role
foreach ($userEmail in $users) {
    try {
        # Get the user object
        $user = Get-MgUser -Filter "userPrincipalName eq '$userEmail'"
        
        if ($user) {
            # Assign the role to the user
            New-MgRoleManagementDirectoryRoleAssignment -RoleDefinitionId $roleDefinition.Id -PrincipalId $user.Id -DirectoryScopeId "/"
            Write-Output "Global Reader role assigned to user: $userEmail"
        } else {
            Write-Output "User not found: $userEmail"
        }
    } catch {
        Write-Output "Error assigning role to user $userEmail : $_"
    }
}