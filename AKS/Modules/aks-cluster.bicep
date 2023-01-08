param location string = 'eastus2'
param clusterName string = 'aks${uniqueString(resourceGroup().id)}'

param nodeCount int = 1
param vmSize string = 'standard_d3s_v3'
param logAnalyticsWorkspaceResourceID string 

resource aks 'Microsoft.ContainerService/managedClusters@2022-03-02-preview' = {
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
resource aksCluster 'Microsoft.ContainerService/managedClusters/agentPools@2022-10-02-preview' = {
  name: 'app'
  parent: aks
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


