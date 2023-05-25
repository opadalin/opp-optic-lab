param tags object

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Email')
param autoShutdownNotificationEmail string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Location for all resources.')
param location string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'opp-optic-pip'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Static'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Standard'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_B1s'

@description('Name of the virtual machine.')
param vmName string = 'opp-optic-vm'

@description('Security Type of the Virtual Machine.')
param securityType string = 'TrustedLaunch'

var nicName = 'opp-optic-vm-nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'opp-optic-vm-subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = 'opp-optic-vnet'
var networkSecurityGroupName = 'opp-optic-NSG'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allow-sql-1433'
        properties: {
          priority: 1001
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '1433'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [

    virtualNetwork
  ]
}


@description('Amount of data disks (1TB each) for SQL Data files')
@minValue(1)
@maxValue(8)
param sqlDataDisksCount int = 1

@description('Amount of data disks (1TB each) for SQL Log files')
@minValue(1)
@maxValue(8)
param sqlLogDisksCount int = 1


var dataDisks = {
  createOption: 'Empty'
  caching: 'ReadOnly'
  writeAcceleratorEnabled: false
  storageAccountType: 'Premium_LRS'
  diskSizeGB: 1023
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2022-ws2022'
        sku: 'standard-gen2'
        version: 'latest'
      }
      dataDisks: [for j in range(0, (sqlDataDisksCount + sqlLogDisksCount)): {
        lun: j
        createOption: dataDisks.createOption
        caching: ((j >= sqlDataDisksCount) ? 'None' : dataDisks.caching)
        writeAcceleratorEnabled: dataDisks.writeAcceleratorEnabled
        diskSizeGB: dataDisks.diskSizeGB
        managedDisk: {
          storageAccountType: dataDisks.storageAccountType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}

resource shutdown_computevm_virtualMachine 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '19:00'
    }
    timeZoneId: 'W. Europe Standard Time'
    targetResourceId: virtualMachine.id
    notificationSettings: {
      status: 'Enabled'
      notificationLocale: 'en'
      timeInMinutes: 30
      emailRecipient: autoShutdownNotificationEmail
    }
  }
}

resource sqlVirtualMachine 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2022-07-01-preview' = {
  name: vmName
  location: location
  properties: {
    virtualMachineResourceId: virtualMachine.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: 'General'
      sqlDataSettings: {
        luns: range(0, sqlDataDisksCount)
        defaultFilePath: 'F:\\SQLData'
      }
      sqlLogSettings: {
        luns: range(sqlDataDisksCount, sqlLogDisksCount)
        defaultFilePath: 'G:\\SQLLog'
      }
      sqlTempDbSettings: {
        defaultFilePath: 'D:\\SQLTemp'
      }
    }
    autoPatchingSettings: {
      enable: true
      dayOfWeek: 'Sunday'
      maintenanceWindowStartingHour: 2
      maintenanceWindowDuration: 60
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: 'PUBLIC'
        port: 1433
        sqlAuthUpdateUserName: 'oppopticsa'
        sqlAuthUpdatePassword: adminPassword
      }
    }
  }
}


output hostname string = publicIp.properties.dnsSettings.fqdn
