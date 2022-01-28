#!/bin/sh

echo "      | .bash_datapipeline.sh [dp*|airflow*]"


# ------------------------------------------------------------------------
# DataPipeilne: Spark & Hadoop
#	  Refer to ml-tools.git/datapipeline/spark/scripts for HDFS commands
# ------------------------------------------------------------------------
#export AIBIGDATA_HOME="/usr/local/AIBigData"
#export HADOOP_HOME=$AIBIGDATA_HOME/hadoop-2.7.0
#export SPARK_HOME=${AIBIGDATA_HOME}/spark-2.2.0-bin-hadoop2.7/
export SPARK_HOME=/opt/spark/
export SPARK_BIN=${SPARK_HOME}/bin
export PATH=${SPARK_BIN}:${PATH}

export SPARK_HOME="/opt/spark"
export PATH=$SPARK_HOME/bin:$PATH
export SPARK_LOCAL_IP='127.0.0.1'

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
export PYSPARK_PYTHON=python3


function dpParquetRead() {
  #installed on mac via: homebrew install parquet-tools
  parquet-tools cat --json ${1}
}

function dpSparkRunLocalSM() {
  cdsmp

  #sbt compile package
  sbt -Dspark.master=local -J-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=7778
  # Intellij --> Start SparkLocak debugger
  run --config local.conf --jobs QueryRankMetrics

  # pushd /Users/thchang/Documents/dev/code/ebay/sm-data-pipelines/result/jobs/MonetizationMetrics/aggregate
  # toolsParquetRead ./FriFeb1513\:57\:49PST2019/parquet/part-00000-e7181aa4-5e2e-4cad-92a6-5cb79660abae-c000.snappy.parquet | more
}


# sparkRunRemoteSM -buildJar
function dpSparkRunRemoteSM() {

  if [ "${1}" == "-buildJar" ]; then
    #sbt -mem 18192 clean update compile && sbt -mem 18192 clean update universal:packageBin
    sbt -mem 18192 clean compile universal:packageBin

  fi

  # password = CORP
  #./copyPackageToCluster.sh $USER@apollo-rno-devour.vip.hadoop.ebay.com
  ./copyPackageToCluster.sh apollo-rno-devours.vip.hadoop.ebay.com

  #taskSmRemoteInstructionsReno

  # ssh apollo-rno-devours.vip.hadoop.ebay.com "cd /home/thchang/binaries/sm-data-pipeline/next-version && unzip -o sm-data-pipelines-1.0-SNAPSHOT.zip && cd /home/thchang/binaries/sm-data-pipeline/next-version && ls -alh sm-data-pipelines-1.0-SNAPSHOT.zip sm-data-pipelines-1.0-SNAPSHOT"
}

function dpSparkRunLocalRec() {
  cdsr
  if [ "${2}" == "-buildJar" ]; then
    sbt -mem 8096 clean compile assembly;
  fi

  chmod +x $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar
  export SPARK_SUBMIT_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=7778;

  # Orig
  # spark-submit --class pipeline.Run --master local[2] $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar -e local -t generator -j ${1} -s "123" -l "456" -d "789"

  spark-submit --driver-memory 6G --class pipeline.Run --master local[*] $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar --env local --jobs ${1} --debug true --siteId 0

  # Run Spark-Local debugger from IntelliJ
  #   Debug confiugration --> Remote --> port = 7777
  #   Spark UI: localhost:4040

  # Sample dataproc command:
  # gcloud dataproc jobs submit spark --region us-central1 --cluster ai-hlt-weekly-aggregation-au --jars gs://ai-data/kg/builder/jar/EERBuilder.jar --class pipeline.Run --properties spark.executor.cores=10,spark.yarn.executor.memoryOverhead=3500,spark.executor.memory=28500m,spark.yarn.am.memoryOverhead=3500,spark.yarn.am.memory=28500m,spark.driver.memory=51440m,spark.driver.maxResultSize=30000m,spark.rpc.message.maxSize=1024,spark.network.timeout=720,spark.sql.shuffle.partitions=10000 -- -e cluster -s {{ macros.ds_add(ds, -2) }} -l {{ macros.ds_add(ds, 5) }} -j QueryItem,QueryAspect -t aggregator -S 15
}

