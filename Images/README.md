# AVD-Deployment

This script is pretty easy, before run the script is necessary to assign the variables:    
```
* identityname=<Name of the Identity used by the Image Builder Template: testidentity>  
* rg=<Name of the resource group, this should be already created>  
* location=<Location where create the resource: westeurope>  
* galleryname=<gallery name: myGallery>  
* imageDefinitionName=<Image Definition Name: myImageDef>  
* osType=<Specify which OS is base the Image: Windows>  
* offer=<Specify the name of the offer I want assign in my Gallery: myoffer>  
* publisher=<Specify the name of the publisher I want assign in my Gallery: mypublisher>  
* sku=<Specify the name of the SKU I want assign in my Gallery: mysku>  
* imageSource=<Specify the Image Source: MicrosoftWindowsDesktop:Windows-10:20h2-evd-g2:19042.2965.230505>  
* imageTemplate=<Specify the name of the Image Template: win10-ver-1.0.0>
```
  