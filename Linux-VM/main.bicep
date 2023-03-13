targetScope = 'subscription'

param location string = 'eastus2'
param rgName string = 'rg-bicep'
param rgvNet string = 'rg-vnet'
param tags object = {
  Environment: 'Dev'
  Administrator: 'Jared'
  Team: 'Cloud'
}

param adminUsername string
@secure()
param adminPassword string 

//Create Resource Group - Linux VM
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: tags
}

//Create Resource Group - vNet 
resource rgNetwork 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgvNet
  location: location
  tags: tags
}

//Storage Account Module
module storage 'storage.bicep' = {
  scope: resourceGroup
  name: 'storage'
  params: {
    environmentType: 'dev'
    location: location
    virtualNetworkSubnetId: vnet.outputs.subnetId
  }
}

//Virtual Network Module
module vnet 'vnet.bicep' = {
  scope: rgNetwork
  name: 'vnet'
  params: {
    location: location
  }
}

//Linux VM
module linux_vm 'linux-vm.bicep' = {
  scope: resourceGroup
  name: 'linux-vm'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    storageUri: storage.outputs.storageAccountUri
    subnetId: vnet.outputs.subnetId
    location: location
  }
}
