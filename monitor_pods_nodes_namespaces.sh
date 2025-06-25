#!/bin/bash

# ============================================================================
# Script Name:    monitor_pods_nodes_namespaces.sh
# Author:         Mauro García
# Version:        1.0
# Description:    This script creates services from every namespace, pods and 
#                 nodes on a k8s cluster
# Repository:     https://gitlab.mid.de/magarpol/scripts.git
# Last Updated:   2025-06-25
# ============================================================================


export KUBECONFIG=<path_to>kubeconfig.yaml

# Check command exists
command -v kubectl >/dev/null 2>&1 || { echo "2 kube_check - CRITICAL - kubectl not found"; exit 1; }

# List Nodes
for node in $(kubectl get nodes --no-headers -o custom-columns=":metadata.name"); do
    status=$(kubectl get node "$node" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    if [[ "$status" == "True" ]]; then
        echo "0 node_$node - OK - Node $node is Ready"
    else
        echo "2 node_$node - CRITICAL - Node $node is Not Ready"
    fi
done

# List Pods
kubectl get pods --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name, .status.phase] | @tsv' | while IFS=$'\t' read -r ns name phase; do
    svcname="pod_${ns}_${name}"
    case "$phase" in
        Running)
            echo "0 $svcname - OK - Pod $name in $ns is $phase"
            ;;
        Pending|Succeeded)
            echo "1 $svcname - WARNING - Pod $name in $ns is $phase"
            ;;
        Failed|Unknown)
            echo "2 $svcname - CRITICAL - Pod $name in $ns is $phase"
            ;;
        *)
            echo "3 $svcname - UNKNOWN - Pod $name in $ns is in unknown state $phase"
            ;;
    esac
done

# List Namespaces
for ns in $(kubectl get ns --no-headers -o custom-columns=":metadata.name"); do
    echo "0 namespace_$ns - OK - Namespace $ns exists"
done

# List PVCs
kubectl get pvc --all-namespaces -o json | jq -r '
  .items[] |
  [.metadata.namespace, .metadata.name, .status.phase, .spec.resources.requests.storage] |
  @tsv' | while IFS=$'\t' read -r ns pvc status requested; do

    svcname="pvc_${ns}_${pvc}"

    case "$status" in
        Bound)
            echo "0 $svcname - OK - PVC $pvc in $ns is Bound with $requested requested"
            ;;
        Pending)
            echo "1 $svcname - WARNING - PVC $pvc in $ns is Pending (requested $requested)"
            ;;
        Lost)
            echo "2 $svcname - CRITICAL - PVC $pvc in $ns is Lost"
            ;;
        *)
            echo "3 $svcname - UNKNOWN - PVC $pvc in $ns has unknown status $status"
            ;;
    esac
done
