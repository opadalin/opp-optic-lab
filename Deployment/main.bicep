@description('Server password')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location


@description('A unique string for the application or workload name')
param uniqueApplicationId string = substring(uniqueString(resourceGroup().id), 0, 5)

param tags object = {
  'op-production': 'optic'
}

module windowsServer 'windowServer.bicep' = {
  name: 'windows-server-deploy'
  params: {
    location: location
    adminPassword: adminPassword
    adminUsername: 'sa'
    uniqueApplicationId: uniqueApplicationId
    tags: tags
  }
}

@description('Azure built-in roles')
module roleDefinitions 'roleDefinitions.bicep' = {
  name: 'role-definitions'
}
