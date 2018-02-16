#Requires -Version 3.0
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
    [Parameter(Mandatory,HelpMessage='Project name must begin with a letter and contain no more than four characters.')]   
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

    [Parameter(Mandatory,HelpMessage='You must choose an environment value from the validate set')]
    [ValidateSet('Development','Staging','Testing','Production')]
    [string]$Environment
  )

  Begin
  {
    $Unique = ((1..2 | ForEach-Object{ '{0:X}' -f (Get-Random -Max 16) }) -join '').ToLower()
     
    switch ($Environment)
    {
      'development'{ $EnvWorking = 'dev'}
      'staging'    { $EnvWorking = 'stg'}
      'testing'    { $EnvWorking = 'tst'}
      'production' { $EnvWorking = 'prd'}
    }
    
    #store data in a CSV format to make it easier to convert to objects later.
    $data = @"
    "Name","Displayname","Type"
    "rg","Resource Group","PaaS"
    "vm","Virtual Machine","IaaS"
    "st","Storage Account","IaaS"
    "as","Availability Set","PaaS"
    "vn","Virtual Network","IaaS"
    "ln","Local Network","IaaS"
    "sn","Subnet","IaaS"
    "gw","Gateway","IaaS"
    "lb","Load Balancer","IaaS"
    "nic","Network Interface","IaaS"
    "tm","Traffic Manager","IaaS"
    "ip","Public IP Address","IaaS"
    "wa","Web App","PaaS"
    "api","API App","PaaS"
    "la","Logic App","PaaS"
    "sql","SQL Server","PaaS"
    "sp","App Service Plan","PaaS"
    "db","Database","PaaS"    
"@

    
    
    
    
    
    
  }
  Process
  {
      $data | ConvertFrom-Csv | foreach-object {
        if ($_.name -eq 'st') {
            $Value = "$($Project.toLower())$Unique$($_.name)$EnvWorking"
        }
        else {
            $value = "$($Project.toLower())-$Unique-$($_.name)-$EnvWorking"
        }
        #add the name value as a new property
        $_ | Add-Member -MemberType NoteProperty -Name Value -Value $Value -PassThru
        }


   
   
  }
          

  }
  End
  {
  
  }

New-ARMNamingConvention -Project 'plu' -Environment 'Staging'