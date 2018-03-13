# https://github.com/RamblingCookieMonster/PowerShell/blob/master/Get-AzureRmVmPublicIP.ps1

$vm = Get-AzureRmVM -ResourceGroupName 4sysops -Name dc1

$nic = Get-AzureRmNetworkInterface -ResourceGroupName 4sysops -Name dc1249

$cfg = Get-AzureRmNetworkInterfaceIpConfig 

$pip = Get-AzureRmPublicIpAddress -ResourceGroupName 4sysops


$vms = get-azurermvm
$nics = get-azurermnetworkinterface | where VirtualMachine -NE $null #skip Nics with no VM

foreach($nic in $nics)
{
    $vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
    $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
    $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
    Write-Output "$($vm.Name) : $prv , $alloc"
}


4
5
6
7
8
9
10
11
12
13
14
15
$report = @()
$vms = get-azurermvm
$nics = get-azurermnetworkinterface | ?{ $_.VirtualMachine -NE $null}
 
foreach($nic in $nics)
{
    $info = "" | Select VmName, ResourceGroupName, HostName, IpAddress
    $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id
    $info.VMName = $vm.Name
    $info.ResourceGroupName = $vm.ResourceGroupName
    $info.IpAddress = $nic.IpConfigurations.PrivateIpAddress
    $info.HostName = $vm.OSProfile.ComputerName
    $report+=$info
}
$report


Get-AzureRmNetworkInterface -ResourceGroupName 4sysops | ForEach { $Interface = $_.Name; $IPs = $_ | Get-AzureRmNetworkInterfaceIpConfig | Select PrivateIPAddress; Write-Host $Interface $IPs.PrivateIPAddress }

Get-AzureRmVM -ResourceGroupName ‘HSG-ResourceGroup’ -Name ‘HSG-LinuxVM’ | Get-AzureRmPublicIpAddress

# Thanks for help from Will Anderson, Rhoderick Milne for the assistance.
#
# Get Date; Used only for output file name.
$Date = Get-Date
$NOW = $Date.ToString("yyyyMMddhhmm")
#
# Variables
$MySubscriptionName = "Windows Azure  MSDN - Visual Studio Premium"
$VmsOutFilePath = "C:\temp"
$VmsOutFile = "$VmsOutFilePath\VmList-$NOW.csv"
#
$NeedToLogin = Read-Host "Do you need to log in to Azure? (Y/N)"
if ($NeedToLogin -eq "Y")
{
  Login-AzureRmAccount
  Select-AzureRmSubscription -SubscriptionName $MySubscriptionName
}
elseif ($NeedToLogin -eq "N")
{
  Write-Host "You must already be logged in then.  Fine. Continuing..."
}
else
{
  Write-Host ""
  Write-Host "You made an invalid choice.  Exiting..."
  exit
}
#
$vms = Get-AzureRmVm 
$vmobjs = @()
foreach ($vm in $vms)
{
  #Write-Host ""
  $vmname = $vm.name
  Write-Host -NoNewline "For VM $vmname... "
  Start-Sleep 1
  $vmInfo = [pscustomobject]@{
      'Subscription'= $MySubscriptionName
      'Mode'='ARM'
      'Name'= $vm.Name
      'PublicIPAddress' = $null
      'PrivateIPAddress' = $null
      'ResourceGroupName' = $vm.ResourceGroupName
      'Location' = $vm.Location
      'VMSize' = $vm.HardwareProfile.VMSize
      'Status' = $null
      'OsDisk' = $vm.StorageProfile.OsDisk.Vhd.Uri
      'DataDisksCount' = $vm.StorageProfile.DataDisks.Count
      'AvailabilitySet' = $vm.AvailabilitySetReference.Id }
  $vmStatus = $vm | Get-AzureRmVM -Status
  $vmInfo.Status = $vmStatus.Statuses[1].DisplayStatus
  $vmInfoStatus = $vmStatus.Statuses[1].DisplayStatus
  Write-Host -NoNewline "Get status `("
  if ($vmInfoStatus -eq "VM deallocated")
  {
    Write-Host -ForegroundColor Magenta -NoNewline "$vmInfoStatus"
  }
  elseif ($vmInfoStatus -eq "VM stopped")
  {
    Write-Host -ForegroundColor Yellow -NoNewline "$vmInfoStatus"
  }
  elseif ($vmInfoStatus -eq "VM generalized")
  {
    Write-Host -ForegroundColor Gray -NoNewline "$vmInfoStatus"
  }
  else
  {
    Write-Host -ForegroundColor White -NoNewline "$vmInfoStatus"
  }
  Write-Host -NoNewline "`)... "
  $VMagain = (Get-AzureRmVm -ResourceGroupName $vm.ResourceGroupName -Name $vmname)
  $NifName = ($VMagain.NetworkProfile[0].NetworkInterfaces.Id).Split('/') | Select-Object -Last 1
  $MyInterface = (Get-AzureRmNetworkInterface -Name $NifName -ResourceGroupName $VMagain.ResourceGroupName).IpConfigurations
  $PrivIP = $MyInterface.privateipaddress
  $vmInfo.PrivateIPAddress = $PrivIP
  Write-Host -NoNewline "Getting Private IP `($PrivIP`)... "
  try
  {
    $PubIPName = (($MyInterface).PublicIPAddress.Id).split('/') | Select-Object -Last 1
    $vmPublicIpAddress = (Get-AzureRmPublicIpAddress -Name $PubIPName -ResourceGroupName $Vmagain.ResourceGroupName).IpAddress 
    Write-Host -NoNewline "Getting public IP `("
    Write-Host -ForegroundColor Cyan -NoNewline "$vmPublicIpAddress"
    Write-Host -NoNewline "`)... "
    $vmInfo.PublicIPAddress = $vmPublicIpAddress
  }
  catch
  {
    Write-Host -NoNewline "No public IP... "
  }
  Write-Host -NoNewline "Add server object to output array... "
  $vmobjs += $vmInfo
  Write-Host "Done."
}  
Write-Host "Writing to output file: $VmsOutFile"
$vmobjs | Export-Csv -NoTypeInformation -Path $VmsOutFile
Write-Host "...Complete!"









