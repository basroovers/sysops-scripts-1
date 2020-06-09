$distinguishedName = "OU=Computers,DC=domain,DC=Local"

$searcher = New-Object system.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = "LDAP://$distinguishedName"
$searcher.filter = "(objectclass=computer)"
$searcher.PropertiesToLoad.Add("dnshostname") | out-null
$adSearchResult = ($searcher.FindAll()).Properties

foreach($adComputer in $adSearchResult){

    Write-Host "$($adComputer.dnshostname)" -BackgroundColor White -ForegroundColor Black

    $psSession = New-PSSession -Credential $credential -ComputerName $($adComputer.dnshostname)

    Invoke-Command -Session $psSession -ScriptBlock {

        $volumes = Get-Volume | Where-Object {($_.DriveType -eq "Fixed") -and ($_.DriveLetter)} | Sort-Object DriveLetter

        foreach($volume in $volumes) {
            
            Write-Host "Disk $($volume.DriveLetter): " -NoNewline
            $scanResult = Repair-Volume -Scan -DriveLetter $volume.DriveLetter
            Write-Host "$scanResult"
        }
    }

    Remove-PSSession -Session $psSession

}