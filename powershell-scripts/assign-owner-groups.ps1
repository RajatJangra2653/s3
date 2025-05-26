Set-ExecutionPolicy Bypass -Scope Process -Force

Import-Module Az
Import-Module ImportExcel

# Connect to Azure
Connect-AzAccount
Start-Transcript -Path C:\Users\RajatKumar\Downloads\Subs.txt -Append

# Path to the Excel file containing user emails and subscription names
$excelFilePath = "C:\Users\RajatKumar\Downloads\Subscriptions.xlsx"
$sheetName = "Subscriptions"  # Replace with the actual sheet name
$userEmailColumn = "UserEmail"  # Column containing user emails
$subscriptionNameColumn = "SubscriptionName"  # Column containing subscription names

# Import the Excel file
$excelData = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Iterate through each row in the Excel file
foreach ($row in $excelData) {
    $userEmail = $row.$userEmailColumn
    $subscriptionName = $row.$subscriptionNameColumn

    # Get the subscription ID based on the name
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName

    if ($subscription) {
        $subscriptionId = $subscription.Id

        # Set the context to the current subscription
        Set-AzContext -SubscriptionId $subscriptionId

        Write-Host "Processing subscription: $subscriptionName (ID: $subscriptionId) for user: $userEmail"

        try {
            # Get the Azure AD user object
            $userObj = Get-AzADUser -UserPrincipalName $userEmail
            if ($userObj) {
                # Assign the Owner role to the user
                New-AzRoleAssignment -ObjectId $userObj.Id -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscriptionId"
                Write-Host "Assigned Owner role to $userEmail for subscription $subscriptionName"
            } else {
                Write-Warning "User $userEmail not found in Azure AD"
            }
        } catch {
            Write-Error "Error assigning role to $userEmail : $_"
        }
    } else {
        Write-Warning "Subscription not found with name: $subscriptionName"
    }
}