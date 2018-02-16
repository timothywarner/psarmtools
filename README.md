# New-ARMNamingConvention
This PowerShell function generates an Azure Resource Manager naming convention in accordance with best practices and and naming limitations.

## Usage
The function has two (mandatory) parameters:

* **Project**: Your project name must begin with a letter and contain no more than four characters
* **Environment**: You can specify Development, Staging, Testing, or Production

Here's an example showing partial output:

```
PS C:\>New-ARMNamingConvention -Project 'plur' -Environment 'Development'

Name DisplayName       Type Value          
    
rg   Resource Group    PaaS plur-18-rg-dev 
vm   Virtual Machine   IaaS plur-18-vm-dev 
st   Storage Account   IaaS plur18stdev   
```
In the above output, the **18** represents a two-digit hexadecimal identifier. As you know, some Azure resources need to be globally unique.

Notice the storage account's format; this defers to the (frustrating) limitations of lowercase, alphanumeric storage account names with no intervening hyphens or underscores.

You are limited to a maximum of four characters for your project name. Don't get angry! Azure has a 15-character requirement for virtual machine names, so I applied that 15-character maximum to all these proposed resource names. Better safe than sorry!

## TODO
* Finish comment-based help
* Include additional Azure resources
* Organize the IaaS and PaaS categories
* Incorporate Pester tests
* Add functionality to the output object

## Credit
Special thanks to the following friends and fellow PowerShell community members for their help:

* Jeff Hicks ([@jeffhicks](https://twitter.com/jeffhicks)) - I couldn't have done this without you :)
* Mike F. Robbins ([@mikefrobbins](https://twitter.com/mikefrobbins)) - Your code is my main reference material 
* Adam Bertram ([@adbertram](https://twitter.com/adbertram)) - Your Pluralsight courses are fantastic