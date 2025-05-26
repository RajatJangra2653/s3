# Connect to Azure if not already connected
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

# Get the user's object ID
$UserPrincipalName=""
$user = Get-AzADUser -UserPrincipalName $UserPrincipalName
if (-not $user) {
    Write-Error "User '$UserPrincipalName' not found."
    exit 1
}
$userId = $user.Id

# Get all subscriptions
$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name) ($($sub.Id))" -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    # Get all role assignments for the user in this subscription
    $assignments = Get-AzRoleAssignment -ObjectId $userId -ErrorAction SilentlyContinue

    foreach ($assignment in $assignments) {
        Write-Host "Removing role '$($assignment.RoleDefinitionName)' at scope '$($assignment.Scope)'" -ForegroundColor Yellow
        Remove-AzRoleAssignment -ObjectId $userId -Scope $assignment.Scope -RoleDefinitionName $assignment.RoleDefinitionName -ErrorAction SilentlyContinue
    }
}

Write-Host "All permissions removed for user $UserPrincipalName across all subscriptions." -ForegroundColor Green