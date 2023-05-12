
#Create HostPool - Personakl Automatic  
az desktopvirtualization hostpool create --name $hostpoolname --resource-group $resourcegroup --host-pool-type Personal --load-balancer-type Persistent --preferred-app-group-type Desktop --personal-desktop-assignment-type Automatic --location $location  
  
#Create Desktop Application Group  
hostPoolArmPath=$(az desktopvirtualization hostpool show  --name $hostpoolname--resource-group $resourcegroup --query [id] --output tsv)  
az desktopvirtualization applicationgroup create --name $appGroupName --resource-group $resourcegroup --application-group-type Desktop --host-pool-arm-path $hostPoolArmPath --location $location  
  
#Generate the registration Token that last 1 day  
az desktopvirtualization hostpool update  --name $hostpoolname --resource-group $resourcegroup --registration-info expiration-time=$(date -d '+24 hours' --iso-8601=seconds) registration-token-operation="Update"  
#Read the registration Key  
registrationKey=$(az desktopvirtualization hostpool retrieve-registration-token --name $hostpoolname --resource-group $resourcegroup --query token --output tsv)  
  
#Create VM Quickstart - Create a Windows VM using the Azure CLI - Azure Virtual Machines | Microsoft Learn  
az vm create --resource-group $resourcegroup --name $vmName --image $vmImage --assign-identity --admin-username $username --admin-password $userpass --subnet $vnetSubnetID --size $vmSize --os-disk-size-gb $vmOSdiskSizeGB --public-ip-address ""  
  
#AzureAD Join Log in to a Windows virtual machine in Azure by using Azure AD - Microsoft Entra | Microsoft Learn  
az vm extension set --publisher Microsoft.Azure.ActiveDirectory --name AADLoginForWindows --resource-group $resourcegroup --vm-name $vmName  
  
#Install and register AVD Agent Add session hosts to a host pool - Azure Virtual Desktop | Microsoft Learn  
az vm run-command invoke -g $resourcegroup -n $vmName --command-id RunPowerShellScript --scripts 'param([string]$registrationKey)' 'Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -o $pwd\RDagentBootLoader.msi -useBasicParsing' 'Unblock-File -path  $pwd\RDagentBootLoader.msi' 'msiexec /i $pwd\RDAgentBootLoader.msi /quiet' 'Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -o $pwd\RDagent.msi -useBasicParsing' 'Unblock-File -path $pwd\RDagent.msi' 'msiexec /i $pwd\RDAgent.msi /quiet REGISTRATIONTOKEN=$registrationKey' --parameters "registrationKey=$registrationKey"  
