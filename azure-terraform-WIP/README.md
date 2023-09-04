
## create ssl cert and save in the Vault

```
az keyvault certificate import --vault-name cafanwii-key-vault --name kays/cafanwii-certificate --file cafanwii_certificate.pem
```
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




Marcelcol Notes

## Azure CLI

```
# Run Azure CLI
docker run -it --rm -v ${PWD}:/work -w /work --entrypoint /bin/sh mcr.microsoft.com/azure-cli:2.6.0

cd ./kubernetes/cloud/azure

```

## Login to Azure

```
#login and follow prompts
az login 

# view and select your subscription account

az account list -o table
SUBSCRIPTION=<id>
az account set --subscription $SUBSCRIPTION

```

## Create our Resource Group

```
RESOURCEGROUP=aks-getting-started
az group create -n $RESOURCEGROUP -l australiaeast

```
## Create Service Principal

Kubernetes needs a service account to manage our Kubernetes cluster </br>
Lets create one! </br>

```

SERVICE_PRINCIPAL_JSON=$(az ad sp create-for-rbac --skip-assignment --name aks-getting-started-sp -o json)

#Keep the `appId` and `password` for later use!

SERVICE_PRINCIPAL=$(echo $SERVICE_PRINCIPAL_JSON | jq -r '.appId')
SERVICE_PRINCIPAL_SECRET=$(echo $SERVICE_PRINCIPAL_JSON | jq -r '.password')

#grant contributor role over the resource group to our service principal

az role assignment create --assignee $SERVICE_PRINCIPAL \
--scope "/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCEGROUP" \
--role Contributor

```
For extra reference you can also take a look at the Microsoft Docs: [here](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/kubernetes-service-principal.md) </br>

## Create our cluster

```
#full list of options

az aks create --help
az aks get-versions --location australiaeast -o table

#generate SSH key

ssh-keygen -t rsa -b 4096 -N "VeryStrongSecret123!" -C "your_email@example.com" -q -f  ~/.ssh/id_rsa
cp ~/.ssh/id_rsa* .

az aks create -n aks-getting-started \
--resource-group $RESOURCEGROUP \
--location australiaeast \
--kubernetes-version 1.16.10 \
--load-balancer-sku standard \
--nodepool-name default \
--node-count 1 \
--node-vm-size Standard_E4s_v3  \
--node-osdisk-size 250 \
--ssh-key-value ./id_rsa.pub \
--network-plugin kubenet \
--service-principal $SERVICE_PRINCIPAL \
--client-secret "$SERVICE_PRINCIPAL_SECRET" \
--output none

# if your SP key is invalid, generate a new one:
SERVICE_PRINCIPAL_SECRET=(az ad sp credential reset --name $SERVICE_PRINCIPAL | jq -r '.password')
```

## Get a kubeconfig for our cluster

```
# use --admin for admin credentials
# use without `--admin` to get no priviledged user.

az aks get-credentials -n aks-getting-started \
--resource-group $RESOURCEGROUP

#grab the config if you want it
cp ~/.kube/config .

```

## Get kubectl

You have two options for installing `kubectl` <br/>

Option 1: Install using `az` CLI

```
az aks install-cli
```

Option 2: Download the binary using `curl` and place in usr bin

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

```

# Create example apps

```
cd ../..

kubectl create ns example-app

# lets create some resources.
kubectl apply -n example-app -f secrets/secret.yaml
kubectl apply -n example-app -f configmaps/configmap.yaml
kubectl apply -n example-app -f deployments/deployment.yaml

# remember to change the `type: LoadBalancer`
kubectl apply -n example-app -f services/service.yaml

```

## Clean up 

```
az group delete -n $RESOURCEGROUP
az ad sp delete --id $SERVICE_PRINCIPAL
```
