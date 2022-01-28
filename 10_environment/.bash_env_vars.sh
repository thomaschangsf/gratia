echo "      | .bash_env_vars.sh"

# ----------------------------------
# COMPUTE INSTANCES
# ----------------------------------
export c3InstanceDev="thchang-dev-4338486.lvs02.dev.ebayc3.com"

export clusterApolloReno="apollo-rno-devours.vip.hadoop.ebay.com"

export hmeaz1=lvt04c-2ikp.lvs02.eaz.ebayc3.com
export hmeaz2=lvt04c-3fji.lvs02.eaz.ebayc3.com # cannot login
export hmeaz3=lvt04c-5qfg.lvs02.eaz.ebayc3.com
export hmeaz4=lvt04c-7glr.lvs02.eaz.ebayc3.com
export hmeaz5=lvt04c-7pnh.lvs02.eaz.ebayc3.com
export hmeaz6=lvt04c-8lie.lvs02.eaz.ebayc3.com # cannot login
export gpueaz1=lvsadiml001.lvs.ebay.com
export gpueaz2=lvt04c-7mky.lvs02.eaz.ebayc3.com
export gpueaz3=lvt04c-6ygx.lvs02.eaz.ebayc3.com


# ----------------------------------
# DEV SUBDIRECTORIES
# ----------------------------------
dev=~/Documents/dev/

devKrylov=~/Documents/dev/krylov
alias cdk='cd $devKrylov'

devPersonal=~/Documents/dev/personal
alias cdp='cd $devPersonal'
alias cdml='cd $devPersonal/ml'

devCode=/Users/thchang/Documents/dev/code
alias cdc='cd $devCode'

devScratchPad=~/Documents/dev/scratchPad
alias cds='cd $devScratchPad'

devData=/Users/thchang/Documents/dev/data/
alias cdd='cd $devData'

devUacityHome=/Users/thchang/Documents/dev/personal/ml/udacity
alias cdu="pushd $devUacityHome"



# ----------------------------------
# GIT
# ----------------------------------
devGit=~/Documents/dev/git
devGitSmSciencePipeline=$devCode/ebay/sm-science-pipelines/
devGitSmPipeline=$devCode/ebay/sm-data-pipelines/
devGitNRT=$devGit/SearchNRTUpdates
devGitSearchIndex=$devGit/SearchIndex
devGitSearchEsUpload=$devGit/SearchIndexEsUpload
devGitSearchDataPipeline=$devGit/SearchDataPipeline
devGitSearchDataPipelineML=$devGit/SearchDataPipelineML
devGitSearchIndexLocalJar=$devGitSearchIndex/target/scala-2.10/SearchIndexBuild-assembly-2.1.11-SNAPSHOT.jar
devGitSearchDataPipleLineLocalJar=$devGitSearchDataPipeline/target/scala-2.11/SearchDataPipelineML-assembly-1.0.jar
devGitSearchEsUploadLocalJar=$devGitSearchEsUpload/target/scala-2.10/SearchIndexEsUploader-assembly-1.0.10-SNAPSHOT.jar
devGitPlayServiceCommon=$devGit/play-svc-common
devGitBackEndService=$devGit/backend-search-service
devGitBackEndAnalyzer=$devGit/backend-search-analyzer
devGitSearchIndexCommon=$devGit/SearchIndexCommon
devGitSearchNRTUpdates=$devGit/SearchNRTUpdates
devGitSearchProtoBuffModel=$devGit/SearchProtobufferModel
devGitSearchIndexEsUpload=$devGit/SearchIndexEsUpload
devGitSearchRecommendation=$devGit/search-science-recommendation/
devGitSearchRecommendationSvc=$devGit/search-rec-svc/
devGitBookRecommendation=$devGit/BookRecommendationEngine/
devGitRedisLocal=$devGit/redis/redisOpenSource/redis-4.0-rc2

alias cdg='cd $devGit'

alias cdgnlp='cd /Users/thchang/Documents/dev/git/nlp'
alias cdpynlp='cd /Users/thchang/Documents/dev/git/nlp/pynlp'

alias cdpr='cd $devProductRetreival'

alias cduia='cd /Users/thchang/Documents/dev/git/ebay/user-item-affinity'
alias cdsmsp='cd $devGitSmSciencePipeline'
alias cdsmp='cd $devGitSmPipeline'
alias cdbs='cd $devGitBackEndService'
alias cdnrt='cd $devGitNRT'
alias cdsi='cd $devGitSearchIndex'

alias cdMlrpy='cd /Users/thchang/Documents/dev/git/ebay/mlrpy'
alias cdMlrr='cd /Users/thchang/Documents/dev/git/ebay/mlrr'


alias cdData='cd /Users/thchang/Documents/dev/data/ebay/'
alias cdDataAA='cd /Users/thchang/Documents/dev/data/ebay/aspect-affinity'
alias cdBert='cd /Users/thchang/Documents/dev/git/ebay/bert_experiments'
alias cdGitEbay='cd cd /Users/thchang/Documents/dev/git/ebay'
alias cdDataRiver='cd $devData/ebay/river'

alias cdsdp='cd $devGitSearchDataPipeline'
alias cdsp='cd $devGitSearchDataPipeline'
alias cdspml='cd $devGitSearchDataPipelineML'

alias cdsic='cd $devGitSearchIndexCommon'

alias cdsr='cd $devGitSearchRecommendation'
alias cdsrb='cd $devGitBookRecommendation'
alias cdsrs='cd $devGitSearchRecommendationSvc'
alias cdd2l='cd /Users/thchang/Documents/dev/personal/ml/amazon'
alias cdnlp='cd /Users/thchang/Documents/dev/personal/ml/stanford/nlp/git'
alias cdInfra='cd $devGitInfra'

alias cdcf='cd /Users/thchang/Documents/dev/personal/scala/functionalDesign'
alias cdcp='cd /Users/thchang/Documents/dev/personal/scala/parallelProgramming'

alias cdaas='cd /Users/thchang/Documents/dev/personal/spark/AdvanceAnalyticsWithSpark/aas'

alias cdDataAA='cd /Users/thchang/Documents/dev/data/ebay/aspect-affinity/'
alias cdDataMlrr='cd /Users/thchang/Documents/dev/data/ebay/mlrr'
alias cdDataPP='cd /Users/thchang/Documents/dev/data/ebay/price-propensity/'

devGitEPI=$devGit/EPIJudge/epi_judge_python
devGitOpus=$devGit/opus
alias cdOpus='cd $devGitOpus'
alias cdEPI='cd $devGitEPI'

# ----------------------------------
# DB: NEO4J
# ----------------------------------
neo4jHome=/Users/thchang/Library/Application\ Support/Neo4j\ Desktop/Application/neo4jDatabases/database-f17d007b-ad83-4112-b6d7-6428049de721/installation-3.3.0
neo4jDatabase=$neo4jHome/data/databases/
neo4jBin=$neo4jHome/bin

# ----------------------------------
# DB: ELASTIC SEARCH
# ----------------------------------
esData=/usr/local/var/elasticsearch/elasticsearch_thchang/
esLog=/usr/local/var/log/elasticsearch/
esConfig=/usr/local/etc/elasticsearch/
esKibanaHome=/usr/local/etc/elasticsearch/kibana/kibana-5.4.0-darwin-x86_64
alias cdEsData='cd $esData'
alias cdEsLog='cd $esLog'
alias cdesConfig='cd $esConfig'
alias cdesKibanaHome='cd $esKibanaHome'

export dev
export devGit
export devScratchPad


