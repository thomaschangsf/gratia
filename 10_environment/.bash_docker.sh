#!/bin/sh

echo "      | .bash_docker.sh [d*]"

# ------------------------------------------------------------------------
# Docker
# ------------------------------------------------------------------------
function dIp() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
}

function dLog() {
  docker logs -f ${1}
}

function dLogin() {
  docker exec -t -i ${1}  /bin/bash
}

function dTop() {
  docker top ${1}
}

function dRmImages() {
  _QUIET=0
  if [ "${1}" == "-q" ]; then
    _QUIET=1
    shift
  fi
  _FOUND=0

  #_LABEL_N_ENV=${1}
  _LABEL_N_SERVICE=${1}

  #_ALL_IMAGES=$(docker images -q -f "label=n.env=${_LABEL_N_ENV}" -f "label=n.service=${_LABEL_N_SERVICE}" | uniq)
  _ALL_IMAGES=$(docker images -q -f "label=n.service=${_LABEL_N_SERVICE}" | uniq)
  if [ "${_ALL_IMAGES}" != "" ]; then
    _FOUND=1
    echo Removing `expr $(echo ${_ALL_IMAGES} | grep -o " " | wc -l) + 1` docker images\(s\) ...
    docker rmi -f ${_ALL_IMAGES}
  fi

  if [ "${_FOUND}" != "1" ]; then
    if [ "$_QUIET" != "1" ]; then
      echo Cannot find ${_LABEL_N_SERVICE} docker images
    fi
  fi
}

function dRmContainer() {
_QUIET=0
if [ "${1}" == "-q" ]; then
  _QUIET=1
  shift
fi
_FOUND=0

#_LABEL_N_ENV=${1}
_LABEL_N_SERVICE=${1}

_RUNNING_CONTAINERS=$(docker ps -q -f "label=n.service=${_LABEL_N_SERVICE}" | uniq)
if [ "${_RUNNING_CONTAINERS}" != "" ]; then
  _FOUND=1
  echo Stopping `expr $(echo ${_RUNNING_CONTAINERS} | grep -o " " | wc -l) + 1` ${_LABEL_N_SERVICE} docker container\(s\) ...
  docker stop ${_RUNNING_CONTAINERS}
fi

_ALL_CONTAINERS=$(docker ps -a -q -f "label=n.service=${_LABEL_N_SERVICE}" | uniq)
if [ "${_ALL_CONTAINERS}" != "" ]; then
  _FOUND=1
  echo Removing `expr $(echo ${_ALL_CONTAINERS} | grep -o " " | wc -l) + 1` ${_LABEL_N_SERVICE} docker container\(s\) ...
  docker rm ${_ALL_CONTAINERS}
fi

if [ "${_FOUND}" != "1" ]; then
  if [ "$_QUIET" != "1" ]; then
    echo Cannot find ${_LABEL_N_SERVICE} docker containers
  fi
fi

}

function dockerimages() {
  docker images
}

function dockercontainer() {
  docker ps -a
}

