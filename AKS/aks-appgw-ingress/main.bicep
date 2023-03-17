param sshpub string
param location string = resourceGroup().location
param appgwname string = 'appgw${uniqueString(resourceGroup().id)}'
var appgwid = resourceId('Microsoft.Network/applicationGateways', appgwname)

param k8scidr string = '10.0.0.192/27'
param dockercidr string = '10.0.0.224/27'
param dnsservice string = '10.0.0.202'

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/25'
        }
      }  
      {
        name: 'ApplicationGateway'
        properties: {
          addressPrefix: '10.0.0.128/26'
        }
      }
    ]
  }
}

resource appgwsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: '${vnet.name}/ApplicationGateway'
}

resource defaultsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: '${vnet.name}/default'
}

resource appgwpip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'appgw-pip-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2022-09-01' = {
  name: appgwname
  location: location
  properties: {
    sku: {
      name: 'Standard_v3'
      tier: 'Standard_v3'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'
        properties: {
          subnet: {
            id: appgwsubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: appgwpip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    probes: [
      {
        name: 'defaultHttpProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'defaultBackendAddressPool'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'defaultHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: 'defaultHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: '${appgwid}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          protocol: 'Http'
          frontendPort: {
            id: '${appgwid}/frontendPorts/port_80'
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'defaultReqRoutingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${appgwid}/httpListeners/defaultHttpListener'
          }
          backendAddressPool: {
            id : '${appgwid}/backendAddressPools/defaultBackendAddressPool'
          }
          backendHttpSettings: {
            id: '${appgwid}/backendHttpSettingsCollection/defaultHttpSettings'
          }
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 2
    }
  }
}

module aks 'modules/aks-cluster.bicep' = {
  name: 'aks-poc'
  params: {
    name: 'aks-${uniqueString(resourceGroup().id)}'
    adminusername: 'azureadmin'
    sshpub: sshpub
    appgwid: appgw.id
    appgwname: appgwname
    servicecidr: k8scidr
    podcidr: defaultsubnet.properties.addressPrefix
    dockercidr: dockercidr
    dnsservice: dnsservice
    subnetid: defaultsubnet.id
    location: location
  }
}
