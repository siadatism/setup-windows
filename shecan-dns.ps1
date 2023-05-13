#Requires -RunAsAdministrator

if ($args.count -ne 1 -or (($args[0] -ne "set") -and ($args[0] -ne "clear")))
{
	$args.count
	Write-Host "Error: Incorrect input arguments." -ForegroundColor red
	
	$scriptName = Split-Path -Path $PSCommandPath -Leaf
	Write-Host "Usage:" -ForegroundColor green
	Write-Host $scriptName, "set    # Sets Shekan DNS"
	Write-Host $scriptName, "clear  # Clears DNS"
	exit 1
}

# Get primary interface index, source: "https://superuser.com/a/1626051/1797013"
$desiredInterfaceIndex = Get-NetRoute | % { Process { If (!$_.RouteMetric) { $_.ifIndex } } };

Write-Host "Selected Interface: " -ForegroundColor green
Get-NetAdapter -InterfaceIndex $desiredInterfaceIndex | Format-List -Property "Name", "InterfaceDescription", "InterfaceName"

# Shekan DNS, "https://shecan.ir/"
$shekanPrimaryDNS = "178.22.122.100"
$shekanSecondaryDNS = "185.51.200.2"

# Change DNS, source: "https://superuser.com/a/1625641/1797013"	
if ($args[0] -eq "set")
{
	Set-DNSClientServerAddress -interfaceIndex $desiredInterfaceIndex -ServerAddresses ("$shekanPrimaryDNS", "$shekanSecondaryDNS");
}
else
{
	Set-DnsClientServerAddress -interfaceIndex $desiredInterfaceIndex -ResetServerAddresses
}

if ($?)
{
	Write-Host "DNS changed successfully." -ForegroundColor green
	exit 0
}
else
{
	Write-Host "DNS failed to change." -ForegroundColor red
	exit 2
}