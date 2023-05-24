param location string
param env string
param applicationName string
param uniqueApplicationId string
param tags object
param runOnLinux bool
param artifactName string
param keyVaultName string
param azurePrincipalId string
param roleDefinitions object

@secure()
@description('''
Using APPLICATIONINSIGHTS_CONNECTION_STRING is recommended. See https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#appinsights_instrumentationkey
It also allows us to take advantage of new capabilities. See https://learn.microsoft.com/en-us/azure/azure-monitor/app/migrate-from-instrumentation-keys-to-connection-strings#new-capabilities
''')
param applicationInsightsConnectionString string

@description('''
Storage account name restrictions:
- Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
- Your storage account name must be unique within Azure. No two storage accounts can have the same name.
''')
@minLength(3)
@maxLength(24)
#disable-next-line BCP335
param functionAppStorageName string = 'safn${applicationName}${uniqueApplicationId}${env}'

var functionAppName = 'fnapp-${applicationName}-${uniqueApplicationId}-${env}'
var hostingPlanName = 'asp-${applicationName}-${uniqueApplicationId}-${env}'
var deploymentPackageContainerName = 'deployment-package'

// ###################- Hosting plan -###################

@description('Hosting plan for the function app.')
resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  tags: tags
  kind: runOnLinux ? 'linux' : 'functionapp'
  properties: {
    reserved: runOnLinux ? true : false
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 1
  }
}

// ###################- Function App -###################

@description('Azure Function App')
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: runOnLinux ? 'functionapp,linux' : 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: runOnLinux ? true : false
    httpsOnly: true
    serverFarmId: hostingPlan.id
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: runOnLinux ? 'DOTNET-ISOLATED|6.0' : null // required only for linux
    }
  }
  dependsOn: [
    storageAccount
  ]
}

@description('App settings for the function app')
resource appsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
    AzureWebJobsStorage__blobServiceUri: 'https://${storageAccount.name}.blob.${environment().suffixes.storage}'
    AzureWebJobsStorage__queueServiceUri: 'https://${storageAccount.name}.queue.${environment().suffixes.storage}'
    AzureWebJobsStorage__tableServiceUri: 'https://${storageAccount.name}.table.${environment().suffixes.storage}'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${existingKeyVault.name};SecretName=${applicationInsightsConnectionStringSecret.name})'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${existingKeyVault.name};SecretName=${storageConnectionStringSecret.name})'
    WEBSITE_CONTENTSHARE: toLower(functionApp.name)
    WEBSITE_RUN_FROM_PACKAGE: runOnLinux ? 'https://${storageAccount.name}.blob.${environment().suffixes.storage}/${deploymentPackageContainerName}/${artifactName}' : '1'
  }
  dependsOn: [
    funcAppRoleAssignmentToKeyVault
    funcAppRoleAssignmentToStorageAccount
  ]
}

// ###################- Storage Account -###################

@description('The storage account for the function app')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: functionAppStorageName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        table: {
          enabled: true
        }
      }
    }
  }
  resource blobServices 'blobServices' = {
    name: 'default'
  }
}

@description('Blob container for zipped function app')
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: storageAccount::blobServices
  name: deploymentPackageContainerName
  properties: {
    publicAccess: 'None'
  }
}

// ###################- Key Vault Secrets -###################

resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyVaultName
}

@description('Key vault secret for storage connection string')
resource storageConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  parent: existingKeyVault
  name: '${applicationName}-StorageConnectionString'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
}

@description('Key vault secret for app-setting WEBSITE_CONTENTAZUREFILECONNECTIONSTRING')
resource applicationInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  parent: existingKeyVault
  name: 'ApplicationInsightsConnectionString'
  properties: {
    value: applicationInsightsConnectionString
  }
}

// ###################- Role Assignments -###################

@description('Perform any action on the secrets of a key vault, except manage permissions. Only works for key vaults that use the Azure role-based access control permission model.')
var keyVaultSecretsUserRole = roleDefinitions['Key Vault Secrets User']

@description('Assign keyvault user permissions to the Azure Function app system-assigned managed identity')
resource funcAppRoleAssignmentToKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingKeyVault.id, functionApp.name, keyVaultSecretsUserRole)
  scope: existingKeyVault
  properties: {
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: keyVaultSecretsUserRole
  }
}

var storageAccountRoleDefinitions = [
  roleDefinitions['Storage Blob Data Owner']
  roleDefinitions['Storage Queue Data Contributor']
  roleDefinitions['Storage Account Contributor']
]

@description('Storage Blob Data Owner, Storage Queue Data Contributor, and Storage Account Contributor roles for function app to storage account')
resource funcAppRoleAssignmentToStorageAccount 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in storageAccountRoleDefinitions: {
  name: guid(storageAccount.id, functionApp.name, roleDefinition)
  scope: storageAccount
  properties: {
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinition
  }
}]

@description('Allows the user to upload, modify, and delete blobs in the storage account.')
var storageBlobDataContributor = roleDefinitions['Storage Blob Data Contributor']

@description('Storage Blob Data Contributor role for pipeline to storage account')
resource pipelineAssignmentToStorageAccount 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, azurePrincipalId, storageBlobDataContributor)
  scope: storageAccount
  properties: {
    principalId: azurePrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributor
  }
}

// ###################- Output Variables -###################

output functionAppName string = functionApp.name
output deploymentPackageContainerName string = blobContainer.name
output functionAppStorageName string = storageAccount.name
