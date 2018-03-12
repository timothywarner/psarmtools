function New-ARMSecurityPrincipal
{
  [CmdletBinding()]
  Param (

    # Use to set scope to resource group. If no value is provided, scope is set to subscription.
    [Parameter()]
    [String] $ResourceGroup='4sysops',

    # Use to set subscription. If no value is provided, default subscription is used. 
    [Parameter()]
    [String] $SubscriptionId='',

    [Parameter(Mandatory=$true)]
    [String] $ApplicationDisplayName='',
    
    [Parameter()]
    [string] $CertSubject='CN=AzureScriptCert'
  )

  process
  {
    if ($SubscriptionId -eq '') 
    {
      $SubscriptionId = (Get-AzureRmContext).Subscription.Id
    }
    else
    {
      Set-AzureRmContext -SubscriptionId $SubscriptionId
    }

    if ($ResourceGroup -eq '')
    {
      $Scope = "/subscriptions/" + $SubscriptionId
    }
    else
    {
      $Scope = (Get-AzureRmResourceGroup -Name $ResourceGroup -ErrorAction Stop).ResourceId
    }

    $cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" -Subject "CN=exampleappScriptCert" -KeySpec KeyExchange
    $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

    $ServicePrincipal = New-AzureRMADServicePrincipal -DisplayName $ApplicationDisplayName -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore
    Get-AzureRmADServicePrincipal -ObjectId $ServicePrincipal.Id 

    $NewRole = $null
    $Retries = 0
    While ($NewRole -eq $null -and $Retries -le 6)
    {
      # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
      Start-Sleep 15
      New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $ServicePrincipal.ApplicationId -Scope $Scope | Write-Verbose -ErrorAction SilentlyContinue
      $NewRole = Get-AzureRMRoleAssignment -ObjectId $ServicePrincipal.Id -ErrorAction SilentlyContinue
      $Retries++
    }
  }
}

<#
And then use the following code to authenticate:

Param (

  [Parameter(Mandatory=$true)]
  [String] $CertSubject,

  [Parameter(Mandatory=$true)]
  [String] $ApplicationId,

  [Parameter(Mandatory=$true)]
  [String] $TenantId
 )

 $Thumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -match $CertSubject }).Thumbprint
 Connect-AzureRmAccount -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -TenantId $TenantId
 #>
