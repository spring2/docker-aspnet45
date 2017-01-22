# this script is to deal with the fact that windows containers always takes the hosts vEthernet ip as their first DNS entry regardless of how docker is configured to run
# https://github.com/docker/docker/issues/30260

$if = get-netipinterface -AddressFamily IPv4 -ConnectionState Connected
$ifIndex = $if[0].ifIndex
#$ifIndex

#Get-DnsClientServerAddress -AddressFamily IPv4  -InterfaceIndex $ifindex

$servers = Get-DnsClientServerAddress -AddressFamily IPv4  -InterfaceIndex $ifindex | Select-Object -ExpandProperty ServerAddresses
#$servers

$dgw = Get-NetIPConfiguration -InterfaceIndex $ifindex

$dg = $dgw.IPv4DefaultGateway.NextHop
#$dg



#write-host "------"
$new = $servers | where {$dg -NotContains $_}
#$new


Set-DNSClientServerAddress -interfaceIndex $ifIndex -ServerAddresses($new)

Get-DnsClientServerAddress -AddressFamily IPv4  -InterfaceIndex $ifindex