function dpSparkShellLocal() {
  cdsp
  #sbt clean assembly
  spark-shell --jars $devGitSearchDataPipeline/target/scala-2.11/search-data-pipeline-assembly-0.0.1-DEV.jar --master=local[2] --driver-memory 4G --executor-memory 4G

  `
  import com.typesafe.config.Config
  import org.apache.spark
  import org.apache.spark.SparkContext
  import org.apache.spark.rdd.RDD
  import org.apache.spark.sql.{DataFrame, Dataset, Row, SQLContext}

  val sqlContext = new SQLContext(sc)
  import sqlContext.implicits._
  `
  # Look at Ref-Spark-SQL notes line 231

  # Sample code: SearchDataPipline.git : DataFrameExp
}

function dpSparkHDFSWF() {
  export dataAdRate=/apps/b_sscience/srchmon/ads-rates/test-run
  echo "On cluster, type:"
  echo "   - taskSmJobRunQueryRankMetrics"
  echo "   - taskSmJobRunItemMetrics"
  echo "   - taskSmJobRunAllMetrics"
  echo "   - taskSmJobRunBSS"
  # pushd /home/thchang/binaries/sm-data-pipeline/next-version/sm-data-pipelines-1.0-SNAPSHOT &&  ./runJob.sh AdRateGuidanceMetrics &

  echo "   - taskSmJobShowAllApplicationIds"
  # hadoop fs -du -h /app-logs/thchang/logs/

  echo "   - taskSmJobLog applicationID"
  # yarn logs -applicationId application_1549069960293_191791

  echo "   - taskSmJobCheckOutputDev"
  echo "   - taskSmJobCheckOutputProd"
  echo "   - hadoop fs -ls -R ${dataAdRate}/stage2-query-rank-metrics/ | grep "^d""
  echo "   - hadoop fs -ls -R ${dataAdRate}/stage2-item-metrics/ | grep "^d""

  echo "    "
  echo "   Move data from hdfs to my directory "
  echo "   - export ADRATE_DATA_DATE=2019/02/15 "
  echo "   - hadoop fs -ls  ${dataAdRate}/stage2-query-rank-metrics/daily/$ADRATE_DATA_DATE "
  echo "   - taskSmJobCopyFromHDFS ${dataAdRate}/stage2-query-rank-metrics/daily/$ADRATE_DATA_DATE/part-00005-101ef1cb-4cfb-424e-8168-4972c9afc6d4-c000.snappy.parquet /home/thchang/data/adrates/query-rank-metrics/ "

  echo "   - hadoop fs -ls  ${dataAdRate}/stage2-item-metrics/daily/$ADRATE_DATA_DATE "
  echo "   - taskSmJobCopyFromHDFS ${dataAdRate}/stage2-item-metrics/daily/$ADRATE_DATA_DATE/part-04999-b99a32e9-d529-43a3-a2b8-5250503338b1-c000.snappy.parquet /home/thchang/data/adrates/item-metrics/ "

  echo "   - hadoop fs -ls  ${dataAdRate}/stage1-unique-query/$ADRATE_DATA_DATE "
  echo "   - taskSmJobCopyFromHDFS ${dataAdRate}/stage1-unique-query/$ADRATE_DATA_DATE/part-00000-49f032f0-db8c-4ba2-9bd9-5e9edd826c08-c000.csv.gz /home/thchang/data/adrates/unique-query/ "

  echo "   - hadoop fs -ls  ${dataAdRate}/stage1-item-query/daily/$ADRATE_DATA_DATE "
  echo "   - taskSmJobCopyFromHDFS ${dataAdRate}/stage1-item-query/$ADRATE_DATA_DATE/part-00019-7b0c1369-d3d5-4bc2-a4a6-6cd698ec5f4a-c000.csv.gz /home/thchang/data/adrates/item-query/ "

  echo "    "
  echo "    Remove directory"
  echo "   - hdfs dfs -rm -r ${dataAdRate}/stage2-query-rank-metrics "
  echo "   - hdfs dfs -rm -r ${dataAdRate}/stage2-item-metrics "
  echo "   - hdfs dfs -rm -r ${dataAdRate}/stage2-item-metrics "
  # hdfs dfs -rm -r $1
}

# ------------------------------------------------------------------------
# Data Pipeline: NRT
# ------------------------------------------------------------------------
function dpNrtMasterEnv ()
{
    export AZ='us-central1-b';
    export ENV='tomMaster';
    export APP='search-nrt-c1b-1'
}
function dpNrtStartMaster() {
  dpNrtMasterEnv
  #export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=4000,server=y,suspend=n"
  export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"
  #mvn jetty:run
  cdnrt
  dpNrtMasterEnv
  java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n -cp /Users/thchang/Documents/dev/git/SearchNRTUpdates/target/search-nrt-1.0.1-SNAPSHOT.jar com.ebay.n.search.nrt.Nrt
}


