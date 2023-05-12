# AVD-Deployment

This repository contains BICEP and Powershell scripts to deploy HostPool and Host Session for Azure Virtual Desktop (AVD).
There is one folder named Images where you can find the script to build the Custom Images
Another folder named hostsession where you can find 2 more folders, BICEP and Powershell, you can use one (depends of your needs and experience) to deploy HostPool and HostSessions in your AVD environment.

# Create and distribute custom image using AIB

You can use the powershell script provided in the Images folder to build and distribute the Custom Image in your Azure Compute Gallery  
The script will create:  
```
the Azure Compute Gallery
the Image Definition
the Image Template (that it use Azure Image Builder to build and distribute a new image in your gallery)
```

# Create HostPool and deploy Host Session in the HostPool
You can use BICEP or powershell to perform this task.
BICEP has also the option to deploy the Host Sesion using Custom Image. 