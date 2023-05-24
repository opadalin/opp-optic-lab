
$ErrorActionPreference = "Stop"
function Remove-RoleAssignment ([string]$objectId, [string]$roleDefinitionName) {
    
    Write-Host "--------------------------------------------------------------------------------------------------------------------------"
    Write-Host "Object Id: $objectId"
    Write-Host "Role Definition Name: $roleDefinitionName"
    $roleAssignment = Get-AzRoleAssignment | Where-object -Property ObjectId -eq $objectId | Where-object -Property RoleDefinitionName -eq $roleDefinitionName | Select-Object -First 1 -Wait
    Write-Host "Scope: $($roleAssignment.Scope)"
    $promptResponse = Read-Host -Prompt "Are you sure you want to remove role assignment? (y/N)"
    
    if ($promptResponse.ToLower() -eq "y" -or $promptResponse.ToLower() -eq "yes") {
        Remove-AzRoleAssignment -InputObject $roleAssignment
    }
}

$orphanRoleAssignments = Get-AzRoleAssignment | Where-object -Property ObjectType -eq "Unknown"

$orphanRoleAssignments | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        if ($_.Name -eq "ObjectId") {
            $objectId = $_.Value
        }
        if ($_.Name -eq "RoleDefinitionName") {
            $roleDefinitionName = $_.Value
        }
    }

    Remove-RoleAssignment $objectId $roleDefinitionName
}
Write-Host "Done"