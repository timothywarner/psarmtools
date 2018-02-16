#Requires -Version 3.0
# Put help inside the function.
# Make parameters more intuitive and in proper case
# Instead of concatenation, use subexpressions. 
# don't think you need to explicitly call Write-Output. Just type the value you want written to the pipeline.
# meaningful variable names (what is $e?)
# No, don't include csv output in your function. It should write an object to the pipeline that if you need to be a CSV, you can then pipe your command to a CSV cmdlet.



function New-ARMNamingConvention
<#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .PARAMETER PName1
    Description
    .EXAMPLE
    Example of how to use this cmdlet
    .EXAMPLE
    Another example of how to use this cmdlet
    .INPUTS
    String
    .OUTPUTS
    PSCustomObject
    .NOTES
    Author: Tim Warner
    Website: timwarnertech.com
    Twitter: @TechTrainerTim
#>
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$true,HelpMessage='Project name must begin with a letter and contain no more than four characters.')]   
    [ValidateScript({
          If (($_ -notmatch "^(-|_|[0-9])") -And ($_ -match "([a-zA-Z]|[0-9])$"))
          {
            $True
          }
          else
          {
            Throw "$_ needs to begin with a letter and contain no more than four characters."
          }
    })]
    [ValidateLength(1,4)]
    [string]$Project,

    [Parameter(Mandatory=$true, HelpMessage='You must choose an environment value from the validate set')]
    [ValidateSet('Development','Staging','Testing','Production')]
    [string]$Environment
  )

  Begin
  {
    $ProjectWorking = $Project.ToLower()
        
    if ($ProjectWorking -match  '^(_|-|[0-9])')
    {
      Throw New-Object -TypeName System.ArgumentException -ArgumentList "Sorry. Your project name must begin with a letter."
    }
        
    if ($ProjectWorking.Length -gt 4)
    {
      Write-Error -Message ("Sorry. Your project name is " + $ProjectWorking.Length + " characters, and needs to be 4 or fewer.") -Category InvalidArgument
      throw "Terminating error"
    }
         
    $Unique = ((1..2 | ForEach-Object{ '{0:X}' -f (Get-Random -Max 16) }) -join '').ToLower()
     
    switch ($Environment)
    {
      'development'{ $EnvWorking = 'dev'}
      'staging'    { $EnvWorking = 'stg'}
      'testing'    { $EnvWorking = 'tst'}
      'production' { $EnvWorking = 'prd'}
    }
    
  }
  Process
  {
    # Todo: Sort the resources by type (Perhaps IaaS and PaaS) 
   
    $resources = [ordered]@{rg='Resource Group';
                            vm='Virtual Machine';
                            st='Storage Account';
                            as='Availability Set';
                            vn='Virtual Network';
                            ln='Local Network';
                            sn='Subnet';
                            gw='Gateway';
                            lb='Load Balancer';
                            nic='Network Interface';
                            tm='Traffic Manager';
                            ip='Public IP Address';
                            wa='Web App';
                            api='API App';
                            la='Logic App';
                            sql='SQL Server';
                            sp='App Service Plan';
                            db='Database';
   
    }
          
    $resources.GetEnumerator() | ForEach-Object { 
            
      if ($($_.key) -eq 'st')
      {
        Write-Output -InputObject ("$($_.value): $ProjectWorking$Unique$($_.key)$EnvWorking")
      }
      else
      {
        Write-Output -InputObject ("$($_.value): $ProjectWorking" + '-' + $Unique + '-' + "$($_.key)-$EnvWorking")
      }
    }

  }
  End
  {
    $out = New-Object -TypeName System.Management.Automation.PSCustomObject
    $out | Add-Member -MemberType NoteProperty 'Resource' $($_.Value)
    Write-Output $out
  
  }
}
New-ARMNamingConvention -Project 'plu' -Environment 'Staging'