# Deploy HostPool and Host Sessions using BICEP

This BICEP repository contains a sample AVD HostPool and HostSession deployment using BICEP script.  
The script has a main file that call 2 modules one to create the hostpool and another one to create the vost sessions.  
In this specific case you have 2 different BICEP main files, 2 different BICEP vm-sessionshost files and one BICEP hostpool file, this is to have the option to deploy Host Session using Marketplace Images or using Azure Compute Gallery based Images.

  
```
The pre-requisite you need for this script:  
* create a Resource Group  
* Permission to attach the VM to the VNET you provide  
```
  
# Deploy Host Sessions using Marletplace Images  
```
To use this template you can run this command and replace with your parameters:  
az deployment group create --name <specify the name of the deployment> -g <Specify the name of the ResourceGroup created in the prerequisite> \
    --template-file main.bicep  --parameters \  
    location=<location: westeurope> \  
    subnetID=<subnet ID that you can copy from the Azure Portal> \  
    vmPrefix=<vm prefix> \  
    AVDnumberOfInstances=<this is an integer and it is the number of the host session you want create> \  
    vmSize=<vm size SKU: Standard_DS2_v2> \  
    administratorAccountUserName=<local username> \  
    administratorAccountPassword=<Password for the local user> \  
    vmDiskType=<vm size disk Standard_LRS> \  
    hostPoolName=<host pool name> \  
    hostPoolFriendlyName=<host pool friendly name> \  
    tokenExpirationTime=$(date -d '+24 hours' --iso-8601=seconds) \  
    appGroupFriendlyName=<Application Group name: AppGroup-DAG> \  
    workspaceName=<Workspace Name: TestWorkspace> \
    publisher=<Specify the Publisher: MicrosoftWindowsDesktop> \
    offer=<Speficy the Offer: Windows-11> \
    sku=<Specify the SKU: win11-22h2-entn> \
    ImageVersion=<Specify the Image Version: latest>
```
  

# Deploy Host Sessions using Custom Images  
```
To use this template you can run this command and replace with your parameters:  
az deployment group create --name <specify the name of the deployment> -g <Specify the name of the ResourceGroup created in the prerequisite> \
    --template-file main-customImage.bicep  --parameters \  
    location=<location: westeurope> \  
    subnetID=<subnet ID that you can copy from the Azure Portal> \  
    vmPrefix=<vm prefix> \  
    AVDnumberOfInstances=<this is an integer and it is the number of the host session you want create> \  
    vmSize=<vm size SKU: Standard_DS2_v2> \  
    administratorAccountUserName=<local username> \  
    administratorAccountPassword=<Password for the local user> \  
    vmDiskType=<vm size disk Standard_LRS> \  
    hostPoolName=<host pool name> \  
    hostPoolFriendlyName=<host pool friendly name> \  
    tokenExpirationTime=$(date -d '+24 hours' --iso-8601=seconds) \  
    appGroupFriendlyName=<Application Group name: AppGroup-DAG> \  
    workspaceName=<Workspace Name: TestWorkspace> \
    rgSIG=<Specify the name of the ResourceGroup where the Azure Compute Gallery has been deployed: testavd> \
    SIGname=<Specify the name of the Azure Compute Gallery: myGallery> \
    ImageDefName=<Specify the Image Definition Name: myImageDef> \
    ImageVersion=<Specify the Image Version: latest>
```