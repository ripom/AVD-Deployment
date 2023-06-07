//Start Parameters Section
param AVDnumberOfInstances int
@description('Location for all standard resources to be deployed into.')
param location string
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
param registrationToken string
param imageRef object

//Create NICs based on the number of instances
resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${vmPrefix}-${i}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
        }
      }
    ]
  }
}]

//Create VMs based on the number of instances
resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${vmPrefix}-${i}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vmPrefix}-${i}'
      adminUsername: administratorAccountUserName 
      adminPassword: administratorAccountPassword
      windowsConfiguration: {
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
    }
    storageProfile: {
      osDisk: {
        name: '${vmPrefix}-${i}-OS'
        managedDisk: {
          storageAccountType: vmDiskType
        }
        osType: 'Windows'
        createOption: 'FromImage'
      }
      imageReference: imageRef
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmPrefix}-${i}-nic')
        }
      ]
    }
  }
  dependsOn: [
    nic[i] //Wait the NICs are created
  ]
}]

// Join the VMs to AAD
//https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/extensions?pivots=deployment-language-bicep
resource vmAADjoinextension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${vmPrefix}-${i}/AADLoginForWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory' 
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: false
  }
  dependsOn: [
    vm[i] //Wait the VMs are created
  ]
}]

//Run a script to install the AVD Agent and join the VMs to the HostPool
//https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines/runcommands?pivots=deployment-language-bicep
resource vmRunCommand 'Microsoft.Compute/virtualMachines/runCommands@2022-11-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${vmPrefix}-${i}/vmRunCommand'
  location: location
  properties: {
    parameters: [
      {
        name: 'registrationToken'
        value: registrationToken
      }
    ]
    source: { //Run a powershell script: Download the 2 Agents and install the Agents configuring the last one with the registrationToken
      script: '''param([string]$registrationToken)
      Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -o $pwd\\RDagentBootLoader.msi -useBasicParsing
      Unblock-File -path  $pwd\\RDagentBootLoader.msi; msiexec /i $pwd\\RDAgentBootLoader.msi /quiet
      Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -o $pwd\\RDagent.msi -useBasicParsing; Unblock-File -path $pwd\\RDagent.msi
      msiexec /i $pwd\\RDAgent.msi /quiet REGISTRATIONTOKEN=$registrationToken'''
    }
  }
  dependsOn: [
    vm[i] //Wait the VMs are created
  ]
}]
