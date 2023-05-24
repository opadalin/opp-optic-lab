param roleDefinitions object
param keyVaultName string
param userId string

resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyVaultName
}

@description('Read secret contents. Only works for key vaults that use the Azure role-based access control permission model.')
var keyVaultSecretsUserRole = roleDefinitions['Key Vault Secrets User']

@description('Assign keyvault user permissions to the Azure Function app system-assigned managed identity')
resource funcAppRoleAssignmentToKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingKeyVault.name, userId, keyVaultSecretsUserRole)
  scope: existingKeyVault
  properties: {
    principalId: userId
    principalType: 'User'
    roleDefinitionId: keyVaultSecretsUserRole
  }
}
