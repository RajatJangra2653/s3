# Connect to Azure AD
 
 
#COpilot = 639dec6b-bb19-468b-871c-c5c441c4b0cb
#M365standard = f245ecc8-75af-4f8e-b61f-27d8114de5f3
#copilotstudio user = 4b74a65c-8b4a-4fc8-9f6b-5177ed11ddfa
#E5 = ""
 
 
# Required modules
Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module AzureAD
Import-Module ImportExcel
 
# Login to Azure
Connect-AzAccount -TenantId "cbc044cf-defc-4487-8475-4df2b4b237ca" -SubscriptionId "949d1f5c-cbe0-443e-813a-c389ca7e1f4e"
 
Connect-AzureAD -TenantId cbc044cf-defc-4487-8475-4df2b4b237ca
 
# Prompt for inputs
$hackName = "thailand"
$numTeams = "12"
$numUsersPerTeam = "10"
$passwordPlain = "AIHack@Thailand" 
$passwordPlainadmins = "AIHack@ThailandAdmin" 
#$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
 
$excelPath = "C:\Users\SumitKumar\Downloads\51601-User-Detail-Report.xlsx"
 
# Normalize hackName
$hackName = $hackName.ToLower().Replace(" ", "")
$domain = "cloudlabs4copilot.onmicrosoft.com"
 
 
# Initialize export array
$userExportList = @()
 
