param applicationName string
param uniqueApplicationId string
param location string
param tags object

@description('''
Key vault name restrictions:
- Key vault names must be between 3 and 24 characters in length and must contain alphanumerics and hyphens only (cannot contain consecutive hyphens).
- The name must start with a letter and end with a letter or digit. 
- Your key vault name must be unique within Azure. No two key vaults can have the same name.
''')
@minLength(3)
@maxLength(24)
#disable-next-line BCP335
param keyVaultName string = 'kv-${applicationName}-${uniqueApplicationId}'

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Specifies the SKU to use for the key vault.')
param keyVaultSku object = {
  name: skuName
  family: 'A'
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForDiskEncryption: true
    sku: keyVaultSku
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output name string = keyVault.name
