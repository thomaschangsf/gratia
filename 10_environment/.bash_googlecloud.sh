#!/bin/sh

echo "      | .bash_googlcloud.sh [gc*]"


# ------------------------------------------------------------------------
# Google Cloud
# ------------------------------------------------------------------------
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/thchang/google-cloud-sdk/path.bash.inc' ]; then source '/Users/thchang/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/thchang/google-cloud-sdk/completion.bash.inc' ]; then source '/Users/thchang/google-cloud-sdk/completion.bash.inc'; fi

function gcRunDataProcRec() {
  #Prerequisites
  # - kSetEnvN1ShopBotNonProd
  # - taskDataProcCreateCluster search-science-merchandise ebay-n2-nonprod -small

  #CLUSTER_NAME=search-science-merchandise
  CLUSTER_NAME=search-science-merchandise-n2-nonprod

  cdsr

  echo ${1}
  echo ${2}
  echo ${3}

  if [ "${3}" == "-copyJar" ]; then
    gsutil rm gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar
    gsutil -m cp $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/
  fi

  if [ "${3}" == "-buildAndCopyJar" ]; then
    sbt clean assembly;
    gsutil rm gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar
    gsutil -m cp $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/
  fi


  # Sample dataproc command: [Have note tested yet]
  #gcloud dataproc jobs submit spark --cluster ai-kg-wiki  --jars gs://npd-shared-nonprod-thchang/kg/wikiData/jar/EERBuilder.jar --class pipeline.Run --properties spark.executor.cores=10,spark.yarn.executor.memoryOverhead=3500,spark.executor.memory=28500m,spark.yarn.am.memoryOverhead=3500,spark.yarn.am.memory=28500m,spark.driver.memory=51440m,spark.driver.maxResultSize=30000m,spark.rpc.message.maxSize=1024,spark.network.timeout=720,spark.sql.shuffle.partitions=10000 -- -e cluster  -j ${1} -s "123" -l "456" -d "789"
  
  # gcloud dataproc jobs submit spark --cluster ai-kg-wiki  --jars gs://npd-shared-nonprod-thchang/kg/wikiData/jar/EERBuilder.jar --class pipeline.Run -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"
  # Exectuor getting killed.  solution: set spark.yarn.executor.memoryOverhead per https://stackoverflow.com/questions/31728688/how-to-prevent-spark-executors-from-getting-lost-when-using-yarn-client-mode?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
  
  # Spark configurations: https://spark.apache.org/docs/latest/configuration.html

  # For ExtractWikiKnowlege, based on the settings for large in taskDataProcCreateCluster
  #   Set size per: https://docs.google.com/spreadsheets/d/1rrBLzKdgV-rvsFS094dak7l7IPvP7PSZzxWAk5_HiXs/edit#gid=1840413697
  #   Set properties: --properties spark.executor.cores=5,spark.executor.instances=7,spark.executor.memory=15g
  
    if [ "${2}" == "-recJobSize" ]; then   
      # Assumes 2 n1-standard-64
      # ORIG gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run --properties spark.yarn.driver.memoryOverhead=10000,spark.yarn.executor.memoryOverhead=10000,spark.executor.cores=30,spark.executor.instances=3,spark.driver.memory=100g,spark.executor.memory=100g,spark.executor.heartbeatInterval=20s,spark.network.timeout=1200 -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"
      # gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run --properties spark.yarn.driver.memoryOverhead=10000,spark.yarn.executor.memoryOverhead=10000,spark.executor.cores=10,spark.executor.instances=11,spark.driver.memory=100g,spark.executor.memory=37g,spark.executor.heartbeatInterval=20s,spark.network.timeout=1200 -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"

      # Assumes 4 n1-standard-64
      gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run --properties spark.yarn.driver.memoryOverhead=10000,spark.yarn.executor.memoryOverhead=10000,spark.executor.cores=10,spark.executor.instances=24,spark.driver.memory=100g,spark.executor.memory=31g,spark.executor.heartbeatInterval=20s,spark.network.timeout=1200 -- --env cluster.n2nonprod --jobs ${1} --debug true --siteId 0

      #With 5 n1-standard-64 - WORKS!
      #gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run --properties spark.yarn.driver.memoryOverhead=10000,spark.yarn.executor.memoryOverhead=5000,spark.executor.cores=30,spark.executor.instances=9,spark.driver.memory=100g,spark.executor.memory=100g,spark.executor.heartbeatInterval=20s,spark.network.timeout=1500 -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"
      
      # Assumes n1-standard-16
      #gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run --properties spark.yarn.driver.memoryOverhead=10000,spark.yarn.executor.memoryOverhead=5000,spark.executor.cores=5,spark.driver.memory=30g,spark.executor.memory=27g,spark.executor.instances=23,spark.executor.heartbeatInterval=20s,spark.network.timeout=1200 -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"
    fi

    if [ "${2}" == "-small" ]; then   
      #gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run --properties spark.yarn.executor.memoryOverhead=1500,spark.executor.cores=5,spark.executor.memory=26g,spark.executor.instances=2,spark.executor.heartbeatInterval=20s,spark.network.timeout=1200  -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"
      gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar --class pipeline.Run -- -env cluster -t generator -j ${1} -s "123" -l "456" -d "789"
    fi


    if [ "${2}" == "-large" ]; then
      # 20 v-highmem-64 machines. This works when my broadcast map was 29 million entries. Now I am at 30 million, and it fails...
      gcloud dataproc jobs submit spark --cluster $CLUSTER_NAME  --jars gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar  --class pipeline.Run --properties spark.yarn.executor.memoryOverhead=8g,spark.executor.cores=10,spark.executor.instances=64,spark.executor.memory=192g,spark.executor.heartbeatInterval=20s,spark.network.timeout=1200,spark.executor.extraJavaOptions=" -XX:ReservedCodeCacheSize=100M -XX:MaxMetaspaceSize=256m -XX:CompressedClassSpaceSize=256m" -- -e cluster -t generator -j ${1} -s "123" -l "456" -d "789"
    fi

  # Delete cluster
  # taskDataProcDeleteCluster search-science-merchandise ebay-n1-nonprod

  # To see spark job details:
  #   taskSiDataProcOpenWebInterface search-science-merchandise-m
  #     http://search-science-merchandise-m:18080/
  #     terminal where I run data proc also outputs tracking url: ie http://search-science-merchandise-m:8088/proxy/application_1522425870991_0012/

}

