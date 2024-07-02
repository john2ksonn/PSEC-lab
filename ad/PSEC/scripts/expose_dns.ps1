<#
Configure DNS service to listen on all IP addresses.
-> seems to not fully work
#>
$DnsServerSettings = Get-DnsServerSetting -ALL
$DnsServerSettings.ListeningIPAddress = $DnsServerSettings.AllIPAddress
Set-DnsServerSetting $DnsServerSettings