export DOCKER_MACHINE_OPTS=
function _dtmachine() {
  local dtmachine=${1}
  if [ "$dtmachine" == "" ]; then
    dtmachine=${DOCKER_MACHINE_NAME}
  fi
  if [ "$dtmachine" == "" ]; then
    dtmachine=$(docker-machine ls -q | head -1)
  fi
  if [ "$dtmachine" == "" ]; then
    dtmachine=default
  fi
  echo $dtmachine
}
function dtrm() {
  local dtmachine=$(_dtmachine ${1})
  echo Removing Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
  docker-machine ${DOCKER_MACHINE_OPTS} rm $dtmachine
  echo Removing Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
}
function dtnew() {
  local dtmachine=$(_dtmachine ${1})
  local dtnewopts=
  if [ "$1" != "" ]; then
    shift
    dtnewopts=$*
  fi
  echo Creating Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
  #TWC docker-machine ${DOCKER_MACHINE_OPTS} create -d virtualbox --virtualbox-memory 3072 --virtualbox-disk-size 204800 --engine-insecure-registry images.ecofactor.com:5000 ${dtnewopts} $dtmachine
  docker-machine ${DOCKER_MACHINE_OPTS} create -d virtualbox --virtualbox-memory 2072 --virtualbox-disk-size 102400 ${dtnewopts} $dtmachine
  echo Created Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
  dtgo $dtmachine
}
function dtgo() {
  local dtmachine_old=${DOCKER_MACHINE_NAME}
  local dtmachine=$(_dtmachine ${1})
  local dtstat=$(docker-machine ${DOCKER_MACHINE_OPTS} status $dtmachine)
  if [ "$dtstat" != "" ]; then
    if [ "$dtstat" != "Running" ]; then
      echo Starting Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
      docker-machine ${DOCKER_MACHINE_OPTS} start $dtmachine
      echo Started Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
    fi
    if [ "$dtmachine" != "$dtmachine_old" ]; then
      echo Configuring environment for Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
    fi
    dtswarmmaster=$(docker-machine ${DOCKER_MACHINE_OPTS} inspect -f "{{ .Driver.SwarmMaster }}" $dtmachine)
    dtenvopts=
    if [ "$dtswarmmaster" == "true" ]; then
      dtenvopts=--swarm
    fi
    eval $(docker-machine ${DOCKER_MACHINE_OPTS} env $dtenvopts --shell=bash $dtmachine)
  else
    echo Cannot find any Docker VM called $(tput setaf 4)${dtmachine}$(tput sgr0)
  fi
}
# shortcut to stop docker toolbox vm
function dtstop() {
  local dtmachine=$(_dtmachine ${1})
  local dtstat=$(docker-machine ${DOCKER_MACHINE_OPTS} status $dtmachine)
  if [ "$dtstat" != "Stopped" ]; then
    echo Stopping Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) ...
    docker-machine ${DOCKER_MACHINE_OPTS} stop $dtmachine
    echo Stopped Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0)
  fi
}
# shortcut to upgrade docker toolbox vm memory
function dtsetmem() {
  local memsize=${1}
  local dtmachine=$(_dtmachine ${2})
  docker-machine stop $dtmachine
  VBoxManage modifyvm $dtmachine --memory $memsize
  docker-machine start $dtmachine
  docker-machine regenerate-certs $dtmachine
}
# shortcut to ssh into docker toolbox vm
function dtssh() {
  local dtmachine=$(_dtmachine ${1})
  _opentab "${dtmachine}" "docker-machine ${DOCKER_MACHINE_OPTS} ssh $dtmachine"
}
# shortcut to show the ip address of a docker toolbox vm
function dtip() {
  local dtmachine=$(_dtmachine ${1})
  echo IP address of Docker VM $(tput setaf 4)${dtmachine}$(tput sgr0) is:
  docker-machine ${DOCKER_MACHINE_OPTS} ip ${dtmachine}
}

