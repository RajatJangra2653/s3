# Import the Microsoft Graph module
Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph with expanded permissions
# Note: You need to be a Global Administrator or User Administrator
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "Directory.AccessAsUser.All"

# Define the domain for the UPNs
$domain = "cloudlabs4copilot.onmicrosoft.com"

# Define the new password
$newPasswordProfile = @{
    Password = "AIHaCk@2025"
    ForceChangePasswordNextSignIn = $false
}

# Loop to update passwords for users
for ($i = 1; $i -le 50; $i++) {
    $userNumber = "{0:D2}" -f $i
    $upn = "AIHack2025-$userNumber@$domain"
    
    try {
        # Get the user's Object ID first (this is more reliable than using UPN)
        $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
        
        if ($user) {
            # Update the user's password using Object ID
            Update-MgUser -UserId $user.Id -PasswordProfile $newPasswordProfile
            Write-Host "Updated password for user: $upn" -ForegroundColor Green
        } else {
            Write-Host "User not found: $upn" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error updating password for $upn : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph