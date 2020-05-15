#Requires -RunAsAdministrator

Write-Host "List certificates without private key: " -NoNewline

$certsWithoutKey = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.HasPrivateKey -eq $false}


if($certsWithoutKey) {

    Write-Host "V" -ForegroundColor Green

    $Choice = $certsWithoutKey | Select-Object Subject, Issuer, NotAfter, ThumbPrint | Out-Gridview -Passthru

    if($Choice){

        Write-Host "Search private key for $($Choice.Thumbprint): " -NoNewline
        $Output = certutil -repairstore my "$($Choice.Thumbprint)"

        $Result = [regex]::match($output, "CertUtil: (.*)").Groups[1].Value
        if($Result -eq '-repairstore command completed successfully.') {

            Write-Host "V" -ForegroundColor Green

        } else {

            Write-Host $Result -ForegroundColor Red

        }

    } else {

        Write-Host "No choice was made." -ForegroundColor DarkYellow

    }

} else {

    Write-Host "There were no certificates found without private key." -ForegroundColor DarkYellow

}