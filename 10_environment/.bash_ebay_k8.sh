#!/bin/sh

# kc
# Since we rely on namespaces for environment, all kubectl commands must specify --namespace $env.
# To alleviate this extra verbosity, use an alias and a default KUBE_NAMESPACE

echo "      | .bash_ebay_k8.sh [tk*|k8*]"


# ------------------------------------------------------------------------
# Kubernetes Tess
#   Also refer to mlTools.git/10_environment/.bash_ebay_k8.sh
# ------------------------------------------------------------------------
export PATH=$PATH:/Users/thchang/tess
alias tk="tess kubectl"
alias tkCmdLogin="tess login"
alias tkCmdDockerLogin="sudo docker login hub.tess.io" #Passowrd: C3 -> Pin+Yubi
alias tkCmdSwitchCluster="tess kubectl config use-context"

# tkPodName [NS]
tkPodName() { # first pod
  tk get pods -n $1 -o jsonpath='{.items[0].metadata.name}'
}

tkPodNameAll() { # first pod
  tk -n $1 get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
}

# tkPodSh [NS]
tkPodSh() {
  tk -n $1 exec -it `tkPodName $1` bash
}

# tkPodIp [NS]
# tkPodIp nlp-lnp-ns
tkPodIp() {
  tk -n $1 get pods  -o json | jq -r '.items[] | .metadata.name + ": " + .status.podIP'
}

# tkPodImageSingle [NS]
# tkPodImageSingle uomdev01
tkPodImageSingle() {
  tk -n $1 get pod `tkPodName $1` --output json | jq '.status.containerStatuses[] | { "name": .name, "image": .image, "imageID": .imageID }'
}

tkPodImagesAll() {
  # If there are more than one pods, k8s adds the items key !!!.
  tk -n $1 get pod `tkPodNameAll $1` --output json | jq -r '.items[].status.containerStatuses[] | { "name": .name, "image": .image, "imageID": .imageID }'
}

tkPodImages() {
  # If first command fails, then run the 2nd command
  tkPodImagesAll $1 || tkPodImageSingle $1
}

tkPodInfos() {
  echo " ---------------------------------------"
  echo " IMAGES"
  echo " ---------------------------------------"
  tkPodImages $1

  echo ""
  echo " ---------------------------------------"
  echo " IP"
  echo " ---------------------------------------"
  tkPodIp $1
}

function kc() {
	export KUBE_NAMESPACE="dev"
	kubectl --namespace $KUBE_NAMESPACE "$@"
}

function kLogPodsSearchRecSvc() {
  #n2nonprod n2prod
  #knsearchdev knsearchprod
  pod=$(kc get pods -l app=search-rec-svc | grep search-rec-svc | head -1 | cut -d ' ' -f 1)
  echo $pod
  kc logs $pod $1 -c search-rec-svc
}

tessNPD() {
  source ~/.ssh/NPD-openrc.sh
  CLUSTER_NAME=tess33
  NAMESPACE=npd
  CLUSTER_ENDPOINT=https://api.system.svc.33.tess.io
  export KUBE_NAMESPACE=npd
  export TOKEN=`openstack token issue | grep "| id" | awk '{print $4}'`
  kubectl config set-cluster ${CLUSTER_NAME} --server=${CLUSTER_ENDPOINT} --insecure-skip-tls-verify=true
  kubectl config set-credentials ${OS_USERNAME} --token=${TOKEN}
  kubectl config set-context ${CLUSTER_NAME} --cluster=${CLUSTER_NAME} --user=${OS_USERNAME} --namespace=${NAMESPACE}
  kubectl config use-context ${CLUSTER_NAME}
}

alias kcNodeports="kc get svc -o json | jq -r '.items[] | .np = .spec.ports[0].nodePort | select(.np != null) |  .metadata.name + \": \" + (.np | tostring)'"


# ------------------------------------------------------------------------
# NPD
#   Also refer to mlTools.git/10_environment/.bash_ebay_k8.sh
# ------------------------------------------------------------------------
export KUBE_NAMESPACE=kube-system
function kc() {
  kubectl --namespace $KUBE_NAMESPACE "$@"
}


# Set env
alias k8nkube="export KUBE_NAMESPACE=kube-system"

# Pod state utils

k8ips() {
  kc get pods -l app="$@" -o json | jq -r '.items[] | .metadata.name + ": " + .status.podIP'
}

k8Pods() {
  app=$1
  shift
  kc get pods -l app="$app" $@
}

k8pod() { # first pod
  kc get pods -l app="$@" -o jsonpath='{.items[0].metadata.name}'
}

k8sh() {
  kc exec -it `fpod $1` sh
}

# Switch namespace
k8n() {
 if [ -z "$1" ]
 then
   echo $KUBE_NAMESPACE
 else
   export KUBE_NAMESPACE=$1
 fi
}


# Convenience function to port-forward a pod to a specified port by module name.
#
# Usage: k8spf <svc name> <local port>
function k8spf() {
  po_name=`kubectl --namespace=$KUBE_NAMESPACE get po -l app=$1 -o jsonpath={.items[0].metadata.name}`
  po_port=`kubectl --namespace=$KUBE_NAMESPACE get po -l app=$1 -o jsonpath={.items[0].spec.containers[0].ports[0].containerPort}`
  kubectl --namespace=$KUBE_NAMESPACE port-forward $po_name $2:$po_port
}


