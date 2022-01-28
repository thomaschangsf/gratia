#!/bin/sh

echo "      | .bash_databases.sh [db*]"

# ------------------------------------------------------------------------
# DB: Redis
# ------------------------------------------------------------------------
function dbRedisStopLocal() {
  cd $devGitRedisLocal
  src/redis-server stop
}

function dbRedisCli() {
  $devGitRedisLocal/src/redis-cli
}

function dbRedisCliLocal() {
  cd $devGitRedisLocal
  src/redis-cli
}

function dbRedisCliRemoteN2Prod() {
  # Assumes
  # n2prod
  # gcloud compute --project ebay-n2-prod ssh --ssh-flag=-L14404:localhost:14404 --zone asia-northeast1-c redis-rlec-asia-n2-prod-3

  cd $devGitRedisLocal
  src/redis-cli -p 14404
}

function dbRedisCliRemoteN2NonProd() {
  # Assumes
  # n2prod
  # gcloud compute --project ebay-n2-prod ssh --ssh-flag=-L14404:localhost:14404 --zone asia-northeast1-c redis-rlec-asia-n2-prod-3

  cd $devGitRedisLocal
  src/redis-cli -p 14063
}

function dbRedisCliLocalGetKeys() {
  # redisCliLocalGetKeys 13*
  $devGitRedisLocal/src/redis-cli KEYS $1
}

function dbRedisCliLocalDeleteKeys() {
  #redisCliLocalDeleteKeys 13*
  #sometimes if we can't delete all the keys, use FLUSHDB
  $devGitRedisLocal/src/redis-cli KEYS $1| xargs $devGitRedisLocal/src/redis-cli DEL
}

function dbRedisBenchMark() {
  cd $devGitRedisLocal
  redis-benchmark -q -n 100000 --csv -c 10 -t HSET,HGET,SET,GET,SADD,SPOP
}



# ------------------------------------------------------------------------
# DB: Elasticsearch
# ------------------------------------------------------------------------
function dbEsStartLocal() {
  #pushd /usr/local/opt/elasticsearch@2.4/bin/
  # Look at knows: Dev-Pipeline-ElasticSearchOnMac
  pushd /usr/local/opt/elasticsearch@5.4/bin/

  ./elasticsearch
}


function dbEsGetIndexInfo() {
  curl -X GET http://${1}:9200/_cat/indices?v
}

function dbEsGetIndexInfoLocal() {
  curl -X GET http://localhost:9200/_cat/indices?v
}

# esGetHealth 104.155.164.127 (ie public ip of one of the vm)
function dbEsGetHealth() {
  curl -X GET http://${1}:9200/_cat/indices?v
}


function dbEsCreateIndex() {
  curl -H "Content-Type: application/json" http://localhost:9200/$1/ -X POST -d '{}' 
}

function dbEsDeleteIndex() {
  curl -X "DELETE" http://localhost:9200/$1
}


function dbEsCurlPort9200() {
  curl -i -XGET ${1}:9200/
}

