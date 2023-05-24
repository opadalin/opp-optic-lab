@description('Current environment for the application. Is set from release pipeline')
param env string

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

@description('Name of the function app artifact')
param artifactName string

param tags object = {
  AMP23: 'delivery'
  Owner: 'lindis'
}

module keyVaultDeploy 'keyVault.bicep' = {
  name: 'key-vault'
  params: {
    env: env
    location: location
    tags: tags
    applicationName: applicationName
    uniqueApplicationId: uniqueApplicationId
  }
}

module applicationInsightsDeploy './applicationInsights.bicep' = {
  name: 'application-insights'
  params: {
    env: env
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

module linuxFunctionAppDeploy 'functionApp.bicep' = {
  name: 'linux-function-app'
  params: {
    env: env
    location: location
    tags: tags
    runOnLinux: true
    applicationName: applicationName
    uniqueApplicationId: uniqueApplicationId
    artifactName: artifactName
    applicationInsightsConnectionString: applicationInsightsDeploy.outputs.connectionString
    keyVaultName: keyVaultDeploy.outputs.name
    azurePrincipalId: azurePrincipalId
    roleDefinitions: roleDefinitions.outputs.roleDefinitions
  }
  dependsOn:[
    keyVaultDeploy
    applicationInsightsDeploy
  ]
}

// module winFunctionAppDeploy 'functionApp.bicep' = {
//   name: 'windows-function-app'
//   params: {
//     env: env
//     location: location
//     tags: tags
//     runOnLinux: false
//     applicationName: 'windows'
//     uniqueApplicationId: uniqueApplicationId
//     artifactName: artifactName
//     applicationInsightsConnectionString: applicationInsightsDeploy.outputs.connectionString
//     keyVaultName: keyVaultDeploy.outputs.name
//     azurePrincipalId: azurePrincipalId
//     roleDefinitions: roleDefinitions.outputs.roleDefinitions
//   }
//   dependsOn:[
//     keyVaultDeploy
//     applicationInsightsDeploy
//   ]
// }

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

output linuxFunctionAppName string = linuxFunctionAppDeploy.outputs.functionAppName
output accountName string = linuxFunctionAppDeploy.outputs.functionAppStorageName
output containerName string = linuxFunctionAppDeploy.outputs.deploymentPackageContainerName
