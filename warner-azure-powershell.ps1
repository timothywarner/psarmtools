#Requires -Version 3.0
<# .SYNOPSIS
     Azure PowerShell Jump Start - Presentation for Nashville PowerShell User Group
.DESCRIPTION
     March 13, 2018
.NOTES
     Author     : Tim Warner
     Twitter:   : @TechTrainerTim
.LINK
     http://timw.info/ajs
#>
#break

# Set location
Set-Location -Path (Split-Path -Path $psISE.CurrentFile.FullPath)

# Install Azure PowerShell
Find-Module -Name AzureRM -Repository PSGallery -AllVersions | Select-Object -Property Version, PublishedDate
Install-Module -Name AzureRM -Repository PSGallery -Verbose -Force

# Update local help
Update-Help -Force -ErrorAction SilentlyContinue

# Authenticate to Azure
Connect-AzureRmAccount

Select-AzureRmSubscription -Subscription 'Microsoft Azure Sponsorship'

Get-AzureRmContext

Enable-AzureRmContextAutosave -Scope CurrentUser -Verbose

# Module discovery
Get-Module -ListAvailable -Name AzureRM* | Select-Object -Property Name, Version | format-table -AutoSize

Get-Module -ListAvailable -Name AzureRM* | Measure-Object

Get-Command -Module AzureRM* | Measure-Object

# Command discovery
Get-Command -Module AzureRM.Compute | Select-Object -Property Name

Get-Command -Module AzureRM.Compute -Verb Get | Select-Object -Property Name

Get-Help -Name Get-AzureRmVM -Online

Get-Help -Name Get-AzureRmVMSize -Examples

Get-AzureRmVMSize -Location 'South Central US'

Get-Command -Verb Get -Noun AzureRM*location*

Get-AzureRmLocation | Select-Object -Property DisplayName, Location | Format-Table -AutoSize

# Common Azure VM operations
Get-AzureRmVM -ResourceGroupName 4sysops

# Start and stop VMs
Get-AzureRmVM -ResourceGroupName 4sysops | Start-AzureRmVM

Get-AzureRmVM -ResourceGroupName 4sysops | Stop-AzureRmVM -Force

# Remote into a VM
Get-AzureRmPublicIpAddress -ResourceGroupName 4sysops | Select-Object -Property Name, IPAddress

$vm = 13.92.249.88

$session = New-PSSession -ComputerName $vm -Credential (Get-Credential)

Enter-PSSession -Session $session

# Small resource deployment
New-AzureRmResourceGroup -Name 'NashvillePUG' -Location 'South Central US'

New-AzureRmStorageAccount -ResourceGroupName 'NashvillePUG' -Name 'nashpugst9876' -SkuName Standard_LRS -Location 'South Central US' -Kind StorageV2

$s = Get-AzureRmStorageAccount -ResourceGroupName 'NashvillePUG' -StorageAccountName 'nashpugst9876'

$s | Get-Member

$s.PrimaryEndpoints | Format-List

Get-AzureRmStorageAccountKey -ResourceGroupName 'NashvillePUG' -Name 'nashpugst9876' | Select-Object -Property KeyName, Value | Format-List

Remove-AzureRmStorageAccount -ResourceGroupName 'NashvillePUG' -Name 'nashpugst9876' -Force

# Big resource deployment
ise .\azuredeploy.json

ise .\azuredeploy.parameters.json

New-AzureRmResourceGroup -Name 'justtesting' -Location 'South Central US'

New-AzureRmResourceGroupDeployment -Name 'SimpleWindowsVM' `
    -ResourceGroupName 'justtesting' `
    -Mode Complete `
    -TemplateFile '.\azuredeploy.json' `
    -TemplateParameterFile '.\azuredeploy.parameters.json' `
    -Verbose

# Azure Key Vault

# Install and import the CredentialVault community module
Install-Module -Name AxCredentialVault -Repository PSGallery -Force -Verbose

Import-Module -Name AxCredentialVault

# Set variables
$location = 'SouthCentralUS'

$name = 'TimKeyVault7837'

# Capture credentials
$creds = Get-Credential

# Connect to ARM
$azureRM = Connect-AzureRmAccount -Credential $creds -Subscription 'Microsoft Azure Sponsorship'

# Create a vault
$AzCredVault = New-AzureCredentialVault -Credential $creds -SubscriptionID $AzureRM.Context.Subscription.Id -ResourceGroupName $name -StorageAccountName $name.ToLower() -Location $location -VaultName $name -Verbose 

# Connect to the vault
$AzCredVault2 = Connect-AzureCredentialVault -Credential $creds -SubscriptionID $AzureRM.Context.Subscription.Id -ResourceGroupName $name -StorageAccountName $name.ToLower() -VaultName $name -Verbose 

# Add a credential to the vault
Set-AzureCredential -UserName 'AzServiceAccount' -Password ($pwd = Read-Host -AsSecureString) -VaultName $name -StorageAccountName $name -Verbose

# Retrieve credentials
$AzVaultCreds = Get-AzureCredential -UserName 'AzServiceAccount' -VaultName $name -StorageAccountName $name -Verbose

# Automating Azure authentication
ise .\New-ARMSecurityPrincipal.ps1
