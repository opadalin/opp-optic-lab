param location string
param env string
param tags object
param applicationName string
param uniqueApplicationId string

@description('''
Name of the Application Insights instance. 
Valid characters: string (required). Can't use: %&\?/ or control characters. Can't end with space or period.
''')
@minLength(1)
@maxLength(260)
#disable-next-line BCP335
param applicationInsightsName string = 'appi-${applicationName}-${uniqueApplicationId}-${env}'
var workspaceName = 'log-${applicationName}-${uniqueApplicationId}-${env}'

@description('Log Analytics workspace')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

@description('Application Insights')
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWorkspace.id
    Request_Source: 'rest'
  }
}

output connectionString string = applicationInsights.properties.ConnectionString
