param location1 string = 'swedencentral'
param location2 string = 'norwayeast'
param rgname string = 'afdlab-rg2'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgname
  location: location1
}

module vnet1 './vnet.bicep' = {
  scope: rg
  name: 'vnet1'
  params: {
    vnetName: 'vnet1'
    location: location1
    vnetaddressrange: '10.0.1.0/24'
    subnet1name: 'subnet1'
    subnet1range: '10.0.1.0/26'
    subnet2name: 'subnet2'
    subnet2range: '10.0.1.64/26'
    subnet3name: 'AzureBastionSubnet'
    subnet3range: '10.0.1.128/26'
  }
}
module vnet2 './vnet.bicep' = {
  scope: rg
  name: 'vnet2'
  params: {
    vnetName: 'vnet2'
    location: location2
    vnetaddressrange: '10.0.2.0/24'
    subnet1name: 'subnet1'
    subnet1range: '10.0.2.0/26'
    subnet2name: 'subnet2'
    subnet2range: '10.0.2.64/26'
    subnet3name: 'AzureBastionSubnet'
    subnet3range: '10.0.2.128/26'
  }
}

module web1 './vm.bicep' = {
  scope: rg
  name: 'web1'
  params: {
    name: 'web1'
    location: location1
    vnetid: vnet1.outputs.vnetid
    subnet1id: vnet1.outputs.subnet1id
    subnet2id: vnet1.outputs.subnet2id
  }
}

module web2 './vm.bicep' = {
  scope: rg
  name: 'web2'
  params: {
    name: 'web2'
    location: location2
    vnetid: vnet2.outputs.vnetid
    subnet1id: vnet2.outputs.subnet1id
    subnet2id: vnet2.outputs.subnet2id
  }
}
