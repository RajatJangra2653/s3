# Connect to Azure
Set-ExecutionPolicy Bypass -Scope Process -Force


Import-Module Az.Accounts
Import-Module Az.Resources


Connect-AzAccount -TenantId cbc044cf-defc-4487-8475-4df2b4b237ca
 
# List of subscription names
$subscriptionNames = @(
    "CopilotLabs DS - 1088", "CopilotLabs DS - 1089", "CopilotLabs DS - 1090", "CopilotLabs DS - 1091",
    "CopilotLabs DS - 1092", "CopilotLabs DS - 1093", "CopilotLabs DS - 1094", "CopilotLabs DS - 1095",
    "CopilotLabs DS - 1096", "CopilotLabs DS - 1097", "CopilotLabs DS - 1098", "CopilotLabs DS - 1099",
    "CopilotLabs DS - 1100", "CopilotLabs DS - 1101", "CopilotLabs DS - 1102", "CopilotLabs DS - 1103",
    "CopilotLabs DS - 1104", "CopilotLabs DS - 1105", "CopilotLabs DS - 1106", "CopilotLabs DS - 1107",
    "CopilotLabs DS - 1108", "CopilotLabs DS - 1109", "CopilotLabs DS - 1110", "CopilotLabs DS - 1111",
    "CopilotLabs DS - 1112", "CopilotLabs DS - 1113", "CopilotLabs DS - 1114", "CopilotLabs DS - 1115",
    "CopilotLabs DS - 1116", "CopilotLabs DS - 1117", "CopilotLabs DS - 1118", "CopilotLabs DS - 1119",
    "CopilotLabs DS - 1120", "CopilotLabs DS - 1121", "CopilotLabs DS - 1122", "CopilotLabs DS - 1123",
    "CopilotLabs DS - 1124", "CopilotLabs DS - 1125", "CopilotLabs DS - 1126", "CopilotLabs DS - 1127",
    "CopilotLabs DS - 1128", "CopilotLabs DS - 1129", "CopilotLabs DS - 1130", "CopilotLabs DS - 1131",
    "CopilotLabs DS - 1132", "CopilotLabs DS - 1133"
)
 
foreach ($subName in $subscriptionNames) {
    Write-Host "`n============================"
    Write-Host "Processing subscription: $subName"
    Write-Host "============================"
 
    # Get subscription ID from name
    $subscription = Get-AzSubscription -SubscriptionName $subName
 
    if ($subscription) {
        Set-AzContext -SubscriptionId $subscription.Id
 
        # Get all resource groups
        $resourceGroups = Get-AzResourceGroup
 
        foreach ($rg in $resourceGroups) {
            Write-Host "Deleting Resource Group: $($rg.ResourceGroupName) in subscription $subName..."
            Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob
        }
    } else {
        Write-Warning "Subscription not found: $subName"
    }
}