function dpNrtSlaveEnv() {
  # Property file env-zone-app.property located in git/SearchNRTUpdates/src/main/resources
  export AZ='us-central1-b' #aka Zone
  export ENV='tomSlave' #used to be prod'
  export APP='search-nrt-c1b-1' #kubernetes deployment=search-nrt-c1a-1-svc

}
function dpNrtStartSlave() {
  # Property file env-zone-app.property located in git/SearchNRTUpdates/src/main/resources
  export MAVEN_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8002,server=y,suspend=n"
  cdnrt
  dpNrtSlaveEnv
  java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8002,suspend=n -cp /Users/thchang/Documents/dev/git/SearchNRTUpdates/target/search-nrt-1.0.1-SNAPSHOT.jar com.ebay.n.search.nrt.Nrt
}


function dpVisualVmStart() {
  /usr/bin/jvisualvm
}


# -----------------------------------------------------
# Orchestration: Airflow
# -----------------------------------------------------
# Set up workflow via virutal env
function airflowSetupPythonEnv() {
  # Reference: http://michal.karzynski.pl/blog/2017/03/19/developing-workflows-with-apache-airflow/

  # Assumes virtualenv airflow was setup with the following:
  #   cd ~/virtualenv
  #   virtualenv airflow
  #   source airflow/bin/activate
  #   pip install airflow==1.8.0
  #   pip install ipython

  source ~/virtualenv/airflow/bin/activate

  cdsr
  export AIRFLOW_HOME=`pwd`/airflowHome
  cd $AIRFLOW_HOME

  # To exit virtual env
  # deactivate
}
# toolRecAirflowStartN2RecApp [-all|-webserver|-webserverAndScheduler]
# Starts the airflow server for search-recommendation-science
function airflowStartåApp() {

  # Assumes airflowSetupPythonEnv

  cdsr
  export AIRFLOW_HOME=`pwd`/airflowHome
  cd $AIRFLOW_HOME

  echo "User entered: |${1}| "

  if [ "${1}" == "-all" ]; then
    airflow initdb
    airflow webserver -p 8080
    airflow scheduler
  fi

  if [ "${1}" == "-webserver" ]; then
    airflow webserver -p 8080
  fi

  if [ "${1}" == "-webserverAndScheduler" ]; then
    airflow webserver -p 8080
    airflow scheduler
  fi

  # Debug commands: Reference: scratchpad/Rec-Task (Airflow Setup)
  # airflow list_dags
  # airflow list_tasks my_test_dag
  # airflow test my_test_dag my_first_operator_task 2017-03-18T18:00:00.0

  # How to import third party operators?
  #   pip show airflow
  #   location --> /Users/thchang/virtualenv/airflow/lib/python2.7/site-packages/
  #   go to ${location}/airflow/contrib/operators & copy from git/incubator-airflow/airflow/contrib/operators

  # Test one specific task
  #airflow test my_test_dag my_first_operator_task 2017-03-18T18:00:00.0
}

#recSyncAirflowVmToMac -copyJar|buildAndCopyJar
# Note: copyJar copies to gs:../jarForProd
function airflowFromMacToGCExample() {
  cdsr

  recScpToAirflowVm airflowHome/dags/bql/n2_user_behavior.sql /airflow/dags/bql

  recScpToAirflowVm airflowHome/dags/etl_ingest_behavior_data_dag.py /airflow/dags/

  recScpToAirflowVm airflowHome/dags/etl_train_rec_model_dag.py /airflow/dags/

  if [ "${1}" == "-copyJarToProd" ]; then
    gsutil rm gs://npd-shared-nonprod-thchang/search/ml/recommendation/jarForProd/SearchRecommendation.jar
    gsutil -m cp $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar gs://npd-shared-nonprod-thchang/search/ml/recommendation/jarForProd/
  fi

  if [ "${1}" == "-buildAndCopyJarToProd" ]; then
    sbt clean assembly;
    gsutil rm gs://npd-shared-nonprod-thchang/search/ml/recommendation/jarForProd/SearchRecommendation.jar
    gsutil -m cp $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar gs://npd-shared-nonprod-thchang/search/ml/recommendation/jarForProd/
  fi

  if [ "${1}" == "-copyJarToDev" ]; then
    gsutil rm gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar
    gsutil -m cp $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/
  fi

  if [ "${1}" == "-buildAndCopyJarToDev" ]; then
    sbt clean assembly;
    gsutil rm gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/SearchRecommendation.jar
    gsutil -m cp $devGitSearchRecommendation/target/scala-2.11/SearchRecommendation.jar gs://npd-shared-nonprod-thchang/search/ml/recommendation/jar/
  fi

}