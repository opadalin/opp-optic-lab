$userPrincipalName = az account show --query user.name -o tsv
$subscriptionId = az account show --query id -o tsv
Write-Host "subscriptionId: $subscriptionId"
$role = Read-Host -Prompt "Type which role definition name you want to assign. e.g 'Owner', 'Contributor'"
$scope = Read-Host -Prompt "Type on which scope you want to assign the role"
az role assignment create --role $role --assignee $userPrincipalName --scope $scope