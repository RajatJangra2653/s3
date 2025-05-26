# Import required modules
Import-Module Az
Import-Module ImportExcel

# Define the path to the Excel file
$ExcelFilePath = "C:\Users\RajatKumar\Downloads\AIHackathon-StateofOhio-Updated.xlsx"

# Read data from the Excel file
$ExcelData = Import-Excel -Path $ExcelFilePath

# Loop through each row in the Excel file
foreach ($Row in $ExcelData) {
    # Extract username and password from the current row
    $Username = $Row.Username
    $Password = $Row.Password | ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

    # Login to Azure
    Connect-AzAccount -Credential $Credential

    # Fetch the subscriptions where the user is an owner
    $Subscriptions = Get-AzRoleAssignment -SignInName $Username | Where-Object { $_.RoleDefinitionName -eq "Owner" }

    foreach ($Subscription in $Subscriptions) {
        # Set the subscription context
        Set-AzContext -SubscriptionId $Subscription.Scope.Split("/")[-1]

        # Assign owner permission to the new user (from a different row in the Excel file)
        $NewUser = $Row.NewUser
        New-AzRoleAssignment -ObjectId (Get-AzADUser -UserPrincipalName $NewUser).Id -RoleDefinitionName "Owner" -Scope $Subscription.Scope

        # Remove the original user's owner permission
        Remove-AzRoleAssignment -ObjectId (Get-AzADUser -UserPrincipalName $Username).Id -RoleDefinitionName "Owner" -Scope $Subscription.Scope
    }

    # Disconnect the current user session
    Disconnect-AzAccount
}

Write-Host "Permissions updated successfully."