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
param workspaceName string = 'TestDev-AVD-PROD'
//End Parameters Section


// Create the HostPool
var CustomRdpProperties='drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;'
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-09-09' =  {
  name: hostPoolName
  location: location
  properties: {
    friendlyName: hostPoolFriendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    customRdpProperty: CustomRdpProperties
    preferredAppGroupType: 'Desktop'
    personalDesktopAssignmentType: personalDesktopAssignmentType
    maxSessionLimit: maxSessionLimit
    validationEnvironment: false
    registrationInfo: {
      expirationTime: tokenExpirationTime
      token: null
      registrationTokenOperation: 'Update' //Generate the Registration Token
    }
  }
}
// Create the Application Group
var appGroupName = '${hostPoolName}-DAG'
resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-09-09' = {
  name: appGroupName
  location: location
  properties: {
    friendlyName: appGroupFriendlyName
    applicationGroupType: 'Desktop'
    description: 'Deskop Application Group created through test Deploy process.'
    hostPoolArmPath: resourceId('Microsoft.DesktopVirtualization/hostpools', hostPoolName)
  }
  dependsOn: [
    hostPool // Wait the HostPool is created
  ]
}
// Assign the Application Group to the Workspace
var applicationGroupReferencesArr = array(applicationGroup.id)
resource workspace 'Microsoft.DesktopVirtualization/workspaces@2022-09-09' = {
  name: workspaceName
  location: location
  properties: {
    applicationGroupReferences: applicationGroupReferencesArr
  }
}
// Put in output the Registration Token
output tokenvalue string = reference(hostPool.id, '2021-01-14-preview').registrationInfo.token //hostPool.properties.registrationInfo.token
