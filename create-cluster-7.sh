### create cluster

aksname="cluster7win"
rg="challenge7"
PASSWORD_WIN="P@ssw0rd1234"

az extension add --name aks-preview
az extension update --name aks-preview
az feature register --name WindowsPreview --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerService


az group create --name $rg --location AustraliaEast

az aks create \
    --resource-group $rg \
    --name $aksname \
    --node-count 2 \
    --enable-addons monitoring \
    --kubernetes-version 1.15.7 \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username azureuser \
    --vm-set-type VirtualMachineScaleSets \
    --load-balancer-sku standard \
    --network-plugin azure

az aks get-credentials --resource-group challenge7 --name cluster7 --overwrite-existing

az aks nodepool add \
    --resource-group challenge7 \
    --cluster-name cluster7 \
    --name nodepool2 \
    --node-count 3 \
    --kubernetes-version 1.15.5

az aks nodepool list --resource-group challenge7 --cluster-name cluster7

az aks nodepool upgrade \
    --resource-group challenge7 \
    --cluster-name cluster7 \
    --name nodepool2 \
    --kubernetes-version 1.15.7 \
    --no-wait





