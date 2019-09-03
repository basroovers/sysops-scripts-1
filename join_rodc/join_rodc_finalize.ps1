#requires -RunAsAdministrator

Param
(
    [Parameter(Mandatory=$true)][string]$serverName,
    [Parameter(Mandatory=$true)][string]$ouPath,
    [Parameter(Mandatory=$true)][string]$fqdnRODC,
    [Parameter(Mandatory=$true)][string]$computerAccountPassword,
    [Parameter(Mandatory=$true)][string]$domainName,
    [Parameter(Mandatory=$true)][string]$dynamicSiteName
)

## Set the DNS suffix search list
Set-DnsClientGlobalSetting -SuffixSearchList @("$domainName")

# Set DynamicSiteName
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "DynamicSiteName" -Value $dynamicSiteName -PropertyType String -Force

## Domain join with RODC
Write-Host "Joining domain" -BackgroundColor Black -ForegroundColor Green
Set-Variable JOIN_DOMAIN -option Constant -value 1                  # Joins a computer to a domain. If this value is not specified, the join is a computer to a workgroup
Set-Variable MACHINE_PASSWORD_PASSED -option Constant -value 128    # The machine, not the user, password passed. This option is only valid for unsecure joins
Set-Variable NETSETUP_JOIN_READONLY -option Constant -value 2048    # Use an RODC to perform the domain join against

$readOnlyDomainJoinOption = $JOIN_DOMAIN + $MACHINE_PASSWORD_PASSED + $NETSETUP_JOIN_READONLY
$localComputerSystem = Get-WMIObject Win32_ComputerSystem
$localComputerSystem.Rename($serverName)
$returnErrorCode = $localComputerSystem.JoinDomainOrWorkGroup($fqdnADdomain+"\"+$fqdnRODC,$computerAccountPassword,$null,$null,$readOnlyDomainJoinOption)

$returnErrorDescription = switch ($($returnErrorCode.ReturnValue)) {
	0 {"SUCCESS: The Operation Completed Successfully."} 
	5 {"FAILURE: Access Is Denied."} 
	53 {"FAILURE: The Network Path Was Not Found."}
	64 {"FAILURE: The Specified Network Name Is No Longer Available."}
	87 {"FAILURE: The Parameter Is Incorrect."} 
	1219 {"FAILURE: Logon Failure: Multiple Credentials In Use For Target Server."}
	1326 {"FAILURE: Logon Failure: Unknown Username Or Bad Password."} 
	1355 {"FAILURE: The Specified Domain Either Does Not Exist Or Could Not Be Contacted."} 
	2691 {"FAILURE: The Machine Is Already Joined To The Domain."} 
	default {"FAILURE: Unknown Error!"}
}
	
If ($($returnErrorCode.ReturnValue) -eq "0") {
	Write-Host "Domain Join Result Code...: $($returnErrorCode.ReturnValue)" "SUCCESS"
	Write-Host "Domain Join Result Text...: $returnErrorDescription" "SUCCESS"
} Else {
	Write-Host "Domain Join Result Code...: $($returnErrorCode.ReturnValue)" "ERROR"
	Write-Host "Domain Join Result Text...: $returnErrorDescription" "ERROR"
}
	
If ($($returnErrorCode.ReturnValue) -eq "0") {
	Write-Host "All went well, please reboot."
}