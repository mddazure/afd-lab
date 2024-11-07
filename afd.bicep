param location string
param name string
param web1address string
param web2address string

resource afd 'Microsoft.Network/frontDoors@2021-06-01' = {
  name: name
  location: location
  properties: {
    enabledState: 'Enabled'
    frontendEndpoints:[
      {
        name: '${name}-frontend'
        properties: {
        hostName: 'yada-afd.azurefd.net'
        sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]
    healthProbeSettings: [
      {
        name: 'probe1'
        properties: {
          path: '/healthcheck'
          protocol: 'Http'
          intervalInSeconds: 30
          }
      }
      ]
    backendPools: [
      {
        name: '${name}-backendpool'
        properties: {
          backends: [
            {
              address: web1address
              httpPort: 80
              httpsPort: 443
            }
            {address: web2address
              httpPort: 80
              httpsPort: 443
            }
          ]
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', name, 'probe1')
          }
        }
      }
    ]
    friendlyName: name
    routingRules: [
      {
        name: 'rule1'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', name, '${name}-frontend')
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', name, '${name}-backendpool')
            }
          }
        }
      }
    ]
  }
}

output afdid string = afd.id
