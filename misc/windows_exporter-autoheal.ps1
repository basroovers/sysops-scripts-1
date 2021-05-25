$prometheusUri = "http://domain.tld:9090"
$jobName = "jobname"
$service = 'windows_exporter'

$upStatusDownResults = Invoke-RestMethod -Uri "$prometheusUri/api/v1/query?query=up%7Bjob%3D""$jobName""%7D%20%3D%3D%200"

if(!$cred){
    $cred = get-Credential
}

foreach($computer in $upStatusDownResults.data.result.metric.node){

    Write-Host "$computer" -ForegroundColor Green

    Invoke-Command -ComputerName $computer -Credential $cred -ArgumentList $service -ScriptBlock {

        $service = $args[0]

        $service = Get-Service $service

        if($service.Status -eq 'Stopped'){

            Write-Host "Service is not running, will now try to start"

        Start-Service $service

        } else {

            Write-Host "Service is running"

        }

    }

}

