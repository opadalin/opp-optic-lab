// More built in roles can be found at https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
param roleDefinitions object = {
  // General
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'User Access Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')

  // Storage
  'Storage Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')
  'Storage Blob Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  'Storage Blob Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  'Storage Blob Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  'Storage Blob Delegator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'db58b8e5-c6ad-4a2a-8342-4190687cbf4a')
  'Storage Queue Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
  'Storage Queue Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '19e7f393-937e-4f77-808e-94535e297925')
  'Storage Queue Data Message Processor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8a0f0c08-91a1-4084-bc3d-661d67233fed')
  'Storage Queue Data Message Sender': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a')
  'Storage Table Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
  'Storage Table Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '76199698-9eea-4c19-bc75-cec21354c6b6')

  // Security
  'Key Vault Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
  'Key Vault Certificates Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
  'Key Vault Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395')
  'Key Vault Crypto Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
  'Key Vault Crypto Service Encryption User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6')
  'Key Vault Crypto User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
  'Key Vault Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
  'Key Vault Secrets Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  'Key Vault Secrets User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
  
  // Databases
  'Cosmos DB Account Reader Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8')
  'Cosmos DB Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '230815da-be43-4aae-9cb4-875f7bd000aa')
  'Cosmos Backup Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'db7b14f2-5adf-42da-9f96-f2ee17bab5cb')
  'Cosmos Restore Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5432c526-bc82-444a-b7ba-57c5b0b5b34f')
}

output roleDefinitions object = roleDefinitions
