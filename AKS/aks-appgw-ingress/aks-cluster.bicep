@secure()
param sshpub string
param name string
param adminusername string
param appgwid string
param servicecidr string
param podcidr string
param dockercidr string
param dnsservice string
param subnetid string
param location string
param appgwname string

resource aks 'Microsoft.ContainerService/managedClusters@2021-10-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'akspoc'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: 1
        vmSize: 'Standard_D2s_v3'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: subnetid
      }
    ]
    linuxProfile: {
      adminUsername: adminusername
      ssh: {
        publicKeys: [
          {
            keyData: sshpub
          }
        ]
      }
    }
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayId: appgwid
        }
      }
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      podCidr: podcidr
      serviceCidr: servicecidr
      dockerBridgeCidr: dockercidr
      dnsServiceIP: dnsservice
    }
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2021-05-01' existing = {
  name: appgwname
}

resource contrib 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('aks-contrib-roleassignment-agic')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: aks.properties.addonProfiles.ingressApplicationGateway.identity.objectId
    principalType: 'ServicePrincipal'
  }
  scope: appgw
}

resource read 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid('aks-read-roleassignment-agic')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
    principalId: aks.properties.addonProfiles.ingressApplicationGateway.identity.objectId
    principalType: 'ServicePrincipal'
  }
  scope: resourceGroup()
}