# Images in namespaces
# Example of quickly getting the docker image for a deployment in multiple namespaces. Also illustrates further usage of jsonpath. Update to namespaces you care about:

k8images() {
  echo -n "Prod: "
  kubectl get deployment -nprod $1 -o jsonpath='{.spec.template.spec.containers[0].image}'
  echo
  echo -n "Dev: "
  kubectl get deployment -ndev $1 -o jsonpath='{.spec.template.spec.containers[0].image}'
  echo
  echo -n "Test: "
  kubectl get deployment -ntest $1 -o jsonpath='{.spec.template.spec.containers[0].image}'
  echo
}

# Project switching
#alias shared='gproj npd-shared'
#alias sharedprod='gproj npd-shared-prod && gzone us-central1-a && gcluster us-central1-std-m'
#alias sharedprod2='gproj npd-shared-prod && gzone us-central1-a && gcluster us-central1-standard-m'
#alias sharednonprod='gproj npd-shared-nonprod && gzone us-central1-a && gcluster us-central1-std-m'
#alias sharednonprod2='gproj npd-shared-nonprod && gzone us-central1-a && gcluster us-central1-standard-m'
#alias catalognonprod='gproj npd-shared-nonprod && gzone us-central1-a && gcluster us-central1-std-m-catalog'
#alias catalognonprodb='gproj npd-shared-nonprod && gzone us-central1-b && gcluster us-central1-b-std-m-catalog'
#alias catalogprod='gproj npd-shared-prod && gzone us-central1-a && gcluster us-central1-std-m-catalog'
#alias catalogprodb='gproj npd-shared-prod && gzone us-central1-b && gcluster us-central1-b-std-m-catalog'
#alias restricted='gproj npd-restricted'
#alias restrictedprod='gproj npd-restricted-prod && gzone us-central1-a && gcluster us-central1-std-m'
#alias restrictednonprod='gproj npd-restricted-nonprod && gzone us-central1-a && gcluster us-central1-std-m'
#alias n1prod='gproj ebay-n1-prod && gzone us-central1-a && gcluster us-central1-std-m'
#alias n1nonprod='gproj ebay-n1-nonprod && gzone us-central1-a && gcluster us-central1-std-m'
#alias n2prod='gproj ebay-n2-prod && gzone asia-northeast1-a && gcluster asia-northeast1-std-m2'
#alias n2nonprod='gproj ebay-n2-nonprod && gzone asia-northeast1-a && gcluster asia-northeast1-std-m2'
#alias catalognonprod='gproj npd-shared-nonprod && gzone us-central1-a && gcluster us-central1-std-m-catalog'
#alias catalogprod='gproj npd-shared-prod && gzone us-central1-a && gcluster us-central1-std-m-catalog'

# kubectl proxy
# You must already have these contexts locally defined by switching to the associated project at least once
# Run multiple proxies in parallel via multiple terminals or via parallel command, e.g:
# alias kc-proxy="parallel --will-cite --ungroup ::: 'kubectl proxy --port 8001 --context=gke_ebay-n1-nonprod_us-central1-a_us-central1-std-m' 'kubectl proxy --port 8002 --context=gke_npd-shared-nonprod_us-central1-a_us-central1-std-m'"
#alias proxysharednonprod='kubectl proxy --port 8001 --context gke_npd-shared-nonprod_us-central1-a_us-central1-std-m'
#alias proxysharedprod='kubectl proxy --port 8002 --context gke_npd-shared-prod_us-central1-a_us-central1-std-m'
#alias proxyrestrictednonprod='kubectl proxy --port 8003 --context gke_npd-restricted-nonprod_us-central1-a_us-central1-std-m'
#alias proxyrestrictedprod='kubectl proxy --port 8004 --context gke_npd-restricted-prod_us-central1-a_us-central1-std-m'
#alias proxyn1nonprod='kubectl proxy --port 8005 --context gke_ebay-n1-nonprod_us-central1-a_us-central1-std-m'
#alias proxyn1prod='kubectl proxy --port 8006 --context gke_ebay-n1-prod_us-central1-a_us-central1-std-m'
#alias proxyn2nonprod='kubectl proxy --port 8007 --context gke_ebay-n2-nonprod_asia-northeast1-a_asia-northeast1-std-m2'
#alias proxyn2prod='kubectl proxy --port 8008 --context gke_ebay-n2-prod_asia-northeast1-a_asia-northeast1-std-m2'

# Cluster switching
#alias gproj="gcloud config set project"
#alias gzone="gcloud config set compute/zone"
#function gcluster() {
#  CLUSTER_NAME=$@
#  gcloud config set container/cluster $CLUSTER_NAME
#  gcloud container clusters get-credentials $CLUSTER_NAME
#}

# Cluster creds
#alias kcreds='gcloud container clusters describe $CLUSTER_NAME | grep -E "endpoint|username|password"'

# SSH to GCE node

#alias gssh="gcloud compute ssh"

# Node Ports
# alias nodeports="kc get svc -o json | jq -r '.items[] | .np = .spec.ports[0].nodePort | select(.np != null) |  .metadata.name + \": \" + (.np | tostring)'"


