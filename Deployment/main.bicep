@description('Server password')
@secure()
param adminPassword string

@description('Public IP address')
@secure()
param publicIpAddress string

@description('Location for all resources.')
param location string = resourceGroup().location

param tags object = {
  'op-production': 'optic'
}

module windowsServer 'sqlServerVm.bicep' = {
  name: 'windows-server-deploy'
  params: {
    location: location
    adminPassword: adminPassword
    adminUsername: 'oppopticadmin'
    tags: tags
    publicIpAddress: publicIpAddress
    autoShutdownNotificationEmail: 'niklas.lennerdahl@omegapoint.se'
  }
}

@description('Azure built-in roles')
module roleDefinitions 'roleDefinitions.bicep' = {
  name: 'role-definitions'
}
