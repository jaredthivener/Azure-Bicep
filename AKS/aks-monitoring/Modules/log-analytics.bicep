param location string = 'eastus2'
param workspaceName string = 'aks${uniqueString(resourceGroup().id)}'
param appInsightsName string = 'aks${uniqueString(resourceGroup().id)}'

//Create Log Analytics Workspace 
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    features: {
      immediatePurgeDataOn30Days: true
    }
  }
}

//Create App insights component
resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

output WorkspaceResourceId string = logAnalyticsWorkspace.id