function dbEsCreateIndexEbayN_2_4() {
  # mapping is accurate as of 2/21 based on SearchIndex/elasticsearch/elasticsearch-mapping-2.4.x.txt
  curl -H "Content-Type: application/json" http://localhost:9200/ebay-n/ -X POST -d '{
  "settings": {
    "number_of_shards": 40,
    "number_of_replicas": 1,
    "refresh_interval": "-1",
    "similarity": {
      "my_bm25": {
        "type": "BM25",
        "k1": 0.2,
        "b": 0.2
      }
    }
  },
  "mappings": {
    "listing": {
      "include_in_all": false,
      "properties": {
        "item_id": {
          "type": "long"
        },
        "title": {
          "type": "string",
          "analyzer": "english",
          "similarity": "my_bm25",
          "index_options": "docs"
        },
        "sub_title": {
          "type": "string",
          "index": "no"
        },
        "desc": {
          "type": "string",
          "index": "no"
        },
        "leaf_categ_id": {
          "type": "long"
        },
        "semantic_v": {
          "type": "double",
          "index": "no"
        },
        "price": {
          "type": "double"
        },
        "original_price": {
          "type": "double"
        },
        "slr_id": {
          "type": "long"
        },
        "images": {
          "type": "string",
          "index": "no"
        },
        "attr_ner_keys": {
          "type": "string",
          "index": "not_analyzed"
        },
        "attr_ner": {
          "type": "string",
          "index": "no"
        },
        "attr_seller_keys": {
          "type": "string",
          "index": "not_analyzed"
        },
        "attr_seller": {
          "type": "string",
          "index": "no"
        },
        "attr_cls_keys": {
          "type": "string",
          "index": "not_analyzed"
        },
        "attr_cls": {
          "type": "string",
          "index": "no"
        },
        "condition": {
          "type": "integer"
        },
        "demote": {
          "type": "double"
        },
        "demote_v2": {
          "type": "double"
        },
        "deal_score": {
          "type": "double"
        },
        "item_loc": {
          "type": "string",
          "index": "not_analyzed"
        },
        "ship": {
          "type": "string",
          "index": "no"
        },
        "return": {
          "type": "string",
          "index": "no"
        },
        "raw_version": {
          "type": "long"
        },
        "nrt_timestamp": {
          "type": "long"
        },
        "trend_score": {
          "type": "double"
        },
        "start_ts": {
          "type": "long"
        },
        "end_ts": {
          "type": "long"
        },
        "data_flag": {
          "type": "integer"
        },
        "seller_detail": {
          "type": "string",
          "index": "no"
        },
        "visit_count": {
          "type": "integer"
        },
        "watch_count": {
          "type": "integer",
          "index": "no"
        },
        "quantity_sold": {
          "type": "integer",
          "index": "no"
        },
        "quantity": {
          "type": "integer",
          "index": "no"
        },
        "msku": {
          "type": "string",
          "index": "no"
        },
        "attr_msku": {
          "type": "string",
          "index": "no"
        },
        "attr_msku_keys": {
          "type": "string",
          "index": "not_analyzed"
        },
        "iso_start_ts": {
          "type": "date"
        },
        "iso_end_ts": {
          "type": "date"
        },
        "meta_categ_id": {
          "type": "long"
        },
        "seller_name": {
          "type": "string"
        },
        "fast_and_free_shipping": {
          "type": "integer"
        },
        "ai_interest_id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "seller_rating": {
          "type": "double"
        },
        "product_rating": {
          "type": "double"
        },
        "product_rating_count": {
          "type": "integer"
        },
        "product_review_count": {
          "type": "integer"
        },
        "product_rating_histogram": {
          "type": "string",
          "index": "no"
        },
        "product_id": {
          "type": "long"
        }
      }
    }
  }
}'
}


# ------------------------------------------------------------------------
# DB: MYSQL
# ------------------------------------------------------------------------
#alias mysql=${MYSQL_HOME}/bin/mysql
#alias mysqladmin=${MYSQL_HOME}/bin/mysqladmin
#export DYLD_LIBRARY_PATH=${MYSQL_HOME}/lib/:$DYLD_LIBRARY_PATH
function dbMystart() {
  pushd ${MYSQL_HOME}
  sudo ./bin/mysqld_safe &
  popd
}
function dbMy() {
  if [ "$1" == "" ] ; then
    mysql -u root
  else
    mysql -u root -D $1
  fi
}
function dbMyclone() {
  local dbto=$1
  echo "drop database if exists ${dbto};" | mysql -u root
  echo "create database ${dbto};" | mysql -u root
  while [ ! "${2}" == "" ]; do
    local dbfrom=$2
    rm -f /tmp/${dbfrom}_schema.sql
    mysqldump -u root --no-data ${dbfrom} > /tmp/${dbfrom}_schema.sql
    mysql -u root -D ${dbto} < /tmp/${dbfrom}_schema.sql
    rm -f /tmp/${dbfrom}_schema.sql
    shift
  done
}
function dbMycfg() {
  subl ${MYSQL_HOME}/my.cnf
}

# sqllite
function dbMySql() {
  sqlite3 -header -column $1
}