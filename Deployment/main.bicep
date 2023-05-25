@description('Server password')
@secure()
param adminPassword string

@description('Public IP address')
@secure()
param publicIpAddress string

@description('Email address for shutdown notification')
@secure()
param emailAddress string

@description('Location for all resources.')
param location string = resourceGroup().location

param tags object = {
  'op-production': 'optic'
}

module windowsServer 'sqlServerVm.bicep' = {
  name: 'sql-server-vm-deploy'
  params: {
    location: location
    adminPassword: adminPassword
    adminUsername: 'oppopticadmin'
    tags: tags
    publicIpAddress: publicIpAddress
    autoShutdownNotificationEmail: emailAddress
  }
}