# docker
# shortcut to show all containers
function dkps() {
  docker ps -a --format "table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.RunningFor}}" $* | (read -r; printf "%s\n" "$REPLY"; sort)
}
# shortcut to show all images
function dkim() {
  docker images $* | (read -r; printf "%s\n" "$REPLY"; sort)
}
# shortcut to list all containers and their ip addresses
function dkips() {
  declare -a arr=($(docker ps -a -q))
  echo "Container ID   IP Address     Container Name"
  echo "-------------- -------------- --------------"
  for container_id in "${arr[@]}"; do
    container_ip=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' ${container_id})
    if [ "${container_ip}" == "" ]; then
      container_ip="-"
    fi
    container_name=$(docker inspect --format='{{ .Name }}' ${container_id})
    printf "%-14s %-14s %s\n" ${container_id} ${container_ip} ${container_name}
  done
}
# shortcut to show all runtime statistics of containers
function dkst() {
  docker stats --no-stream $(docker ps --format "{{.Names}}" | sort)
}
# shortcut to show the ip address of a container
function dkip() {
  local dkcontainer=$1
  if [ "$dkcontainer" == "" ]; then
    dkcontainer=`docker ps -laq`
  fi
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo IP address of docker container $(tput setaf 4)${dkname}$(tput sgr0) is:
  docker inspect --format='{{ .NetworkSettings.IPAddress }}' ${dkcontainer}
}
# shortcut to show the exposed ports of a container
function dkport() {
  local dkcontainer=$1
  if [ "${dkcontainer}" == "" ] || [ "${dkcontainer:0:1}" == "-" ]; then
    dkcontainer=`docker ps -laq`
  else
    shift
  fi
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo Ports of docker container $(tput setaf 4)${dkname}$(tput sgr0) include:
  docker port ${dkcontainer} $*
}
# shortcut to show logs from a container
function dkl() {
  local opts=""
  while true; do
    if [ "${1}" == "-f" ]; then
      opts="$opts -f"
      shift
    elif [ "${1}" == "-s" ]; then
      opts="$opts --since=`date +%s`"
      shift
    elif [ "${1}" == "" ]; then
      dkcontainer=`docker ps -laq`
      break
    else
      dkcontainer=${1}
      shift
      break
    fi
  done
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo Logs from docker container $(tput setaf 4)${dkname}$(tput sgr0):
  docker logs ${opts} ${dkcontainer}
}
# shortcut to open an interactive shell in a container
function dksh() {
  local dkcontainer=$1
  if [ "${dkcontainer}" == "" ] || [ "${dkcontainer:0:1}" == "-" ]; then
    dkcontainer=`docker ps -laq`
  else
    shift
  fi
  local dkname=`docker inspect --format='{{ .Name }}' ${dkcontainer}`
  echo Interactive shell into docker container $(tput setaf 4)${dkname}$(tput sgr0):
  docker exec -t -i ${dkcontainer} /bin/bash
}
# shortcut to delete all dangling images
function dkrmi0() {
  local dkimages=$(docker images -f "dangling=true" -q)
  if [ "$dkimages" != "" ]; then
    docker rmi $* $dkimages
  fi
}
# shortcut to delete all exited containers
function dkrm0() {
  local dkcontainers=$(docker ps -a -q -f status=exited)
  if [ "$dkcontainers" != "" ]; then
    docker rm -v $* $dkcontainers
  fi
}
# shortcut to delete all containers
function dkclean() {
  docker ps -a -q | xargs -n 1 -I {} docker rm {}
}
function _dktags() {
  local dkimage=$1
  local dkurl=https://registry.hub.docker.com/v2/repositories/library/${dkimage}/tags/
  while [ "$dkurl" != "" ] && [ "$dkurl" != "null" ]; do
    >&2 echo "Querying $(tput setaf 4)$dkurl$(tput sgr0) ..."
    curl -s -S $dkurl | jq -M '."results"[]["name"]'
    dkurl=$(curl -s -S $dkurl | jq -j -M '."next"')
  done
}
function dktags() {
  local dkimage=$1
  local jqinstalled=$(which jq)
  if [ "$jqinstalled" == "" ]; then
    echo Installing jq ...
    brew install jq
  fi
  _dktags $dkimage | sort
}
# shortcut to save images
function dkims() {
  local images_dir=${1:-/tmp/images}
  mkdir -p ${images_dir}
  declare -a arr=($(docker images -q -f "label=n.env=dev" | sort | uniq))
  for image_id in "${arr[@]}"; do
    image_repo_and_tag=$(docker inspect --format='{{with .RepoTags}}{{index . 0}}{{end}}' ${image_id})
    rm -f ${images_dir}/${image_id}.tar
    docker save -o ${images_dir}/${image_id}.tar ${image_repo_and_tag}
    echo Saved image $(tput setaf 4)${image_repo_and_tag}$(tput sgr0) to $(tput setaf 4)${images_dir}/${image_id}.tar$(tput sgr0)
  done
}
# shortcut to load images
function dkiml() {
  local images_dir=${1:-/tmp/images}
  for image_tar in ${images_dir}/*.tar; do
    echo Loading image from $(tput setaf 4)${image_tar}$(tput sgr0) ...
    docker load -i $image_tar
  done
}