function gcCreateCluster() {
  # machine sizes: https://cloud.google.com/compute/docs/machine-types
  #gcloud dataproc clusters create ${1} --subnet us-central1-m --zone us-central1-b --master-machine-type n1-standard-8 --master-boot-disk-size 500 --num-workers 2 --worker-machine-type n1-standard-16 --worker-boot-disk-size 500 --num-preemptible-workers 2 --image-version 1.1 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ${2} --initialization-actions gs://ai-hlt/zeppelin.sh --labels team=ai-hlt

  #gcloud dataproc jobs submit spark --help

  if [ "${3}" == "-small" ]; then
    gcloud dataproc clusters create ${1} --subnet us-central1-m --zone us-central1-b --master-machine-type n1-standard-8 --master-boot-disk-size 50 --num-workers 2 --worker-machine-type n1-standard-8 --worker-boot-disk-size 50 --num-preemptible-workers 0 --image-version 1.2 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ${2} --initialization-actions gs://ai-hlt/zeppelin.sh --labels team=ai-hlt
  fi

  if [ "${3}" == "-recJobSize" ]; then
    #image chosen to support spark 2.2. 
    
    # Uses n1-standard-64, but appears to be too big
    gcloud dataproc clusters create ${1} --subnet asia-northeast1-m --zone asia-northeast1-a --master-machine-type n1-standard-64 --master-boot-disk-size 600 --num-workers 2 --worker-machine-type n1-standard-64 --worker-boot-disk-size 350 --num-preemptible-workers 0 --image-version 1.2 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ${2} --labels team=search
    
    # Uses n1-standard-16
    # gcloud dataproc clusters create ${1} --subnet us-central1-m --zone us-central1-b --master-machine-type n1-standard-16 --master-boot-disk-size 600 --num-workers 2 --worker-machine-type n1-standard-16 --worker-boot-disk-size 350 --num-preemptible-workers 0 --image-version 1.2 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ${2} --labels team=ai-hlt
  fi

  if [ "${3}" == "-recJobSizeN2Prod" ]; then
    #gcloud dataproc clusters create search-science-merchandise --network n2-prod-m --subnet asia-northeast1-m --zone asia-northeast1-a --master-machine-type n1-standard-64 --master-boot-disk-size 500 --num-workers 2 --worker-machine-type n1-standard-64 --worker-boot-disk-size 500 --image-version 1.2 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ebay-n2-prod --labels team=search

    gcloud dataproc clusters create ${1} --subnet asia-northeast1-m --zone asia-northeast1-a --master-machine-type n1-standard-64 --master-boot-disk-size 500 --num-workers 2 --worker-machine-type n1-standard-64 --worker-boot-disk-size 500 --image-version 1.2 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ebay-n2-prod --labels team=search
  fi

  if [ "${3}" == "-xlarge" ]; then   
    gcloud beta dataproc clusters create --master-min-cpu-platform "Intel Skylake" --worker-min-cpu-platform "Intel Skylake" ${1} --subnet us-central1-m --zone us-central1-b --master-machine-type n1-highmem-96 --master-boot-disk-size 600 --num-workers 20 --master-machine-type n1-highmem-64 --worker-boot-disk-size 350  --num-preemptible-workers 0 --image-version 1.2 --scopes 'https://www.googleapis.com/auth/cloud-platform' --project ${2} --initialization-actions gs://ai-hlt/zeppelin.sh --labels team=ai-hlt
  fi
}

