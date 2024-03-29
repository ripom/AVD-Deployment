//Start Parameters Section
param location string
param hostPoolName string
@description('Friendly Name of the Host Pool, this is visible via the AVD client')
param hostPoolFriendlyName string
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string = 'Pooled'
@allowed([
  'BreadthFirst'
  'DepthFirst'
  'Persistent'
])
param loadBalancerType string = 'BreadthFirst'
@allowed([
  'Automatic'
  'Direct'
])
param personalDesktopAssignmentType string = 'Direct'
param maxSessionLimit int = 10
@description('Expiration time for the HostPool registration token. This must be up to 30 days from todays date.')
param tokenExpirationTime string
param appGroupFriendlyName string
@description('Name of the AVD Workspace to used for this deployment')
param workspaceName string 
param AVDnumberOfInstances int
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param vmDiskType string
param vmSize string
param administratorAccountUserName string
@secure()
param administratorAccountPassword string
param subnetID string
param vmPrefix string
@allowed(['Marketplace','Gallery'])
param imageType string

param publisher string=''
param offer string=''
param sku string=''
param ImageVersion string=''

param rgSIG string=''
param SIGname string=''
param ImageDefName string=''
//End Parameters Section

var imageRefMap = {
  Marketplace:{
    publisher: publisher
    offer: offer
    sku: sku
    version: ImageVersion //'22621.1555.230329'
  }
  Gallery:{
    id: resourceId(rgSIG, 'Microsoft.Compute/galleries/images/versions', SIGname, ImageDefName, ImageVersion)
  }
} 

// Invoke Module to create the HostPool and applicationgroup
module hostpool 'hostpool.bicep' = {
  name: 'hostpool-${deployment().name}'
  params: {
    location: location
    hostPoolName: hostPoolName
    hostPoolFriendlyName: hostPoolFriendlyName
    hostPoolType: hostPoolType
    appGroupFriendlyName: appGroupFriendlyName
    loadBalancerType: loadBalancerType
    personalDesktopAssignmentType: personalDesktopAssignmentType
    tokenExpirationTime: tokenExpirationTime
    maxSessionLimit: maxSessionLimit
    workspaceName: workspaceName
  }
}

//Invoke the module to create the HostSession in the HostPool
module VMs './vm-sessionhosts.bicep' = {
  name: 'VMs-${deployment().name}'
  params: {
    location: location
    administratorAccountUserName: administratorAccountUserName
    administratorAccountPassword: administratorAccountPassword
    vmDiskType: vmDiskType
    vmPrefix: vmPrefix
    vmSize: vmSize
    AVDnumberOfInstances: AVDnumberOfInstances
    subnetID: subnetID
    registrationToken: hostpool.outputs.tokenvalue
    imageRef: imageRefMap[imageType]
  }
  dependsOn: [
    hostpool
  ]
}
