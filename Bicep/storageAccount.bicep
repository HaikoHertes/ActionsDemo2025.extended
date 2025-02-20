@minLength(3)
@maxLength(11)
param parStoragePrefix string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param parStorageSKU string = 'Standard_LRS'

param parLocation string = resourceGroup().location

param parTimestamp string = utcNow()


var varUniqueStorageName = '${parStoragePrefix}${uniqueString(resourceGroup().id)}'

resource resStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: varUniqueStorageName
  location: parLocation
  sku: {
    name: parStorageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
  }
}

/*
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' = {
  name: '${storage.name}/$web'
  properties: {
    publicAccess: 'Blob'
  }
}
*/

// Define the user-assigned managed identity
resource resUami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'myUAMI'
  location: parLocation
}

// Assign the Contributor role to the managed identity
resource resRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'Contributor', resUami.id)
  scope: resStorage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Storage Blob Data Contributor role ID
    principalId: resUami.properties.principalId
  }
}

// Deployment script to enable static website
resource resEnableStaticWebsite 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'enableStaticWebsite'
  location: parLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resUami.id}': {}
    }
  }
  dependsOn: [
    resRoleAssignment
  ]
  kind: 'AzurePowerShell'

  properties: {
    azPowerShellVersion: '10.0'
    scriptContent: '''
param(
    [string] $ResourceGroupName,
    [string] $StorageAccountName,
    [string] $IndexDocument)
$ErrorActionPreference = 'Stop'
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
$ctx = $storageAccount.Context
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $IndexDocument
$DeploymentScriptOutputs = @{} 
$DeploymentScriptOutputs['url'] = $storageAccount.PrimaryEndpoints.Web
'''
    forceUpdateTag: parTimestamp
    retentionInterval: 'PT4H'
    arguments: '-ResourceGroupName ${resourceGroup().name} -StorageAccountName ${varUniqueStorageName} -IndexDocument index.html'
  }
}

// Deployment script to generate SAS token
resource resGenerateSasToken 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'generateSasToken'
  location: parLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resUami.id}': {}
    }
  }
  dependsOn: [
    resEnableStaticWebsite
  ]
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '12.5.0'
    scriptContent: '''
param(
    [string] $ResourceGroupName,
    [string] $StorageAccountName)
$ErrorActionPreference = 'Stop'
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
$ctx = $storageAccount.Context
$expiryTime = (Get-Date).AddMinutes(15)
$permissions = 'rcw' # Read, create and write
$sasToken = New-AzStorageContainerSASToken -Name "`$web" -Context $ctx -Permission $permissions -ExpiryTime $expiryTime
# Output the SAS token
$DeploymentScriptOutputs = @{
    sasToken = $sasToken
}
'''
    forceUpdateTag: parTimestamp
    retentionInterval: 'PT4H'
    arguments: '-ResourceGroupName ${resourceGroup().name} -StorageAccountName ${varUniqueStorageName}'
  }
}


output storageEndpoint object = resStorage.properties.primaryEndpoints
output storageAccountName string = resStorage.name
output storageAccountPrimaryEndpoint string = resStorage.properties.primaryEndpoints.web
//output staticWebsiteHostName string = replace(replace(resStorage.properties.primaryEndpoints.web, 'https://', ''), '/', '')
output sasToken string = resGenerateSasToken.properties.outputs.sasToken

