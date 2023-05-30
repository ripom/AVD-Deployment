# AVD-Deployment using Pulumi

This repository contains Pulumi Python scripts to deploy HostPool and Host Session for Azure Virtual Desktop (AVD).
The script will create one ResourceGroup, one HostPool, one Workspace and variable number of Virtual Machines.

# Pre-requisite

Before run pulumi up and create the infrastructure, it's necessary to create the pulumi stack and add the config's parameters:  
```
pulumi config set rg <Resource Group Name>
pulumi config set hostpoolType <Host Pool type, example: Pooled>
pulumi config set hostpoolLB <Host Pool Load Balancer, example: BreadthFirst>
pulumi config set hostpoolMaxSession <Number of max sessions>
pulumi config set hostpoolDeskAssign <Who is the Host Pool Desktop Assignment, example: Automatic>
pulumi config set hostpoolAppGroupType <Host Pool Application Group type, example: Desktop>
pulumi config set tagName1 <Tag Name>
pulumi config set tagValue1 <Tag Value>
pulumi config set workspaceDescription <Workspace description>
pulumi config set workspaceFriendlyName <Workspace friendly Name>
pulumi config set workspaceName <Workspace Name>
pulumi config set vmPrefixName <Virtual Machine prefix Name>
pulumi config set maxVM <Number of virtual machine to be created>
pulumi config set sizeVM <The virtual machine SKU sie, example: Standard_DS2_v2>
pulumi config set subnetID <THe subnet ID where add the VMs>
pulumi config set VMusername <Local administrator username>
pulumi config set --secret VMpassword <Local admnistrator password>
pulumi config set publisher <Marketplace Image Publisher, example: MicrosoftWindowsDesktop>
pulumi config set offer Marketplace Image Offer, example: Windows-11>
pulumi config set sku <Marketplace Image SKU, example: win11-22h2-entn>
pulumi config set version Marketplace Image Version, example: latest>
```

# Create the HostPool
Once the stack config is created and the parameter value have been added to the config, it's time to run the pulumi up 