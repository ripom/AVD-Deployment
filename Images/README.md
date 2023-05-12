# Create and distribute custom image using AIB

You can use the powershell script provided in the Images folder to build and distribute the Custom Image in your Azure Compute Gallery  
The script will create:  
```
the Azure Compute Gallery
the Image Definition
the Image Template (that it use Azure Image Builder to build and distribute a new image in your gallery)
```
  
The pre-requisite you need for this script:  
* create a Resource Group  

  
This script is pretty easy, before run the script is necessary to assign the variables:    
```
identityname=<Name of the Identity used by the Image Builder Template: testidentity>  
rg=<Name of the resource group, this should be already created>  
location=<Location where create the resource: westeurope>  
galleryname=<gallery name: myGallery>  
imageDefinitionName=<Image Definition Name: myImageDef>  
osType=<Specify which OS is base the Image: Windows>  
offer=<Choose the name of the offer I want assign in my Gallery: myoffer>  
publisher=<Choose the name of the publisher I want assign in my Gallery: mypublisher>  
sku=<Choose the name of the SKU I want assign in my Gallery: mysku>  
imageSource=<Specify the Image Source: MicrosoftWindowsDesktop:Windows-10:20h2-evd-g2:19042.2965.230505>  
imageTemplate=<Choose the name of the Image Template (will add automatically the version in the name): win10>
vmsizeAIB=<VM Size using during the image builder: Standard_D16_v5>
imageversion=<1.0.4>
```  
If you need to find the exact ImageSource you are looking for, you can use this command (that include a filder on Windows10):  
az vm image list --offer Windows-10 --all --output table  
  
To view the details for the specific Image use this command:  
az vm image show --offer Windows-10 --publisher MicrosoftWindowsDesktop --sku win10-22h2-entn-g2 --version 19045.2846.230329 -l westeurope