$clusterNodes = Get-ClusterNode | Select-Object Name -ExpandProperty Name

if(!$clusterNodes){Throw "No nodes found, please run this script on one of the nodes."}

Write-Host "The following nodes are part of the cluster: "
$clusterNodes | ForEach-Object { Write-Host "- $($_.Name)" }
Write-Host ""

Write-Host "Fetch VHDs from nodes: " -NoNewline
$ActiveVHDs = (Get-VM -ComputerName $clusterNodes | Get-VMHardDiskDrive | Select-Object -Property Path).Path
Write-Host "V" -ForegroundColor Green
Write-Host ""


Write-Host "Fetch VHDs from storage: " -NoNewline
$HyperVFileLocation = ("C:\ClusterStorage")
$Dir = Get-ChildItem $HyperVFileLocation -Recurse -ErrorAction Ignore | Where-Object {$_.FullName -notmatch "\\Replica\\?" } 
$AllVHDs = ($Dir | Where-Object { $_.Extension -eq ".vhd" }).FullName + ($Dir | Where-Object { $_.Extension -eq ".vhdx" }).FullName
Write-Host "V" -ForegroundColor Green
Write-Host ""

Write-Host "Compare VHDs of storage with nodes: " -NoNewline
$orphanedVHDs = @()
foreach($vhd in $AllVHDs){
    if($vhd -notin $ActiveVHDs){
        $orphanedVHDs += $vhd
    }
}
Write-Host "V" -ForegroundColor Green
Write-Host ""
if($orphanedVHDs){
    Write-Host "List of orphaned VHDs:"
    $orphanedVHDs
} else {
    Write-Host "Nice work, no orphaned VHDs found!" -ForegroundColor Green
}