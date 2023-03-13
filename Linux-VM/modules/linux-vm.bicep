param location string = resourceGroup().location
param vmName string = 'bicep${uniqueString(resourceGroup().id)}'
param adminUsername string
@secure()
param adminPassword string
param storageUri string 
param subnetId string 

//Linux VM
resource ubuntuVM 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  zones: [
    '1'
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v4'
    }
    osProfile: {
      computerName: 'bicep${uniqueString(resourceGroup().id)}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'bicep${uniqueString(resourceGroup().id)}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageUri
      }
    }
  }
}


resource linuxAgent 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  name: 'AzureMonitorLinuxAgent'
  parent: ubuntuVM
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.25'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': ubuntuVM.identity.principalId
        }
      }
    }
  }
}


//Linux VM - NIC
resource networkinterface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'bicep${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    nicType: 'Standard'
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          primary: true
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'bicep${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    deleteOption: 'Delete'
    dnsSettings: {
      domainNameLabel: 'bicep${uniqueString(resourceGroup().id)}'
    }
  }
}
