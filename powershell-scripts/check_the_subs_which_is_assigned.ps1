# Import the necessary modules
Import-Module Az
Import-Module ImportExcel

# Connect to Azure
Connect-AzAccount

# Fetch all subscriptions
$subscriptions = Get-AzSubscription

# Path to the Excel file
$excelFilePath = "C:\Users\RajatKumar\Downloads\AIHackathon-Singapore.xlsx"
$sheetName = "User Credentials"
$excelData = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    # Set the context to the current subscription
    Set-AzContext -SubscriptionId $subscription.Id

    # Fetch the role assignments for the current subscription
    $roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$($subscription.Id)"

    # Filter for owner role assignments
    $ownerAssignments = $roleAssignments | Where-Object { $_.RoleDefinitionName -eq "Owner" }

    # Iterate through each owner assignment
    foreach ($owner in $ownerAssignments) {
        # Check if the owner is in the Excel list
        $user = $excelData | Where-Object { $_.UPN -eq $owner.SignInName }

        if ($user) {
            # Add the subscription name and ID to the Excel data
            $user.SubscriptionID = $subscription.Id
        }
    }
}

# Export the updated Excel data back to the file
$excelData | Export-Excel -Path $excelFilePath -WorksheetName $sheetName -Show