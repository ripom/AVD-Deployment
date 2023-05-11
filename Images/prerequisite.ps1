identityname="testidentity"
rg="testavd"
location="westeurope"
galleryname="myGallery"
imageDefinitionName="myImageDef"
osType="Windows"
offer="offer"
publisher="publisher"
sku="sku"
imageSource="MicrosoftWindowsDesktop:Windows-10:20h2-evd-g2:19042.2965.230505"
imageTemplate="myTemplate"

identity=$(az identity create -n $identityname -g $rg -l $location)
gallery=$(az sig create --resource-group $rg --gallery-name $galleryname)
galleryID=$(echo $gallery| grep -o '"id": *"[^"]*"' | grep -o '"[^"]*"$')
principalid=$(echo $identity | grep -o '"principalId": *"[^"]*"' | grep -o '"[^"]*"$')
principalid=${principalid//\"/}
galleryID=${galleryID//\"/}
#az role assignment create --assignee $principalid --role "Image Template Contributor" --scope $galleryID
az role assignment create --assignee $principalid --role "Contributor" --resource-group $rg
az sig image-definition create --gallery-name $galleryname --os-type $osType -g $rg -p $publisher -f $offer -s $sku -i $imageDefinitionName --architecture x64 --hyper-v-generation V2 --os-state Generalized 
az image builder create -n $imageTemplate -g $rg --identity $identityname --image-source $imageSource --shared-image-destinations $galleryname/$imageDefinitionName=$location 
