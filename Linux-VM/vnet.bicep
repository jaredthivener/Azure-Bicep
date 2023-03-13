param location string = resourceGroup().location
param vNetName string = 'bicep${uniqueString(resourceGroup().id)}'

//Virtual-Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'bicep${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh'
        properties: {
          description: 'ssh'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}


output vnetId string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
