$cluster = Get-Cluster

Write-Host "Getting cluster nodes: " -NoNewline

$clusterNodes = Get-ClusterNode -Cluster $cluster

Write-Host "V" -ForegroundColor Green

$virtualMachines = ForEach($clusterNode in $clusterNodes) {

    Write-Host "Get virtual machines running on $($clusterNode.Name): " -NoNewline

    Get-VM -ComputerName $clusterNode.Name | Select-Object Name, State, MemoryAssigned, ProcessorCount, HardDrives, ComputerName

    Write-Host "V" -ForegroundColor Green
}

$vmListParsed = @()

ForEach($vm in $virtualMachines) {
    Write-Host "Get data from $($vm.Name): " -NoNewline
    $vmHardDriveProvisioned = 0
    ForEach($vmHardDrive in $vm.HardDrives){
        $vmHardDriveProvisioned = $vmHardDriveProvisioned + ((Get-VHD -Path $vmHardDrive.Path -ComputerName $vm.ComputerName).Size)
    }

    switch ($vm.Status)
    {
        "Operating normally" { $vmStatus = "Active"}
        "Off" { $vmStatus = "Offline"}
    }

    $vmParsed = New-Object System.Object
    $vmParsed | Add-Member -MemberType NoteProperty -Name "name" -Value $vm.Name.ToLower()
    $vmParsed | Add-Member -MemberType NoteProperty -Name "status" -Value $vmStatus
    $vmParsed | Add-Member -MemberType NoteProperty -Name "vcpus" -Value $vm.ProcessorCount
    $vmParsed | Add-Member -MemberType NoteProperty -Name "memory" -Value ($vm.MemoryAssigned / 1MB)
    $vmParsed | Add-Member -MemberType NoteProperty -Name "disk" -Value ($vmHardDriveProvisioned / 1GB)
    $vmParsed | Add-Member -MemberType NoteProperty -Name "cluster" -Value $cluster.Name.ToLower()

    $vmListParsed += $vmParsed
    Write-Host "V" -ForegroundColor Green

}

$vmListParsed | ConvertTo-CSV | Out-File -FilePath "C:\Temp\Netbox_all.csv" -Encoding utf8


