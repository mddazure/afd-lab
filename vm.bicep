param location string
param vnetid string
param subnet1id string
param subnet2id string


var linuximagePublisher = 'kinvolk'
var linuximageOffer = 'flatcar-container-linux-free'
var linuximageSku = 'stable-gen2'

var api_image='erjosito/yadaapi:1.0'
var web_image='erjosito/yadaweb:1.0'

var sql_server_fqdn = 'yada-db-server.database.windows.net'
var sql_username = 'marc'
var sql_password = 'Nienke040598'

var adminUsername = 'AzureAdmin'
var adminPassword = 'AFD-demo2024'


resource webpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'webpip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource web 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'web'
  location: location
  plan: {
    publisher: linuximagePublisher
    product: linuximageOffer
    name: linuximageSku
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: linuximagePublisher
        offer: linuximageOffer
        sku: linuximageSku
        
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'web'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webnic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource webnic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'webnic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet1id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: webpip.id
            }
        }
      }
    ]
  }
}
resource webruncommand 'Microsoft.Compute/virtualMachines/runCommands@2024-03-01' = {
  parent: web
  name: 'webruncommand'
  location: location
  properties: {
    source: {
      script: 'docker run --restart always -d -p 80:80 -e "API_URL=http://${apinic.properties.ipConfigurations[0].properties.privateIPAddress}:8080" --name yadaweb ${web_image}'
    }
  }
}
resource webruncommand2 'Microsoft.Compute/virtualMachines/runCommands@2024-03-01' = {
  parent: web
  name: 'web1runcommand2'
  dependsOn: [webruncommand]
  location: location
  properties: {
    source: {
      script: 'systemctl enable --now docker.service'
    }
  }
}

resource yadaapi 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'yadaapi'
  location: location
  plan: {
    publisher: linuximagePublisher
    product: linuximageOffer
    name: linuximageSku
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: linuximagePublisher
        offer: linuximageOffer
        sku: linuximageSku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'yadaapi'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: apinic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource apinic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'apinic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet2id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource apiruncommand 'Microsoft.Compute/virtualMachines/runCommands@2024-03-01' = {
  parent: yadaapi
  name: 'apiruncommand'
  location: location
  properties: {
    source: {
      script: 'docker run --restart always -d -p 8080:8080 -e "SQL_SERVER_FQDN=${sql_server_fqdn}" -e "SQL_SERVER_USERNAME=${sql_username}" -e "SQL_SERVER_PASSWORD=${sql_password}" --name api ${api_image}'
    }
  }
}
resource apiruncommand2 'Microsoft.Compute/virtualMachines/runCommands@2024-03-01' = {
  parent: yadaapi
  name: 'apiruncommand2'
  dependsOn: [apiruncommand]
  location: location
  properties: {
    source: {
      script: 'systemctl enable --now docker.service'
    }
  }
}

output webid string = web.id
output apiid string = yadaapi.id
output webpipid string = webpip.id