# Phase 1: Create Groups, Users, and Assign to Groups
for ($team = 1; $team -le [int]$numTeams; $team++) {
    $teamPadded = "{0:D2}" -f $team
    $teamGroupName = "AIHack$hackName-team$teamPadded"
 
    Write-Host "Creating Group: $teamGroupName" -ForegroundColor Cyan
    $group = New-AzureADGroup -DisplayName $teamGroupName `
        -MailEnabled $false `
        -MailNickname "$teamGroupName" `
        -SecurityEnabled $true
 
    for ($user = 1; $user -le [int]$numUsersPerTeam; $user++) {
        $userPadded = "{0:D2}" -f $user
        $userName = "AIHack$hackName-team$teamPadded-user$userPadded"
        $userPrincipalName = "$userName@$domain"
 
        $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $passwordProfile.Password = $passwordPlain
        $passwordProfile.ForceChangePasswordNextLogin = $false
 
        Write-Host "Creating User: $userPrincipalName" -ForegroundColor Yellow
        $aadUser = New-AzureADUser -DisplayName $userName `
            -UserPrincipalName $userPrincipalName `
            -AccountEnabled $true `
            -MailNickName $userName `
            -PasswordProfile $passwordProfile
 
        Write-Host "Adding $userPrincipalName to group $teamGroupName" -ForegroundColor Gray
        Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $aadUser.ObjectId
 
        # Add to export list
        $userExportList += [pscustomobject]@{
            TeamName = $teamGroupName
            Email    = $userPrincipalName
            Password = $passwordPlain
        }
    }
}

# Prompt for the number of admin accounts
$numAdmins = Read-Host "Enter the number of admin accounts to create"

# Create Admin Group
$adminGroupName = "AIHack$hackName-admins"
Write-Host "Creating Admin Group: $adminGroupName" -ForegroundColor Cyan
$adminGroup = New-AzureADGroup -DisplayName $adminGroupName `
    -MailEnabled $false `
    -MailNickname "$adminGroupName" `
    -SecurityEnabled $true

# Create Admin Users and add to Admin Group
for ($admin = 1; $admin -le [int]$numAdmins; $admin++) {
    $adminPadded = "{0:D2}" -f $admin
    $adminUserName = "AIHack$hackName-admin$adminPadded"
    $adminPrincipalName = "$adminUserName@$domain"

    $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $passwordProfile.Password = $passwordPlainadmins
    $passwordProfile.ForceChangePasswordNextLogin = $false

    Write-Host "Creating Admin User: $adminPrincipalName" -ForegroundColor Yellow
    $aadAdminUser = New-AzureADUser -DisplayName $adminUserName `
        -UserPrincipalName $adminPrincipalName `
        -AccountEnabled $true `
        -MailNickName $adminUserName `
        -PasswordProfile $passwordProfile

    Write-Host "Adding $adminPrincipalName to admin group $adminGroupName" -ForegroundColor Gray
    Add-AzureADGroupMember -ObjectId $adminGroup.ObjectId -RefObjectId $aadAdminUser.ObjectId

    # Add to export list
    $userExportList += [pscustomobject]@{
        TeamName = $adminGroupName
        Email    = $adminPrincipalName
        Password = $passwordPlainadmins
    }
}
 
# Export to Excel
$excelFileName = "AIHack-$hackName-Users.xlsx"
$userExportList | Export-Excel -Path $excelFileName -AutoSize -BoldTopRow 
Write-Host "`nUser information exported to $excelFileName" -ForegroundColor Green

 
# Phase 2: Role Assignment based on Excel sheet
$records = Import-Excel -Path $excelPath -WorksheetName "Environment Detail"
 
 
# Get all subscriptions only once
$allSubs = Get-AzSubscription  -TenantId cbc044cf-defc-4487-8475-4df2b4b237ca
 
# Create a map from subscription name to ID
$subMap = @{}
foreach ($sub in $allSubs) {
    $subMap[$sub.Name] = $sub.Id
}
foreach ($record in $records) {
    $upn = $record.UPN.Trim()
    $team = $record.Teamname.Trim().ToLower()
    $subName = $record.Subname.Trim()
    $groupName = "AIHack$hackName-$team"
 
    Write-Host "Processing group: $groupName for user $upn"
 
    # Get subscription ID from map
    if (-not $subMap.ContainsKey($subName)) {
        Write-Warning "Subscription name not found: $subName"
        continue
    }
    $subId = $subMap[$subName]
 
    # Get group object
    $group = Get-AzADGroup -DisplayName $groupName -ErrorAction SilentlyContinue
    if (-not $group) {
        Write-Warning "Group not found: $groupName"
        continue
    }
 
    # Set context to target subscription
    Set-AzContext -SubscriptionId $subId -ErrorAction SilentlyContinue | Out-Null
 
    # Assign Owner role to group
    Write-Host "Assigning 'Owner' to group $groupName on subscription $subName"
    try {
        New-AzRoleAssignment -ObjectId $group.Id `
            -RoleDefinitionName "Owner" `
            -Scope "/subscriptions/$subId" `
            -ErrorAction Stop
    } catch {
        Write-Warning "Failed to assign role for group $groupName on $subName "
    }
}

# Assign Owner role to Admin Group
foreach ($record in $records) {
    $upn = $record.UPN.Trim()
    $team = $record.Teamname.Trim().ToLower()
    $subName = $record.Subname.Trim()
    $adminGroupName = "AIHack$hackName-admins"
 
    Write-Host "Processing group: $adminGroupName for user $upn"
 
    # Get subscription ID from map
    if (-not $subMap.ContainsKey($subName)) {
        Write-Warning "Subscription name not found: $subName"
        continue
    }
    $subId = $subMap[$subName]
 
    # Get admin group object
    $adminGroup = Get-AzADGroup -DisplayName $adminGroupName -ErrorAction SilentlyContinue
    if (-not $adminGroup) {
        Write-Warning "Admin group not found: $adminGroupName"
        continue
    }
 
    # Set context to target subscription
    Set-AzContext -SubscriptionId $subId -ErrorAction SilentlyContinue | Out-Null
 
    # Assign Owner role to admin group
    Write-Host "Assigning 'Owner' to admin group $adminGroupName on subscription $subName"
    try {
        New-AzRoleAssignment -ObjectId $adminGroup.Id `
            -RoleDefinitionName "Owner" `
            -Scope "/subscriptions/$subId" `
            -ErrorAction Stop
    } catch {
        Write-Warning "Failed to assign role for admin group $adminGroupName on $subName "
    }
}

