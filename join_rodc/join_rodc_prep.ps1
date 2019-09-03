#requires -RunAsAdministrator

Param
(
    [Parameter(Mandatory=$true)][string]$serverName,
    [Parameter(Mandatory=$true)][string]$ouPath,
    [Parameter(Mandatory=$true)][string]$fqdnRODC,
    [Parameter(Mandatory=$true)][string]$fqdnRWDC,
    [Parameter(Mandatory=$true)][string]$computerPassword,
    [Parameter(Mandatory=$true)][string]$rodcPasswordWhitelist
)

If ((Get-WmiObject -class win32_optionalfeature | Where-Object { $_.Name -eq 'RemoteServerAdministrationTools'}) -ne $null) {
    Throw "RSAT not installed."
}

## Preparing variables
$cred = Get-Credential
$distinguishedServerName = "CN=" + $serverName + "," +$ouPath
$SecurePassword=ConvertTo-SecureString $computerPassword -asplaintext -force

## Create new computer object
New-ADComputer -Name $ServerName -SamAccountName $ServerName -Path $ouPath -Credential $cred -Server $fqdnRWDC

## Set temporary password on new computer object
Set-ADAccountPassword -Identity $distinguishedServerName -Credential $cred -NewPassword $SecurePassword -Server $fqdnRWDC

## Add new computer object to AD group which is allowed to replicate passwords to read-only domain controller
Add-ADGroupMember -Identity $rodcPasswordWhitelist -members $distinguishedServerName -Credential $cred -Server $fqdnRWDC

## Sync new computer object to read-only domain controller
Sync-ADObject -Object $distinguishedServerName -Source $fqdnRWDC -Destination $fqdnRODC -PasswordOnly -PassThru