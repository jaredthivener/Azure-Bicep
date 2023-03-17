targetScope = 'subscription'

param location string = 'eastus2'
param rgName string = 'rg-aks'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module aks 'Modules/aks-cluster.bicep' = {
  name: 'aks-cluster'
  scope: rg
  params: {
    location: location
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
