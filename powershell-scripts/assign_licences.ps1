# Install and import the Microsoft Graph module (if not already)
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Import-Module Microsoft.Graph

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "User.ReadWrite.All", "Directory.Read.All"

$subscribedSkus = Get-MgSubscribedSku -All
$subscribedSkus | Select-Object SkuPartNumber, SkuId
# Get the SKU ID for the subscription you want to remove
$skuId = (Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq "ENTERPRISEPACK" }).SkuId

Write-Host "SKU ID to be removed: $skuId" -ForegroundColor Yellow

# Import the users list from CSV
$users = Import-Csv -Path "./users.csv"

foreach ($user in $users) {
    $upn = $user.UserPrincipalName
    Write-Host "`nProcessing: $upn" -ForegroundColor Cyan

    try {
        # Resolve user object to get the User ID (GUID)
        $userObject = Get-MgUser -UserId $upn
        $userId = $userObject.Id

        # Get current licenses
        $currentLicenses = (Get-MgUserLicenseDetail -UserId $userId).SkuId

        if ($currentLicenses -contains $skuId) {
            # Remove the specific license
            Set-MgUserLicense -UserId $userId -RemoveLicenses @($skuId) -AddLicenses @{}
            Write-Host "✅ License removed for $upn" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ $upn does not have the ENTERPRISEPACK license" -ForegroundColor DarkYellow
        }

    } catch {
        Write-Host "❌ Error processing $upn: $_" -ForegroundColor Red
    }
}
