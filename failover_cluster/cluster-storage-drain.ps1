$clusterSharedVolumes = Get-ClusterSharedVolume | Select -ExpandProperty SharedVolumeInfo

$chosenCSV = ($clusterSharedVolume | Select-Object FriendlyVolumeName | Out-GridView -PassThru).FriendlyVolumeName

$clusterNodes = Get-ClusterNode | Select-Object Name -ExpandProperty Name

$allVMs = Get-VM -ComputerName $clusterNodes | Get-VMHardDiskDrive

$vmsOnCSV = $allVMs | Where-Object {$_.Path -like "$chosenCSV*"} | Select-Object VMName, ComputerName | Get-Unique -AsString

foreach($vmOnCSV in $vmsOnCSV){

    $BestVolume = ((Get-ClusterSharedVolume | Where-Object { $_.SharedVolumeInfo.FriendlyVolumeName -ne $chosenCSV } | Select -ExpandProperty SharedVolumeInfo | Select @{label="Name";expression={(($_.FriendlyVolumeName).Split("\"))[-1]}},@{label="FreeSpace";expression={($_ | Select -Expand Partition).FreeSpace}} | Sort FreeSpace -Descending)[0])

    $DestinationStoragePath = "C:\ClusterStorage\$($BestVolume.Name)\$($vmOnCSV.VMName)"

    Write-Host "Move $($vmOnCSV.VMName) to $DestinationStoragePath"
    Move-VMStorage -ComputerName $($vmOnCSV.ComputerName) -VMName $($vmOnCSV.VMName) -DestinationStoragePath "C:\ClusterStorage\$($BestVolume.Name)\$($vmOnCSV.VMName)"

}