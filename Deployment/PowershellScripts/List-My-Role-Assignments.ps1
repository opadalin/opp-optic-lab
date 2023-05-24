$userPrincipalName = az account show --query user.name -o tsv
az role assignment list --all --assignee $userPrincipalName --output json --query '[].{principalName:principalName, principalId:principalId, roleDefinitionName:roleDefinitionName, scope:scope}'

Read-Host -Prompt "Press any key to exit..."
exit 0