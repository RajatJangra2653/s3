# Import the Microsoft Graph module\
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Define the domain for the UPNs
$domain = "yourdomain.com" # Replace with your actual domain

# Define the password
$passwordProfile = @{
    Password = "AiHaCk@2025"
    ForceChangePasswordNextSignIn = $false
}

# Loop to create users
for ($i = 1; $i -le 50; $i++) {
    $userNumber = "{0:D2}" -f $i
    $upn = "AIHack2025-$userNumber@$domain"

    # Create the user
    $params = @{
        DisplayName = "AIHack2025-$userNumber"
        MailNickname = "AIHack2025-$userNumber"
        UserPrincipalName = $upn
        PasswordProfile = $passwordProfile
        AccountEnabled = $true
        UsageLocation = "US" # Replace with your location if needed
    }
    
    New-MgUser @params

    Write-Host "Created user: $upn"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph