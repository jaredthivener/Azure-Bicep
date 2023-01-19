targetScope = 'subscription'

// If an environment is set up (dev, test, prod...), it is used in the application name
param environment string = 'dev'
param applicationName string = 'mbusa-app'
param location string = 'eastus2'
var instanceNumber = '001'

var defaultTags = {
  'environment': environment
  'application': applicationName
  'nubesgen-version': 'undefined'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${applicationName}-${instanceNumber}'
  location: location
  tags: defaultTags
}

module instrumentation 'modules/application-insights/app-insights.bicep' = {
  name: 'instrumentation'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    instanceNumber: instanceNumber
    resourceTags: defaultTags
  }
}

module blobStorage 'modules/storage-blob/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    instanceNumber: instanceNumber
  }
}

module redis 'modules/redis/redis.bicep' = {
  name: 'redis'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    instanceNumber: instanceNumber
  }
}

module mongodb 'modules/cosmosdb-mongodb/cosmosdb-mongodb.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'mongo-db'
  params: {
    applicationName: applicationName
    location: location
    tags: {}
  }
}

var applicationEnvironmentVariables = [
// You can add your custom environment variables here
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: instrumentation.outputs.appInsightsInstrumentationKey
      }
      {
        name: 'azure_storage_account_name'
        value: blobStorage.outputs.storageAccountName
      }
      {
        name: 'azure_storage_account_key'
        value: blobStorage.outputs.storageKey
      }
      {
        name: 'azure_storage_connectionstring'
        value: 'DefaultEndpointsProtocol=https;AccountName=${blobStorage.outputs.storageAccountName};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${blobStorage.outputs.storageKey}'
      }
      {
        name: 'MONGODB_HOST'
        value: mongodb.outputs.azure_cosmosdb_mongodb_uri
      }
      {
        name: 'MONGODB_DATABASE'
        value: mongodb.outputs.azure_cosmosdb_mongodb_database
      }
      {
        name: 'MONGODB_KEY'
        value: mongodb.outputs.azure_cosmosdb_mongodb_accountKey
      }
      {
        name: 'REDIS_HOST'
        value: redis.outputs.redis_host
      }
      {
        name: 'REDIS_PASSWORD'
        value: redis.outputs.redis_key
      }
      {
        name: 'REDIS_PORT'
         value: '6380'
      }
]

module webApp 'modules/app-service/app-service.bicep' = {
  name: 'webApp'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    instanceNumber: instanceNumber
    environmentVariables: applicationEnvironmentVariables
  }
}

output application_name string = webApp.outputs.application_name
output application_url string = webApp.outputs.application_url
output resource_group string = rg.name
output container_registry_name string = webApp.outputs.container_registry_name
