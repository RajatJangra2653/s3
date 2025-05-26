# Import the necessary modules
Import-Module Az
Import-Module ImportExcel
Set-ExecutionPolicy Bypass -Scope Process -Force
Connect-AzAccount

# Path to the Excel file
$excelFilePath = "C:\Users\RajatKumar\Downloads\AI Hackathon - HackN Wow-FINAL.xlsx"

# Sheet name in the Excel file
$sheetName = "ODL-AI Hackathon - Hack'N Wow-U"

# Path to the log file
$logFilePath = "C:\Users\RajatKumar\Downloads\AI Hackathon - HackN Wow-FINAL.txt"

# Function to write log messages to the log file
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
    Add-Content -Path $logFilePath -Value $logMessage
}

# Read the Excel file
$users = Import-Excel -Path $excelFilePath -WorksheetName $sheetName
# Loop through each user in the Excel file
foreach ($user in $users) {
    $userEmail = $user.UserEmail

    # Get all subscriptions in the tenant
    $subscriptions = Get-AzSubscription

    foreach ($subscription in $subscriptions) {
        # Set the context to the current subscription
        Set-AzContext -SubscriptionId $subscription.Id

        # Get all role assignments for the current subscription
        $roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$($subscription.Id)" -SignInName $userEmail

        if ($roleAssignments.Count -eq 0) {
            Write-Log "No roles found for $userEmail in subscription $($subscription.Name)"
            continue
        }

        foreach ($roleAssignment in $roleAssignments) {
            if ($roleAssignment.RoleDefinitionName -eq "Owner") {
                # Remove the owner role assignment
                Remove-AzRoleAssignment -ObjectId $roleAssignment.ObjectId -RoleDefinitionName "Owner" -Scope "/subscriptions/$($subscription.Id)"
                Write-Log "Removed Owner role from $userEmail in subscription $($subscription.Name)"

                # Assign the reader role to the user
                New-AzRoleAssignment -ObjectId $roleAssignment.ObjectId -RoleDefinitionName "Reader" -Scope "/subscriptions/$($subscription.Id)"
                Write-Log "Assigned Reader role to $userEmail in subscription $($subscription.Name)"
            }
        }
    }
}