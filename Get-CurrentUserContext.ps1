function Get-CurrentUserContext
{
  [CmdletBinding()]
  [Alias('whom')]
  Param
  (
    [Parameter(ValueFromPipeline, Position=1)]
    [string[]]$ComputerName = $env:COMPUTERNAME
  )

  Begin
  {
  }
    
  Process
  {
      foreach ($comp in $ComputerName)
      {
          $userName = Invoke-Command -ComputerName $comp -ScriptBlock {$env:USERNAME}   
          $isAdmin =  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
          $hostName = Invoke-Command -ComputerName $comp -ScriptBlock {$env:COMPUTERNAME}        
          $isDomain = (Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $comp).Domain
          $isWorkgroup = (Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $comp).Workgroup
          $FQDN= (Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $comp).DNSHostName + "." + $isDomain
       
          $data = [ordered]@{
              User        = $userName
              IsAdmin     = $isAdmin
              Host        = $hostName
              Workgroup   = $isWorkgroup
              Domain      = $isDomain
              FQDN        = $FQDN
          }

          $out = New-Object -TypeName PSCustomObject -Property $data

          if ((Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain -eq $true)
              {
                  $out | Select-Object -Property User, IsAdmin, Host, Domain, FQDN
              }
          else
              {
                  $out | Select-Object -Property User, IsAdmin, Host, Workgroup, FQDN
              }
      }
  }
  End
  {
  }
}