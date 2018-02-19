function Get-ARMVmStatus {
  <#
      .SYNOPSIS
      Obtains Azure VM runtime status  
 
      .DESCRIPTION
      Get-ARMVmStatus is a PowerShell function that makes it easier to obtain the run status of selected or all VMs. The -ResourcGroup parameter scopes your query to a particular resource group. The -All switch parameter retrieves VM status across all resource groups within the active Azure subscription. Be careful with this option because your request will be throttled by the Azure platform if you have a lot of VMs (you're considered to be 'hammering' the Resource Manager Compute APIs too hard).
 
      .PARAMETER IPAddress
      The IPAddress(es) to return the Geolocation information for.
 
      .EXAMPLE
      Get-ARMVmStatus -ResourceGroup 'myRG'
 
      .EXAMPLE
      Get-ARMVmStatus -All
 
      .EXAMPLE
      vms -res 'myrg1'
 
      .INPUTS
      String
 
      .OUTPUTS
      PSCustomObject
 
      .NOTES
      Author:  Timothy Warner
      Website: timwarnertech.com
      Twitter: @TechTrainerTim
      Credit: I adapted code from a few different sources. Thanks to those developers for the "leg up": http://timw.info/s01; http://timw.info/s02
  #>
  [CmdletBinding(DefaultParameterSetName = 'default',
                 ConfirmImpact = 'low')]
  [Alias("vms")]
  Param (
    [Parameter(ParameterSetName = 'default')]
               [string]$ResourceGroup,
               
    [Parameter(ParameterSetName = 'All')]
               [switch]$All  
  )
  
  Begin {
    # test for RG existence
    if ($All -eq $False) {
        $rggroup = Get-AzureRmResourceGroup
        foreach ($rgz in $rggroup) {
            if ($rggroup.ResourceGroupName -notcontains $ResourceGroup) {
                throw "$ResourceGroup is not a valid resource group name in the current subscription."
            }
        }
     }
  }

    Process {
      if ($All) {
          $RGs = Get-AzureRMResourceGroup
          foreach($RG in $RGs) {
              $VMs = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName
              foreach($VM in $VMs) {
                  $VMDetail = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name -Status
                  $RGN = $VMDetail.ResourceGroupName  
                  foreach ($VMStatus in $VMDetail.Statuses) { 
                      if($VMStatus.Code -like ("PowerState/*")) {
                          $VMStatusDetail = $VMStatus.DisplayStatus
                        }
                      $out = [PSCustomObject]@{
                              ResourceGroup = $RGN
                              Name = $VM.Name
                              Status = $VMStatusDetail
                          }
                  }
                  $out | Select-Object -Unique  | Sort-Object -Property ResourceGroup
              }
          }
      }
      else {
          
        $name = '*'
        Get-AzureRmVM -ResourceGroupName $ResourceGroup |
        Get-AzureRmVM -Status |
        Select-Object -Property Name, Statuses |
        Where-Object -FilterScript {$_.Name -like $Name} |
        ForEach-Object {
          $VMName = $_.Name
          $_.Statuses |
          Where-Object {$_.Code -like 'PowerState/*'} |
          ForEach-Object {
              $props = [ordered]@{
                  ResourceGroup = $ResourceGroup
                  Name = $VMName
                  Status = $_.DisplayStatus
              }
              New-Object -TypeName PSCustomObject -Property $props
          }
        }
      }
    }
}
