param location string = resourceGroup().location
param storgeAccountName string = 'bicep${uniqueString(resourceGroup().id)}'
@allowed([
'dev'
'prod'
])
param environmentType string
@description('if the envronment type is set to "dev" then Standard_LRS will be used, if "prod" Standard_ZRS will be used.')
var storageAccountskuType = (environmentType == 'dev') ? 'Standard_LRS' : 'Standard_ZRS'
param virtualNetworkSubnetId string 

//Create Storage Account
resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storgeAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountskuType
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: virtualNetworkSubnetId
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
    }
  }
}
//Output the storage account uri - blob endpoint
output storageAccountUri string = storageaccount.properties.primaryEndpoints.blob
