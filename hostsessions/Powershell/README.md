# Deploy HostPool and Host Sessions using Powershell

The pre-requisite you need for this script:  
* create a Resource Group  
* Permission to attach the VM to the VNET you provide  

This script is pretty easy, before run the script is necessary to assign the variables:    
```
#declare variables  
hostpoolname=<host pool name>  
resourcegroup=<resource group name>  
location=<location>  
appGroupName=<Application Group Name: Desktop-AG>  
vmName=<VM Name>  
username=<local username>  
userpass=<Local user password>  
vmImage=<VM Image: MicrosoftWindowsDesktop:Windows-10:win10-22h2-entn:19045.2364.221205>    
vnetSubnetID=<subnet ID where want attach the host session>  
vmSize=<VM Sike SKU: Standard_DS2_v2>  
vmOSdiskSizeGB=<OS Disk size: 128>  
```

If you need to find the exact ImageSource you are looking for, you can use this command (that include a filder on Windows10):  
***az vm image list --offer Windows-10 --all --output table***  
  
To view the details for the specific Image use this command:  
***az vm image show --offer Windows-10 --publisher MicrosoftWindowsDesktop --sku win10-22h2-entn-g2 --version 19045.2846.230329 -l westeurope***
  