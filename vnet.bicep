param vnetName string
param location string

param vnetaddressrange string
param subnet1name string
param subnet1range string
param subnet2name string
param subnet2range string
param subnet3name string
param subnet3range string

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' =  {
  name: vnetName
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetaddressrange       
      ]
    }
    subnets:[
      {
      name: subnet1name
      properties:{
        addressPrefix: subnet1range
        networkSecurityGroup: {id: servernsg.id}
        }
      }
      {
        name: subnet2name
        properties:{
          addressPrefix: subnet2range
        }
      }
      {
        name: subnet3name
        properties:{
          addressPrefix: subnet3range
        }
      }
    ]
  }
}

resource servernsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${location}-servernsg'
  location: location
  properties: {
    securityRules: [
      {
      name: 'AllowHTTPInbound'
      properties: {
        access: 'Allow'
        description: 'Allow HTTP inbound traffic'
        destinationAddressPrefix: '*'
        destinationPortRange: '80'
        direction: 'Inbound'
        priority: 100
        protocol: 'Tcp'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        }
      }
    ]
  }
}

output vnetid string = vnet.id
output subnet1id string = vnet.properties.subnets[0].id
output subnet2id string = vnet.properties.subnets[1].id
output subnet3id string = vnet.properties.subnets[2].id
