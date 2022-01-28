#!/bin/sh

# kc
# Since we rely on namespaces for environment, all kubectl commands must specify --namespace $env.
# To alleviate this extra verbosity, use an alias and a default KUBE_NAMESPACE

echo "      | .bash_terminal_cmds.sh. [tm*]"

# ------------------------------------------------------------------------
# Tools: General
# ------------------------------------------------------------------------
function subl () {
  if [ -f /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl ]; then
    /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl
  else
    /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl
  fi
}

alias shellReset="exec $SHELL && srcs"

# Set defalut shell as bash
alias tmShellBash='chsh -s /bin/bash && echo $SHELL'
alias tmShellZsh='chsh -s /bin/zsh && echo $SHELL'

function sshRestartServer() {
  pkill ssh  
  sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
  sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
}

#json pretty print: tJsonPrint '{"k1": "v1"}'
function tmJsonPrint() {
  echo $1 | python -m json.tool
}

#Kill processing matching pattern. Ex: tkill redis
function tmProcesskillByName() {
  ps aux | grep $1 | awk '{print $2}' | xargs kill
}

# tmProcessOnPortList 5000
function tmProcessListOnPort() {
  lsof -t -i tcp:$1
}

# tmProcessKillOnPort 5000
function tmProcessKillOnPort() {
  lsof -t -i tcp:$1 | xargs kill
}


#Return the ip address of the computers
function tmIpAddress() {
  curl ifconfig\.me/ip
}

#Find intersection of 2 files
function tmFileIntersection() {
  cat $1 $2 | sort | uniq -d
}

#Find union of 2 files
function tmFileUnion() {
  cat $1 $2 | sort | uniq
}

#Find difference of 2 files: first - second
alias tmFileDiff="tFileUnion "
function tFileUnion() {
  cat $1 $2 $2 | sort | uniq -u
}

function tmFileNumHandles() {
  lsof | awk '{print $1}' | uniq -c | sort -rn | head
}

# LInux command to split a large file into multiple parts
# Example: linuxSplitFile [inputFileName]           [sizeOfEachSubFile] [outputFileName]            [outputFileExtension]
#                         latest-all_updated.json   50G                 latest-all-updated-split-   .json
# OR BY RAW COMMAND
#   split --bytes 100M --numeric-suffixes --suffix-length=3 part-orig kg-split-
function tmFileSplit() {
  #split --bytes 50G --numeric-suffixes --suffix-length=3 --additional-suffix=.json latest-all_updated.json latest-all-updated-split-
  split --bytes ${2} --numeric-suffixes --suffix-length=3 --additional-suffix=${4} ${1} ${3}
}

# linuxSplitFileOnMac orig.txt orig-split.txt. 100m|k
# To merge the split files, cat YourFile.iso.* > YourFile.iso
function tmFiileSplitOnMac() {
  # split -b 10k original.txt original-split.txt.
  split -b ${3} ${1} ${2}
}

# Linux command to merge multiple files in a directory into one file
# Example: tmfileMerge tmp/* finalOutput.txt
function tmFileMerge() {
  cat ${1} > ${2}
}

#Use this as an example to sum the 5th column
function tmSumExample() {
  ls -hl *.txt | awk '{ SUM += $5 } END {print SUM/1024 }'
}

# Use this to find the account Id counts: tLookForAccntId fruits.txt purplestuff.txt
function tmLookForAccntId() {
  cat $@| egrep -o '[0-9]+' | cut -d= -f2| sort | uniq -c | sort -rn
}

#alias ll="ls -lFGh"
alias la="ls -aFGh"
function llHeader() {
  local VAR="Permissions|Group|Size|Modified|Name"

  echo -e "$VAR" | column -t -s"|" && ls -lh "${1}"
}

function tmTimeUtce {
  local input=${1}
  if [ "${input}" == "" ] ; then
    input=0
  fi
  local val=${input}
  if [ "${val}" -gt 9999999999 ]; then
    val=`expr ${val} / 1000`
  fi
  local result_utc=`date -u -r ${val}`
  local result=`date -r ${val}`
  echo ""
  echo "From: ${input}"
  echo "  UTC: ${result_utc}"
  echo "  Current TZ: ${result}"
  echo ""
}
function tmTimeUtcNow {
  local result_utc=`date -u`
  local result=`date +%s`
  local result_local=`date`
  echo ""
  echo "Time: Now"
  echo "  Local: ${result_local}"
  echo "  UTC: ${result_utc}"
  echo "  Seconds: ${result}"
  echo "  Milliseconds: ${result}000"
  echo ""
}

# temperature conversion
function tmTempCels2Fah() {
  local c0=$1
  f0=`expr ${c0} \* 9`
  f0=`expr ${f0} / 500`
  f0=`expr ${f0} + 32`
  echo ${f0}
}
function tmTempFah2Cel() {
  local f0=$1
  c0=`expr ${f0} - 32`
  c0=`expr ${c0} \* 500`
  c0=`expr ${c0} / 9`
  echo ${c0}
}

# tmTarDir WordNet-3.0
function tmTarDir() {
  # To get maximum compression: env GZIP=-9 tar cvzf wnjpn.tar.gz  wnjpn.db
  tar -czf ${1}.tar.gz ${1}/

}

# linuxUntar WordNet-3.0.tar.gz
function tmUntar() {
  tar -xzf ${1}
}

# if see 0, then ok
function tmCmdExist() {
  # pipe the response to the dev null device (ie blackhole), and pipe stderr(2) to stdout(1)
  command -v $1 > /dev/null 2>&1
}


