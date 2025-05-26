# Import the necessary modules
Import-Module Az
Import-Module ImportExcel

# Connect to Azure
Connect-AzAccount

# Path to the Excel file
$excelFilePath = "C:\Users\RajatKumar\Downloads\AIHackathon-Singapore.xlsx"
$sheetName = "User Credentials"
$userColumn = "UserPrincipalName"  # Column containing user principal names
$subscriptionNames = @("Subscription1", "Subscription2", "Subscription3")  # List of subscription names

# Import the Excel file
$excelData = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Iterate through each subscription name in the list
foreach ($subscriptionName in $subscriptionNames) {
    # Get the subscription ID based on the name
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName

    if ($subscription) {
        $subscriptionId = $subscription.Id

        # Set the context to the current subscription
        Set-AzContext -SubscriptionId $subscriptionId

        Write-Host "Processing subscription: $subscriptionName (ID: $subscriptionId)"

        # Filter users from the Excel data for the current subscription
        $usersToAssign = $excelData | Select-Object -ExpandProperty $userColumn

        # Assign the owner role to each user
        foreach ($user in $usersToAssign) {
            try {
                $userObj = Get-AzADUser -UserPrincipalName $user
                if ($userObj) {
                    New-AzRoleAssignment -ObjectId $userObj.Id -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscriptionId"
                    Write-Host "Assigned Owner role to $user for subscription $subscriptionName"
                } else {
                    Write-Warning "User $user not found in Azure AD"
                }
            } catch {
                Write-Error "Error assigning role to $user : $_"
            }
        }
    } else {
        Write-Warning "Subscription not found with name: $subscriptionName"
    }
}


# Import the necessary modules
Import-Module Az
Import-Module ImportExcel

# Connect to Azure
Connect-AzAccount

# Path to the Excel file
$excelFilePath = "C:\Users\RajatKumar\Downloads\AIHackathon-Singapore.xlsx"
$sheetName = "User Credentials"
$subscriptionNameColumn = "SubscriptionName"  # Updated to use subscription name instead of ID
$usersToAssign = @("user1@domain.com", "user2@domain.com", "user3@domain.com")

# Import the Excel file
$excelData = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Iterate through each subscription in the Excel file
foreach ($row in $excelData) {
    $subscriptionName = $row.$subscriptionNameColumn
    
    # Get the subscription ID based on the name
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName
    
    if ($subscription) {
        $subscriptionId = $subscription.Id
        
        # Set the context to the current subscription
        Set-AzContext -SubscriptionId $subscriptionId
        
        Write-Host "Processing subscription: $subscriptionName (ID: $subscriptionId)"
        
        # Assign the owner role to each user
        foreach ($user in $usersToAssign) {
            try {
                $userObj = Get-AzADUser -UserPrincipalName $user
                if ($userObj) {
                    New-AzRoleAssignment -ObjectId $userObj.Id -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscriptionId"
                    Write-Host "Assigned Owner role to $user for subscription $subscriptionName"
                } else {
                    Write-Warning "User $user not found in Azure AD"
                }
            } catch {
                Write-Error "Error assigning role to $user: $_"
            }
        }
    } else {
        Write-Warning "Subscription not found with name: $subscriptionName"
    }
}



# Import the necessary modules
Set-ExecutionPolicy Bypass -Scope Process -Force

Import-Module Az
Import-Module ImportExcel

# Connect to Azure
Connect-AzAccount
Start-Transcript -Path C:\Users\RajatKumar\Downloads\Subs.txt -Append

# Define the specific subscription name
# Path to the Excel file containing subscription names
$excelFilePath = "C:\Users\RajatKumar\Downloads\Subscriptions.xlsx"
$sheetName = "Subscriptions"  # Replace with the actual sheet name
$subscriptionNameColumn = "SubscriptionName"  # Column containing subscription names
$usersToAssign = @("AIHackArizona2025-01@cloudevents.ai", "AIHackArizona2025-02@cloudevents.ai", "AIHackArizona2025-03@cloudevents.ai")

# Import the Excel file
$excelData = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Iterate through each subscription in the Excel file
foreach ($row in $excelData) {
    $subscriptionName = $row.$subscriptionNameColumn

    # Get the subscription ID based on the name
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName

    if ($subscription) {
        $subscriptionId = $subscription.Id

        # Set the context to the current subscription
        Set-AzContext -SubscriptionId $subscriptionId

        Write-Host "Processing subscription: $subscriptionName (ID: $subscriptionId)"

        # Assign the owner role to each user
        foreach ($user in $usersToAssign) {
            try {
                $userObj = Get-AzADUser -UserPrincipalName $user
                if ($userObj) {
                    New-AzRoleAssignment -ObjectId $userObj.Id -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscriptionId"
                    Write-Host "Assigned Owner role to $user for subscription $subscriptionName"
                } else {
                    Write-Warning "User $user not found in Azure AD"
                }
            } catch {
                Write-Error "Error assigning role to $user : $_"
            }
        }
    } else {
        Write-Warning "Subscription not found with name: $subscriptionName"
    }
}
