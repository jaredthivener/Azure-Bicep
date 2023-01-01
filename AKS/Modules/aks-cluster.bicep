param location string = 'eastus2'
param clusterName string = 'aks${uniqueString(resourceGroup().id)}'

param nodeCount int = 1
param vmSize string = 'standard_d2s_v3'
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
        osDiskType: 'Ephemeral'
        mode: 'System'
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

