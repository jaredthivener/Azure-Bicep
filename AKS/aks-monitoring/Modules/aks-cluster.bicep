param location string = 'eastus2'
param clusterName string = 'aks${uniqueString(resourceGroup().id)}'

param nodeCount int = 1
@description('2vCPU | 7GB Memory | 86GB cache')
param vmSize string = 'Standard_DS2_v2'
param logAnalyticsWorkspaceResourceID string 

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-10-02-preview' = {
  name: clusterName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'system'
        count: nodeCount
        vmSize: vmSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'System'
        osDiskType: 'Ephemeral'
        osDiskSizeGB: 60
        nodeLabels: {
          poolType: 'system'
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceID
        }
      }
    }
  }
}

//Create AKS Node Pool - App 
resource aksNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2022-10-02-preview' = {
  name: 'app'
  parent: aksCluster
  properties: {
        count: nodeCount
        vmSize: vmSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        osDiskType: 'Ephemeral'
        osDiskSizeGB: 60
        nodeLabels: {
          poolType: 'app'
        }
  }
}


