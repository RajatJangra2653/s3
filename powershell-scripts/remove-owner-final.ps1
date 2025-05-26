# Import the necessary modules
Import-Module Az
Import-Module ImportExcel
Set-ExecutionPolicy Bypass -Scope Process -Force

# Connect to Azure
Connect-AzAccount

# Path to the Excel file
$excelFilePath = "C:\Users\RajatKumar\Downloads\Italy.xlsx"
$sheetName = "Sheet1"
$userColumnName = "UserEmail"  # Update this to match your Excel column name

# Path for output file
$outputFilePath = "C:\Users\RajatKumar\Downloads\RoleChangeReport.csv"

# Import users from Excel
Write-Host "Importing users from Excel..." -ForegroundColor Cyan
$users = Import-Excel -Path $excelFilePath -WorksheetName $sheetName

# Create an array to store results
$results = @()
# List of subscription names to process
$subscriptionNames = @(
    "CopilotLabs DS - 1049",
    "CopilotLabs DS - 1050",
    "CopilotLabs DS - 1051",
    "CopilotLabs DS - 1052",
    "CopilotLabs DS - 1053",
    "CopilotLabs DS - 1054",
    "CopilotLabs DS - 1055",
    "CopilotLabs DS - 1056",
    "CopilotLabs DS - 1057",
    "CopilotLabs DS - 1058"
)

# Filter subscriptions based on the provided names
$subscriptions = Get-AzSubscription | Where-Object { $subscriptionNames -contains $_.Name }
if ($subscriptions.Count -eq 0) {
    Write-Host "No matching subscriptions found for the provided names." -ForegroundColor Red
    return
}
Write-Host "Found $($subscriptions.Count) subscriptions to check" -ForegroundColor Green

# Process each subscription
foreach ($subscription in $subscriptions) {
    Write-Host "`nProcessing subscription: $($subscription.Name)" -ForegroundColor Yellow
    
    # Set context to the subscription
    Set-AzContext -SubscriptionId $subscription.Id -TenantId $subscription.TenantId | Out-Null
    
    # Get all users with the "Owner" role in this subscription
    $ownerRoles = Get-AzRoleAssignment -RoleDefinitionName "Owner" -Scope "/subscriptions/$($subscription.Id)"
    $ownerUsers = $ownerRoles | Select-Object -ExpandProperty ObjectId -Unique
    
    if ($ownerUsers.Count -eq 0) {
        Write-Host "  No Owner roles found in subscription: $($subscription.Name)" -ForegroundColor Gray
        continue
    }
    
    Write-Host "  Found $($ownerUsers.Count) users with Owner role in subscription: $($subscription.Name)" -ForegroundColor Cyan
    
    # Check each user from the Excel file
    foreach ($userRow in $users) {
        $userPrincipalName = $userRow.$userColumnName
        
        Write-Host "    Checking user: $userPrincipalName" -ForegroundColor White
        
        try {
            # Get user object
            $userObject = Get-AzADUser -UserPrincipalName $userPrincipalName
            
            if (-not $userObject) {
                Write-Host "      User not found in Azure AD: $userPrincipalName" -ForegroundColor Red
                continue
            }
            
            $userObjectId = $userObject.Id
            
            # Check if the user has an Owner role in this subscription
            if ($ownerUsers -contains $userObjectId) {
                Write-Host "      User has Owner role in subscription: $($subscription.Name)" -ForegroundColor Yellow
                
                foreach ($role in $ownerRoles | Where-Object { $_.ObjectId -eq $userObjectId }) {
                    $scope = $role.Scope
                    
                    try {
                        # First assign Reader role
                        Write-Host "        Assigning Reader role at scope: $scope" -ForegroundColor White
                        New-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName "Reader" -Scope $scope
                        
                        # Then remove Owner role
                        Write-Host "        Removing Owner role at scope: $scope" -ForegroundColor White
                        Remove-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName "Owner" -Scope $scope -Confirm:$false
                        
                        # Add to results
                        $results += [PSCustomObject]@{
                            User = $userPrincipalName
                            SubscriptionName = $subscription.Name
                            SubscriptionId = $subscription.Id
                            Scope = $scope
                            Action = "Owner replaced with Reader"
                            Status = "Success"
                        }
                    }
                    catch {
                        Write-Host "        Error changing role: $_" -ForegroundColor Red
                        
                        $results += [PSCustomObject]@{
                            User = $userPrincipalName
                            SubscriptionName = $subscription.Name
                            SubscriptionId = $subscription.Id
                            Scope = $scope
                            Action = "Owner replaced with Reader"
                            Status = "Failed: $_"
                        }
                    }
                } 
            } else {
                Write-Host "      User does not have Owner role in subscription: $($subscription.Name)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "      Error processing user $userPrincipalName : $_" -ForegroundColor Red
        }
    }
}

# Export results
if ($results.Count -gt 0) {
    $results | Export-Csv -Path $outputFilePath -NoTypeInformation
    Write-Host "`nRole change report exported to: $outputFilePath" -ForegroundColor Green
}

Write-Host "`nProcessing complete. Total role changes: $($results.Count)" -ForegroundColor Cyan


"CopilotLabs DS - 1016",
"CopilotLabs DS - 1017",
"CopilotLabs DS - 1018",
"CopilotLabs DS - 1019",
"CopilotLabs DS - 1020",
"CopilotLabs DS - 1021",
"CopilotLabs DS - 1022",
"CopilotLabs DS - 1023",
"CopilotLabs DS - 1024",
"CopilotLabs DS - 1025",
"CopilotLabs DS - 1026",
"CopilotLabs DS - 1027",
"CopilotLabs DS - 1028",
"CopilotLabs DS - 1029",
"CopilotLabs DS - 1030",
"CopilotLabs DS - 1031",
"CopilotLabs DS - 1032",
"CopilotLabs DS - 1033",
"CopilotLabs DS - 1034",
"CopilotLabs DS - 1035",
"CopilotLabs DS - 1036",
"CopilotLabs DS - 1037",
"CopilotLabs DS - 1038",
"CopilotLabs DS - 1039",
"CopilotLabs DS - 1040"
