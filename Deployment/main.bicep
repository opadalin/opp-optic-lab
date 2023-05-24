@secure()
@description('Principal id of the user-assigned managed identity used for OIDC in pipeline. Is set from release pipeline')
param azurePrincipalId string

@secure()
@description('Principal id of the user who set up the above user-assigned managed identity. Is set from release pipeline')
param userId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specifies the application name')
param applicationName string = 'dc'

@description('A unique string for the application or workload name')
param uniqueApplicationId string = substring(uniqueString(resourceGroup().id), 0, 5)


param tags object = {
  'op-production': 'optic'
}

module keyVaultDeploy 'keyVault.bicep' = {
  name: 'key-vault'
  params: {
    location: location
    tags: tags
    applicationName: applicationName
    uniqueApplicationId: uniqueApplicationId
  }
}

module applicationInsightsDeploy './applicationInsights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
    tags: tags
    applicationName: applicationName
    uniqueApplicationId: uniqueApplicationId
  }
}

@description('Azure built-in roles')
module roleDefinitions 'roleDefinitions.bicep' = {
  name: 'role-definitions'
}


module applyKeyVaultRoleAssignment 'keyVaultRoleAssignments.bicep' = {
  name: 'kv-user-role-assignement'
  params: {
    userId: userId
    keyVaultName: keyVaultDeploy.outputs.name
    roleDefinitions: roleDefinitions.outputs.roleDefinitions
  }
  dependsOn:[
    keyVaultDeploy
    applicationInsightsDeploy
  ]
}
