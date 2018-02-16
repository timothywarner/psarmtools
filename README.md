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


## TODO
* Write comment-based help
* Organize the IaaS and PaaS categories