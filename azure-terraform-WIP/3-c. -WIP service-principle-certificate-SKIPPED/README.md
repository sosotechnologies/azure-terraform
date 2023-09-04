<!-- cafanwii-terraform-subsciption
2758777e-d279-4b89-b058-dfbf61c1e250 -->

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
  -  cafanwii-terraform-subsciption: 2758777e-d279-4b89-b058-dfbf61c1e250 

2. Create a service principle with terraform: see files. It will create 4 resources:
   - azuread_application
   - azuread_service_principal
   - azurerm_resource_group
   - azurerm_user_assigned_identity

```
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

terraform destroy -var-file="terraform.tfvars"
```

So the service principle ID is outputted:
I also need the passwork, so Im gonna run this command to output the password. 


This is not best practice. In the future I will Create a secret in Azure Key Vault  using Terraform. This will enable us to retrieve the secret using an Azure SDK, Azure CLI, or REST API from the application when needed.

3. Grant contributor role over the subscription to our service principal:
To achieve this, use the [azurerm_role_assignment] resource in Terraform. See the Terraform configuration to grant the "Contributor" role to the newly created service principal:

4. Add secret resource for service principle and output
- Focus on the apply run process of terrafrm, you will see those credentials.
- Copy and save as it will be used soon
- save the client key in terraform.tfvars and update the variable.

#############################################################################################
For section 3.b. The use care is to create certificates too for the service principle
***Note***: It's not mandatory to use secret_client and certificate. The most secure is CA certs

5. create kubernetes resource: This use case is after the cluster has been created.

If you want to use certificate-based authentication for an Azure Kubernetes Service (AKS) cluster, you will need to set up and configure Kubernetes yourself after creating the cluster. Azure Kubernetes Service supports service principal authentication through client certificates, but it's a separate step beyond the Terraform resource.

Here's a general outline of the steps you'd need to follow:

Create the AKS cluster using the azurerm_kubernetes_cluster resource without specifying service_principal.

After the AKS cluster is created, manually configure Kubernetes to use the certificate-based authentication by updating the Kubernetes configuration (kubeconfig) on your local machine.

Set up the Kubernetes client certificates to allow your Kubernetes tools (like kubectl) to authenticate using the client certificate and private key.

Here's a simplified example of how you might update your local Kubernetes configuration for client certificate-based authentication:

I will not be using the client secret for authenticating. I will be using a certificate-based authentication for secure access. I will:

Generate a certificate:
You need to generate a self-signed certificate or obtain a valid certificate from a Certificate Authority.

Upload the certificate to Azure AD application:
Go to the Azure Portal.

- Navigate to the "Azure Active Directory" service.
- Select "App registrations".
- Find and select your application from the list.
- Under "Certificates & secrets," you can add a new certificate. Upload the certificate (.pem or .cer) and save.
- Update your Terraform configuration:

Upload the certificate to Azure AD application:


### Generate a self-signed certificate [Dev Environment ONLY]. For Prod use CA Certs.
1. Install OpenSSL:

```
sudo apt-get install openssl
```

2. Generate a Private Key:

```
openssl genpkey -algorithm RSA -out cafanwii_private_key.pem
```

3. Generate a Self-Signed Certificate:
This command is a prompt you to enter information for the certificate, such as the Common Name (CN), Organization (O), and other details. You can provide your own values or leave them blank for a self-signed certificate.

```
openssl req -new -x509 -key cafanwii_private_key.pem -out cafanwii_certificate.pem -days 365
```

4. Verify the Certificate and Private Key:


```
openssl x509 -in cafanwii_certificate.pem -text -noout
openssl pkey -in cafanwii_private_key.pem -text -noout
```

then configure tha kubeconfig yaml

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <CA_CERT_DATA>
    server: <AKS_API_SERVER>
  name: my-aks-cluster
contexts:
- context:
    cluster: my-aks-cluster
    user: my-aks-user
  name: my-aks-context
current-context: my-aks-context
kind: Config
preferences: {}
users:
- name: my-aks-user
  user:
    client-certificate: /path/to/client_certificate.pem
    client-key: /path/to/client_private_key.pem
```


az aks get-credentials --resource-group my-resource-group --name my-aks-cluster
