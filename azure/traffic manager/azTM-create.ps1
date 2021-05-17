$resourceGroup = ""
$relativeDnsName = ""
$monitorPath = "/"
$monitorProtocol = "HTTPS" # HTTP, HTTPS, TCP
$monitorPort = 443
$profileName = $relativeDnsName.Replace(".","-").ToLower()

$endpointName_1 = ""
$endpointTarget_1 = ""
$endpointName_2 = ""
$endpointTarget_2 = ""

Write-Host "Create Azure Traffic Manager Profile $($profileName): " -NoNewline
New-AzTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup -ProfileStatus Enabled -TrafficRoutingMethod Priority -RelativeDnsName $relativeDnsName -TTL 60 -MonitorProtocol $monitorProtocol -MonitorPort $monitorPort -MonitorPath $monitorPath | Out-Null
$AzTrafficManagerProfile = Get-AzTrafficManagerProfile -Name $profileName -ResourceGroupName $resourceGroup
if($AzTrafficManagerProfile){
    Write-Host "V"

    Write-Host "Add customer header to profile: " -NoNewline
    Add-AzTrafficManagerCustomHeaderToProfile -TrafficManagerProfile $AzTrafficManagerProfile -Name "host" -Value $relativeDnsName | Out-Null
    Set-AzTrafficManagerProfile -TrafficManagerProfile $AzTrafficManagerProfile | Out-Null
    Write-Host "V"

    Write-Host "Add endpoint $($endpointName_1): " -NoNewline
    New-AzTrafficManagerEndpoint -EndpointStatus Enabled -Name $endpointName_1 -ProfileName $profileName -ResourceGroupName $resourceGroup -Type ExternalEndpoints -Priority 1 -Target $endpointTarget_1 | Out-Null
    Write-Host "V"
    Write-Host "Add endpoint $($endpointName_2): " -NoNewline
    New-AzTrafficManagerEndpoint -EndpointStatus Enabled -Name $endpointName_2 -ProfileName $profileName -ResourceGroupName $resourceGroup -Type ExternalEndpoints -Priority 2 -Target $endpointTarget_2 | Out-Null
    Write-Host "V"

}