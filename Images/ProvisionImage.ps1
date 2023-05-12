
#Create the Managed Identity to use with Image Template
identity=$(az identity create -n $identityname -g $rg -l $location)
#Create the Azure Compute Gallery
gallery=$(az sig create --resource-group $rg --gallery-name $galleryname)
#Pick the Gallery ID
galleryID=$(echo $gallery| grep -o '"id": *"[^"]*"' | grep -o '"[^"]*"$')
galleryID=${galleryID//\"/}
#Pick the PrincipalID for the Managed Identity
principalid=$(echo $identity | grep -o '"principalId": *"[^"]*"' | grep -o '"[^"]*"$')
principalid=${principalid//\"/}

#Assign the contributor role the the RG, I would suggest to keep all the image in a separated Resource Group
az role assignment create --assignee $principalid --role "Contributor" --resource-group $rg
# Create the Image Definition in the Gallery that is used to group the Image versions
az sig image-definition create --gallery-name $galleryname --os-type $osType -g $rg -p $publisher -f $offer -s $sku -i $imageDefinitionName --architecture x64 --hyper-v-generation V2 --os-state Generalized 
#The follow command store the change in a cache, then last command will upload all the changes from the share in Azure
#Create the Image Builder Template with definition of the source and destination image
imageDefinitionVersion="$galleryID/images/$imageDefinitionName/versions/$imageversion"
az image builder create -n $imageTemplate -g $rg --vm-size $vmsizeAIB --identity $identityname --image-source $imageSource --shared-image-destinations $imageDefinitionVersion=$location --defer
#Add a customizer task where execute a simple powershell command to create a folder
az image builder customizer add -n $imageTemplate -g $rg --customizer-name myPwshScript1 --exit-codes 0 1 --inline-script "mkdir c:\buildActions" "echo Azure-Image-Builder-Was-Here \> c:\buildActions\Output.txt" --type powershell --defer
#Add a customizer task where download and install Notepad++
az image builder customizer add -n $imageTemplate -g $rg --customizer-name myPwshScript2 --exit-codes 0 1 --inline-script "Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.2/npp.8.5.2.Installer.x64.exe' -o $pwd\npp.exe -useBasicParsing' 'Unblock-File -path  $pwd\npp.exe' '$pwd\npp.exe /S'" --type powershell --defer
#Add a customizer task where run windows update
#az image builder customizer add -n $imageTemplate -g $rg --customizer-name winUpdate --type windows-update --update-limit 20 --defer
#Add a customizer task where restart the VM
#az image builder customizer add -n $imageTemplate -g $rg --customizer-name restart --type windows-restart --restart-timeout 10m --defer
#Update the Image Builder Template uploading the previous change from cache to Azure
az image builder update -n $imageTemplate -g $rg
#Start the Imabe Builder Pipeline to create the image, this task can take long time to complete
az image builder run -n $imageTemplate -g $rg --no-wait