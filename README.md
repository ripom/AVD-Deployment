# AVD-Deployment

This repository contains a sample AVD HostPool and HostSession deployment using BICEP script.
The script use Windows 11 Market Place Image, you can change the image in the script.
This is a draft and it's still in development but it can be used as first step to deploy your first HostPoll using IaC.
  

The pre-requisite for this template you need:  
1- to create a Resource Group  
2-Contributor permission on the RG  
3-Contributor permission on the VNET you are using to deploy the Session Host to  

To use this template you can run this command and replace with your parameters:  
az deployment group create --name test -g nordics --template-file main.bicep  --parameters \\  
    location=<location: westeurope> \\  
    subnetID=<subnet ID that you can copy from the Azure Portal> \\  
    vmPrefix=<vm prefix> \\  
    AVDnumberOfInstances=<this is an integer and it is the number of the host session you want create> \\  
    vmSize=<vm size SKU: Standard_DS2_v2> \\  
    administratorAccountUserName=<local username> \\  
    administratorAccountPassword=<Password for the local user> \\  
    vmDiskType=vm size disk Standard_LRS> \\  
    hostPoolName=<host pool name> \\  
    hostPoolFriendlyName=<host pool friendly name> \\  
    tokenExpirationTime=$(date -d '+24 hours' --iso-8601=seconds) \\  
    appGroupFriendlyName=<Application Group name: AppGroup-DAG> \\  
    workspaceName=< Workspace Name: TestWorkspace>
  