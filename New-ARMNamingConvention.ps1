#Requires -Version 3.0
function New-ARMNamingConvention
{
<#
    .Synopsis
    Generates an Azure resource naming convention based on Microsoft best practice guidelines.
    .DESCRIPTION
    New-ARMNamingConvention is a PowerShell advanced function that simplifies the generation of a consistent Azure resource naming convention. The function takes into account both Microsoft best practices as well as known resource naming limitations.
    .PARAMETER Project
    Deployment name. This could be part of a company name or a project name.
    .PARAMETER Environment
    The target environment. Options include Development, Staging, Testing, and Production.
    .EXAMPLE
    New-ARMNamingConvention -Project 'plura' -Environment 'Development'
    .EXAMPLE
    New-ARMNamingConvention -Project 'xyza' -Environment 'Testing' | Where-Object {$_.Type -eq 'PaaS'}
    .INPUTS
    String
    .OUTPUTS
    PSCustomObject
    .NOTES
    Author: Tim Warner
    Website: timwarnertech.com
    Twitter: @TechTrainerTim
#>

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
    # Generate a two-digit hex string to serve as a unique identifier 
    $Unique = ((1..2 | ForEach-Object{ '{0:X}' -f (Get-Random -Max 16) }) -join '').ToLower()
    
    # Translate the environment parameter into desired three-character format 
    switch ($Environment)
    {
      'development'{ $EnvWorking = 'dev'}
      'staging'    { $EnvWorking = 'stg'}
      'testing'    { $EnvWorking = 'tst'}
      'production' { $EnvWorking = 'prd'}
    }
    
    #Store data in CSV format to make it easier to convert to objects later
    $data = @"
    "Name","DisplayName","Type"
    "sub","Subscription","Global"
    "rg","Resource Group","Global"
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
        if ($_.name -eq 'st')
        {
            $Value = "$($Project.toLower())$Unique$($_.name)$EnvWorking"
        }
        else
        {
            $value = "$($Project.toLower())-$Unique-$($_.name)-$EnvWorking"
        }
        #add 'Value' as a new property
        $_ | Add-Member -MemberType NoteProperty -Name Value -Value $Value -PassThru
      }
  }
  }
  End
  {
  
  }
