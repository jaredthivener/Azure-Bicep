param location string = 'westus'
param clusterName string = uniqueString(resourceGroup().id)
param subnetId string = '/subscriptions/f645938d-2368-4a99-b589-ea72e5544719/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/default'
param nodeCount int = 1
param vmSize string = 'standard_d2s_v3'

resource clusterName_resource 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: vmSize
        mode: 'System'
        vnetSubnetID: subnetId
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
      }
    ]
    publicNetworkAccess: 'Disabled'
    networkProfile: {
      networkPolicy: 'calico'
      networkPlugin: 'kubenet'
      serviceCidr: '192.168.0.0/24'
      dnsServiceIP: '192.168.0.10'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
  }
}
