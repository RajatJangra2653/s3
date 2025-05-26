# Import required module
Import-Module AzureAD
Import-Module ImportExcel  # If not installed, run: Install-Module ImportExcel


#COpilot = 71f21848-f89b-4aaa-a2dc-780c8e8aac5b
#M365standard = f245ecc8-75af-4f8e-b61f-27d8114de5f3
# Connect to Azure AD
Connect-AzureAD -TenantId cbc044cf-defc-4487-8475-4df2b4b237ca

# Define the target SKU ID for the license
$TargetSkuId =  "71f21848-f89b-4aaa-a2dc-780c8e8aac5b" #"639dec6b-bb19-468b-871c-c5c441c4b0cb"

# Specify the Excel file path (Change this path as needed)
$ExcelFilePath = "C:\Users\SumitKumar\Downloads\AI Hackathon - Tribal Nations  (1).xlsx"

# Read the Excel file (Ensure the column is named "UserPrincipalName")
$Users = Import-Excel -Path $ExcelFilePath -WorksheetName "users"
$Users = $Users.UPN

# Check if users were loaded
if ($Users.Count -eq 0) {
    Write-Host "No users found in the Excel file!" -ForegroundColor Yellow
    exit
}





# Assign the license to each user
foreach ($UserUPN in $Users) {
    try {
        # Get the user object from Azure AD
        $User = Get-AzureADUser -ObjectId 'AIHack2025-01@cloudlabs4copilot.onmicrosoft.com' #$UserUPN
        
        if ($User) {
          
            $Sku = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $Sku.SkuId = "639dec6b-bb19-468b-871c-c5c441c4b0cb"
            $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $Licenses.AddLicenses = $Sku
            Set-AzureADUserLicense -ObjectId $User.ObjectId -AssignedLicenses $Licenses

            # Assign the license
           
            Write-Host "✅ Successfully assigned license to: $UserUPN"
        } else {
            Write-Host "⚠️ User not found: $UserUPN"
        }
    } catch {
        Write-Host "❌ Failed to assign license to user: $UserUPN. Error: $_"
    }
}
# Confirmation message
Write-Host "`nLicense assignment process completed." -ForegroundColor Cyan






foreach ($UserUPN in $Users) {
    try {
        # Fetch assigned licenses for the user
        $User = Get-AzureADUser -ObjectId 'AIHack2025-01@cloudlabs4copilot.onmicrosoft.com'	#$UserUPN

        $AssignedLicenses = $User.AssignedLicenses

         $AssignedLicenses
        # Check if license count is less than 
        if (($AssignedLicenses | Measure-Object).Count -eq 4) {
            Write-Host "⚠️ User $($User.UserPrincipalName) has less than 3 licenses."
        }
    } catch {
        Write-Host "❌ Failed to process user: $($User.UserPrincipalName). Error: $_"
    }
}


foreach ($User in $Users) {
    try {
        # Check if the user exists in AD
         $Use = Get-AzureADUser -ObjectId $User
         
        
        # Add user to AD group
         Remove-AzureADGroupMember -ObjectId 45a8dff7-a8d1-4eed-b1b6-f4e469b85257 -RefObjectId $Use.ObjectId
        Write-Host "✅ Successfully added $User to the Azure AD group." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to add $User. Error: $_" -ForegroundColor Red
    }
}




$User.AssignedLicenses



 $skuId = "71f21848-f89b-4aaa-a2dc-780c8e8aac5b"
        $sku = Get-AzureADSubscribedSku | Where-Object { $_.Skupartnumber -eq 'Microsoft_365_Copilot' } #$skuId }
        $skuName = $sku.skuId




foreach ($User in $Users) {
    
        # Check if the user exists in AD
         $Use = Get-AzureADUser -ObjectId $User
 #$User

         
        
        # Add user to AD group 
         $Use.ObjectId
          Remove-AzureADDirectoryRoleMember -ObjectId  256dc000-9c74-4eb4-a820-34b373aece8c -MemberId $Use.ObjectId -Verbose #-RefObjectId  $Use.ObjectId -ver
          #deviceadmin
          Remove-AzureADDirectoryRoleMember -ObjectId  880e461c-f147-4bfb-a7f6-8033ae1332e2  -MemberId $Use.ObjectId #-RefObjectId  $Use.ObjectId
                  Remove-AzureADDirectoryRoleMember -ObjectId  b4bbeb72-6ccd-4ade-a1ae-c56c09c576bc  -MemberId $Use.ObjectId #-RefObjectId  $Use.ObjectId

          #-MemberId $Use.ObjectId
          #-RefObjectId  
          ##GA
    }
  



        AzureADDirectoryRoleMember 

        Get-AzureADDirectoryRole  -ObjectId 256dc000-9c74-4eb4-a820-34b373aece8c - #$Use.ObjectId






        Connect-AzAccount -TenantId cbc044cf-defc-4487-8475-4df2b4b237ca

        
foreach ($User in $Users) {
        
# Get the user's object ID
$userObject = Get-AzureADUser -ObjectId $User
if (-not $userObject) {
    Write-Host "User not found: $userId" -ForegroundColor Red
    exit
}
$userObjectId = $userObject.Id

# Get all role assignments for the user
$roleAssignments = Get-AzRoleAssignment -ObjectId $userObject.ObjectId -RoleDefinitionName Owner




# Remove each role assignment
foreach ($role in $roleAssignments) {
    Write-Host "Removing role: $($role.RoleDefinitionName) from user: $userId" -ForegroundColor Cyan
    New-AzRoleAssignment -ObjectId  $userObject.ObjectId -RoleDefinitionName Reader -Scope $role.Scope 
    Remove-AzRoleAssignment -ObjectId $userObject.ObjectId -RoleDefinitionName $role.RoleDefinitionName -Scope $role.Scope -Confirm:$false
}

Write-Host "All role assignments removed successfully for user: $userId" -ForegroundColor Green
}
















for ($i = 32; $i -le 50; $i++) {
    # Format the number with leading zeroes (e.g., 01, 02, ..., 50)
    $index = "{0:D2}" -f $i
    $UserUPN = "AIHack2025-$index@cloudlabs4copilot.onmicrosoft.com"
    Write-Host "Processing user: $UserUPN"

    $User = Get-AzureADUser -ObjectId $UserUPN

    if ($User) {
        $Sku = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $Sku.SkuId = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"
        $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $Licenses.AddLicenses = $Sku

        try {
            Set-AzureADUserLicense -ObjectId $User.ObjectId -AssignedLicenses $Licenses
            Write-Host "License assigned to $UserUPN successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to assign license to $UserUPN. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "User $UserUPN not found." -ForegroundColor Yellow
    }
}
