targetScope = 'subscription'

param location string = 'eastus2'
param resourcePrefix string = 'aksbicep'

var resourceGroupName = '${resourcePrefix}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module aks 'Modules/aks-cluster.bicep' = {
  name: '${resourcePrefix}cluster'
  scope: rg
  params: {
    location: location
    clusterName: resourcePrefix
    logAnalyticsWorkspaceResourceID: log.outputs.WorkspaceResourceId
  }
}

module log 'Modules/log-analytics.bicep' = {
  scope: rg
  name: 'log-analytics'
  params: {
    location: location
  }
}
