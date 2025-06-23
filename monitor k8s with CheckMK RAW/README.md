# Monitoring Kubernetes Clusters with CheckMK Raw

Simple step by step guide to monitor Kubernetes Clusters using CheckMK RAW. All steps are done using WSL (Debian 12)

## Pre-Instalation

### Get helm
```
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version
helm repo add checkmk-chart https://checkmk.github.io/checkmk_kube_agent
helm repo update
```

### Get values.yaml 
```
curl -O https://raw.githubusercontent.com/Checkmk/checkmk_kube_agent/main/deploy/charts/checkmk/values.yaml
nano values.yaml
	service:
    # if required specify "NodePort" here to expose the cluster-collector via the "nodePort" specified below
    type: NodePort
    port: 8080
    nodePort: 30035
    annotations: {}
```

### Export Kubernetes Cluster you want to work with
```
unset KUBECONFIG
export KUBECONFIG=~/route to your folder/<cluster_name>.yaml
```


#### To review
```
kubectl get nodes
kubectl get pods -A
kubectl get namespace
```

### Deploy the Checkmk Kubernetes agent using Helm
`helm upgrade --install   checkmk   checkmk-chart/checkmk   -n checkmk-monitoring   --create-namespace   -f values.yaml`

### Export nodes, token and cert
#### these are example nodes, token and cert. You´ll need to copy & paste the actual ones from the terminal
```
export NODE_PORT=$(kubectl get --namespace checkmk-monitoring -o jsonpath="{.spec.ports[0].nodePort}" services checkmk-cluster-collector)
export NODE_IP=$(kubectl get nodes --namespace checkmk-monitoring -o jsonpath="{.items[0].status.addresses[0].address}")
export TOKEN=$(kubectl get secret checkmk-checkmk -n checkmk-monitoring -o=jsonpath='{.data.token}' | base64 --decode)
export CA_CRT="$(kubectl get secret checkmk-checkmk -n checkmk-monitoring -o=jsonpath='{.data.ca\.crt}' | base64 --decode)"
```

### Cluster IP 
`kubectl cluster-info`

### Port forwarding to 8080 and external IP
```
kubectl edit svc checkmk-cluster-collector -n checkmk-monitoring
	type: LoadBalancer
```
#### to see the external IP assigned
`kubectl get svc checkmk-cluster-collector -n checkmk-monitoring -w`

## CheckMK GUI 
Create a new host in Kubernetes folder (or clone a previous one)

### Password
Create new password: <cluster_name> Kubernetes Internal Token
Assign password generated in `echo $TOKEN`

### Trusted certificate authorities for SSL
Ass new certificate generate in `echo "$CA_CRT"`

### Kubernetes
Clone an existing one, change the following values:
    
    Cluster name
    Token
    API server connection
    Use data from Checkmk Cluster Collector (Cluster external IP)
