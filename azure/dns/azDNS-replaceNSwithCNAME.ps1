$subDomain = 'www'
$domain = 'domain.tld'
$resourceGroup = ''

$rs = Get-AzDnsRecordSet -ZoneName $domain -ResourceGroupName $resourceGroup -Name $subDomain -RecordType NS
Remove-AzDnsRecordSet -RecordSet $rs
New-AzDnsRecordSet -Name $subDomain -RecordType CNAME -ZoneName domain.tld -ResourceGroupName $resourceGroup -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -Cname $subDomain.$domain.trafficmanager.net) 
