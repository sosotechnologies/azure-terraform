<!-- cafanwii-terraform-subsciption
02586025-9515-4eac-9a28-cd52e33fbaa4 -->

## Resource: azuread_service_principal with terraform

The following API permissions are required in order to use this resource.

- ***application roles:*** Application.ReadWrite.All or Directory.ReadWrite.All

It may be possible to manage service principals whilst having only the Application.ReadWrite.OwnedBy role granted, however you must ensure that both the underlying application and the service principal have the Terraform principal as an owner.

When authenticated with a user principal, this resource requires one of the following directory roles: Application Administrator or Global Administrator

On a general note, You'll need at least one of the following roles in Azure Active Directory to successfully list service principal information:

- Application administrator
- Global administrator
- Security administrator
- Privileged role administrator

NOTE: The roles (Application administrator, Global administrator, Security administrator, and Privileged role administrator) are Azure Active Directory roles that grant administrative permissions across the Azure AD tenant or Azure subscription. These roles are typically assigned manually through the Azure portal or using PowerShell/Azure CLI commands.



when you have those roles, then you can run command like:

```
az ad sp list --query "[].appId" --output tsv
```

***OR*** this shell script

```sh
app_ids=$(az ad sp list --query "[].appId" --output tsv)

for app_id in $app_ids; do
  az ad app credential reset --id "$app_id"
done
```

LETS GET STARTED:

0. login to azure, get the subscription and tenant ID and store them as variables:

```
az login 
az account list -o table
```

1. Create an AD Subscription[optional]:
  -  cafanwii-terraform-subsciption: 02586025-9515-4eac-9a28-cd52e33fbaa4 

2. Create a service principle with terraform: see files. It will create 4 resources:
   - azuread_application
   - azuread_service_principal
   - azurerm_resource_group
   - resource "azurerm_user_assigned_identity

```
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

So the service principle ID is outputted:
I also need the passwork, so Im gonna run this command to output the password. 


This is not best practice. In the future I will Create a secret in Azure Key Vault  using Terraform. This will enable us to retrieve the secret using an Azure SDK, Azure CLI, or REST API from the application when needed.

3. Grant contributor role over the subscription to our service principal:
To achieve this, use the [azurerm_role_assignment] resource in Terraform. See the Terraform configuration to grant the "Contributor" role to the newly created service principal:


***NOTE:*** Navigate to 