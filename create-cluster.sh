### create cluster

aksname="cluster5"
rg="team5"

# Create the Azure AD application
serverApplicationId=$(az ad app create \
    --display-name "${aksname}Server" \
    --identifier-uris "https://${aksname}Server" \
    --query appId -o tsv)

# Update the application group memebership claims
az ad app update --id $serverApplicationId --set groupMembershipClaims=All

# Create a service principal for the Azure AD application
az ad sp create --id $serverApplicationId

# Get the service principal secret
serverApplicationSecret=$(az ad sp credential reset \
    --name $serverApplicationId \
    --credential-description "AKSPassword" \
    --query password -o tsv)

    # Create a service principal for the Azure AD application
az ad sp create --id $serverApplicationId

# Get the service principal secret
serverApplicationSecret=$(az ad sp credential reset \
    --name $serverApplicationId \
    --credential-description "AKSPassword" \
    --query password -o tsv)


    az ad app permission add \
    --id $serverApplicationId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

    az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id  $serverApplicationId

clientApplicationId=$(az ad app create \
    --display-name "${aksname}Client" \
    --native-app \
    --reply-urls "https://${aksname}Client" \
    --query appId -o tsv)

    az ad sp create --id $clientApplicationId

    oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

    az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions ${oAuthPermissionId}=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId

az group create --name $rg --location EastUS

tenantId=$(az account show --query tenantId -o tsv)

az aks create \
    --resource-group $rg \
    --name $aksname \
    --node-count 1 \
    --generate-ssh-keys \
    --aad-server-app-id $serverApplicationId \
    --aad-server-app-secret $serverApplicationSecret \
    --aad-client-app-id $clientApplicationId \
    --aad-tenant-id $tenantId

    az aks get-credentials --resource-group $rg --name $aksname --admin


## Create an Azure Key Vault
az keyvault create --resource-group team5 --name team5kv 

## Store the password as a secret
az keyvault secret set --vault-name team5kv --name sql-password --value "vH8ig6Em6"

## Create Service Principal to access Azure Key Vault
az ad sp create-for-rbac --skip-assignment

## Ensure the Service Principal has all the required permissions to access secrets in your Key Vault instance
KEYVAULT_ID=$(az keyvault show --name team5kv --query id --output tsv)
az role assignment create --role Reader --assignee "http://azure-cli-2020-02-26-11-03-47" --scope $KEYVAULT_ID

## Configure Azure Key Vault to allow access to secrets using the Service Principal you created
az keyvault set-policy -n team5kv --secret-permissions get --spn 6f578462-7d5b-49e8-9b31-6b00eae97a35

## Create a Kubernetes secret to store the Service Principal created earlier
kubectl create secret generic kvcreds --from-literal clientid=6f578462-7d5b-49e8-9b31-6b00eae97a35 --from-literal clientsecret=d9722129-3a2d-4c72-bb4b-eb1eb632f3ed --type=azure/kv

## Deploy Key Vault FlexVolume for Kubernetes into your AKS cluster
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

## Retrieve the Azure subscription/tenant ID where the Azure Key Vault is deployed
az account show --query id --output tsv  ## 2797869a-f18f-4acc-95ac-3e2c15960d62
az account show --query tenantId --output tsv ## e0e3ea7e-63e7-4367-94f5-d77adf8abbb0