function gcDeleteCluster() {
  gcloud beta dataproc --project $2 --region global clusters delete $1 --quiet
}

function gcRedisOpenWebInterface() {
  # https://cloud.google.com/dataproc/docs/concepts/cluster-web-interfaces
  # Set up port forwarding.  Set up a ssh tunnerl between google cloud and my mac.
  # When an app talks to localhost port 1080, forward to the tunnel
  gcloud compute ssh  --zone=us-central1-b --ssh-flag="-D 1081" --ssh-flag="-N" --ssh-flag="-n" redislec-dev-nchant-us-c1-i1 &

  # http://redislec-dev-nchant-us-c1-i1:8443
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-server="socks5://localhost:1081" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" --user-data-dir=/tmp/
}

alias gcWFSearch="searchStartSbt"
function searchStartSbt() {
  cdbs
  # kpN1shotBotNonProd
  # kndev
  # gcloud config set compute/zone us-central1-b
  # gcloud compute ssh --ssh-flag=-L9200:localhost:9200 elasticsearch-dev-nchant-us-c1-be-1
  
  # Duplicate notes in Dev kubernetes
  # Overview
  #   kSetEnvN1ShopBotNonProd kSetEnvN1ShopBotProd kSetEnvNEbay
  #     Sets the project
  #     Set the kubernetes namespace
  #   kndev knprod knsearchdev knsearchprod
  #     Remember that not all projects support the search-prod namespaces.

  # Typically, we just need to 
  #   Set project: kpN1shotBotProd, kpNebayN
  #   Set KUBENAMESPCE: knsearchprod, kndev, kprod
  #   Fetch credential: kc

  # Set [PROJECT]: n1shotBotProd | n1shotBotNonProd | nebayN
  #   gcloud config set project ebay-n1-prod
  #   gcloud config set project ebay-n1-nonprod
  #   gcloud config set project ebay-n
  
  # Set [KUBERNETES NAMESPACE]: knprod | knprod | knsearchdev 
  #   export KUBE_NAMESPACE=search-prod
  #   export KUBE_NAMESPACE=search-dev  
  #   export KUBE_NAMESPACE=prod

  # Set [COMPUTE ZONE] - Needed only for VMs
  #   gcloud config set compute/zone us-central1-b #Containers are in zone-A; es cluster is in zoneB

  # Set [CONTAINER CLUSTER]
  #   gcloud config set container/cluster us-central1-std-m
  
  # Fetch the [CONTAINER CREDENTIALS]
  #   gcloud container clusters get-credentials us-central1-std-m --project ebay-n1-nonprod --zone us-central1-a
  #   gcloud container clusters get-credentials us-central1-std-m --project ebay-n1-prod --zone us-central1-a
  #   gcloud container clusters get-credentials us-central1-standard-m --project ebay-n --zone us-central1-a

  # check: 
  #   gcloud info 
  #   gcloud config list
  #   gVmList
  #   gClusterList

  # Proxy to es vm: application.tom.conf is using localhost 9200 to talk to elasticsearch
  #   gcloud compute ssh --ssh-flag=-L9200:localhost:9200 elasticsearch-prod-nchant-us-c1-bh-1
  #   gcloud config set compute/zone us-central1-b

  # Services in Mac talking to pods in google cloud
  #   Option 1: Proxy to containers in gcloud, if code uses http://localhost:8001/api/v1/proxy/namespaces/dev/services/aidmsvc:http
  #     kubectl proxy --port 8001

  #   Option 2: Port forwarding:  if app uses localhost:5051, ie siPortForwardToCatalog
  #     kc port-forward [POD-NAME] 50051:50051

  # trackingSetPubSubCredential  

  # To commit, take a look at Dev-GIT/ Working with n1 n2

  # Get pod names
  #   If I set up the project, namespace, zone, and credential correctly
  #     kc get pods
  #   kubectl get pods --namespace=search-dev
  #   kubectl get pods --namespace=search-prod | grep p-search-svc

  # See the logs
  #   kLogIntoPods 
  #   kubectl --namespace search-prod logs -f p-search-svc-775895799-494h3
  #   kubectl --namespace search-dev logs -f p-search-svc-775895799-494h3
    
  # Describe the pods: can see start up issues
  #   kc describe pod p-search-svc-556874731-fwx1t 
  #   kubectl describe pod p-search-svc-556874731-fwx1t  --namespace search-prod

  # Log into pod
  #   kLogIntoPod 
  sbt -jvm-debug 9998 "~run 9006" -Dconfig.file=conf/application.tom.n2.conf
}

function gcConfigList() {
  gcloud config list
}


# gAutoScale zeus-web 50 5 20
function gcAutoScale() {
  #zeus-web
  kc autoscale deployment ${1} --cpu-percent=${2} --min=${3} --max=${4}
}

function gcVmList() {
  gcloud compute instances list
}

function gcClusterList() {
  gcloud container clusters list
}

function gcRCList() {
  kubectl get rc
}

function gcServiceList() {
  kubectl get services
}

function gcGetClusterCredentials() {
  gcloud container clusters get-credentials $1
}
 
function gcGetClusterCredentialsProd() {
  gcloud container clusters get-credentials psearchsvc-uc1b-prod-cluster
}

function gcGetClusterCredentialsDev() {
  gcloud container clusters get-credentials psearchsvc-uc1b-dev-cluster
}

function gcLogPods() {
  kubectl logs ${1} -f
}

function gLogPodsPrev() {
  kubectl logs --namespace=prod --previous=true ${1} -f 
}

function gcLogIntoPods() {
  kubectl exec ${1} -ti -- bash
}

function gcCredentialAsia() {
  gcloud container clusters get-credentials asia-northeast1-std-m --zone asia-northeast1-a --project ebay-nchant 
}

