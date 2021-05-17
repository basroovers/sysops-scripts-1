Param
(
    [Parameter(Mandatory=$true)][string]$resourceGroup
)

$azTrafficManagerProfiles = Get-AzTrafficManagerProfile -ResourceGroupName $resourceGroup

foreach($azTrafficManagerProfile in $azTrafficManagerProfiles){
    Write-Host " $($azTrafficManagerProfile.RelativeDnsName) " -BackgroundColor Gray -ForegroundColor Black
    
    foreach($azTrafficManagerProfileEndpoint in $azTrafficManagerProfile.Endpoints){
        Write-Host " $($azTrafficManagerProfileEndpoint.Name) [$($azTrafficManagerProfileEndpoint.Priority)] " -BackgroundColor DarkGray -ForegroundColor White -NoNewline

        Write-Host " $($azTrafficManagerProfileEndpoint.EndpointStatus) " -NoNewline
        
        $azTrafficManagerEndpoint = Get-AzTrafficManagerEndpoint -Name $azTrafficManagerProfileEndpoint.Name -Type ExternalEndpoints -ResourceGroupName $resourceGroup -ProfileName $azTrafficManagerProfile.Name

        switch($azTrafficManagerEndpoint.EndpointMonitorStatus){
            "Online" {$monitorStatusBackgroundColor = "Green"; $monitorStatusForegroundColor = "Black";}
            "Degraded" {$monitorStatusBackgroundColor = "Red"; $monitorStatusForegroundColor = "White";}
            "Disabled" {$monitorStatusBackgroundColor = "Yellow"; $monitorStatusForegroundColor = "Black";}
            Default {$monitorStatusBackgroundColor = "Black"; $monitorStatusForegroundColor = "White";}
        }

        Write-Host " $($azTrafficManagerEndpoint.EndpointMonitorStatus) " -BackgroundColor $monitorStatusBackgroundColor -ForegroundColor $monitorStatusForegroundColor

    }

    $dnsResult = Resolve-DnsName -Name $azTrafficManagerProfile.relativeDnsName -Type CNAME
    
    if($dnsResult.NameHost){
        if($dnsResult.NameHost -ne "$($azTrafficManagerProfile.RelativeDnsName).trafficmanager.net"){
            Write-Host "DNS not set to Traffic Manager" -BackgroundColor Red -ForegroundColor White
            Write-Host "CNAME record is wrong. Should be set to: $($azTrafficManagerProfile.RelativeDnsName).trafficmanager.net"
            Write-Host "But is currently set to: [$($dnsResult.NameHost)]"
        }
    } else {
        Write-Host "DNS not set to Traffic Manager" -BackgroundColor Red -ForegroundColor White
        Write-Host "CNAME record missing. Should be set to: $($azTrafficManagerProfile.RelativeDnsName).trafficmanager.net"
    }

    Write-Host ""

}