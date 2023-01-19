#!/bin/sh

# FLOW: (triggered by srcs | shellResult | new terminal)
#   source bash_profile.sh
#     ~/.bashrc
#         /Users/thchang/Documents/dev/git/ml-tools/tools/environment/.bash_aliases

if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi


echo "    | .bash_aliases.sh"
source $OPUS_DIR/10_environment/.bash_env_vars.sh
source $OPUS_DIR/10_environment/.bash_terminal_cmds.sh
source $OPUS_DIR/10_environment/.bash_databases.sh
source $OPUS_DIR/10_environment/.bash_docker.sh
source $OPUS_DIR/10_environment/.bash_googlecloud.sh
source $OPUS_DIR/10_environment/.bash_gitcommands.sh
source $OPUS_DIR/10_environment/.bash_datapipeline.sh
source $OPUS_DIR/10_environment/.bash_ebay_k8.sh
#source $OPUS_DIR/10_environment/.bash_ebay_compute.sh
#source $OPUS_DIR/10_environment/.bash_ebay_nlp.sh



# ------------------------------------------------------------------------
# Scala & SBT
# ------------------------------------------------------------------------
export SBT_HOME=/usr/local/bin/sbt
export SCALA_HOME=/usr/local/bin/scala
export PATH=${PATH}:${SCALA_HOME}/bin
alias sbtca='sbt clean assembly'
alias sbtVersion='sbt sbtVersion'
alias sbtLog='cd ~/.sbt/boot/'
alias sbtCPA="sbt clean package assembly"
alias scalaUse210='brew unlink scala && brew unlink scala210 && brew link scala210 --force' 
alias scalaUse211='brew unlink scala && brew unlink scala210 && brew link scala'
function sbtTestCoverage() {
  sbt clean coverage test coverageReport
  pushd target/scala-2.11/scoverage-report
  open .
  popd
}
function sbtDependencyTree() {
  # Assumes project/plugins.sbt has:
  # addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "0.8.2")
  sbt dependency-tree
}
function sbtScalastyle() {
  # Assumes project/plugins.sbt has:
  # Assumes build.sbt has a scala.config reference  
  sbt scalastyle
}
function sbtRemoteDebug() {
  # Dependency steps: Instruction in Task-GuidedSearchV2
  # Look for: Bot svc: Setup instruction Here
  #
  # ngrok http 9000
  #   https://59aff308.ngrok.io/
  # 
  # bot-svc dependency services
  #   kSetEnvN1ShopBotNonProd
  #   kndev
  #   kubectl proxy --port 8005   
  # 
  # aio-svc local
  #   kSetEnvN1ShopBotNonProd
  #   kndev
  #   aioStartSbt
  #
  # SciMon
  # kSetEnvN1ShopBotNonProd
  #   kSetEnvN1ShopBotNonProd
  #   export KUBE_NAMESPACE=services-test
  #     kubectl proxy --port 8002   
  
  cd $HOME/Documents/dev/git/fork/bot-svc
  sbt -jvm-debug 9999 run -Dconfig.file=conf/application.tom.conf
}


# ------------------------------------------------------------------------
# Java & Maven
# ------------------------------------------------------------------------
# How to add New Java Versions
#   Install on Mac: brew install AdoptOpenJDK/openjdk/adoptopenjdk8
#   Add to jenv: 
#     List available versions on mac: /usr/libexec/java_home -V
#     jenv add  /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
#   List jenv versions avaialble
#     jenv versions
#   Switch java versions
#     jenv global openjdk64-11.0.11, openjdk64-1.8.0.292, oracle64-17.0.2
#     restart terminal: srcs
alias sdkInit='source /Users/chang/.sdkman/bin/sdkman-init.sh'

# One time setup
# sdk install java 8.0.322-zulu
# sdk install java 11.0.14-zulu
# sdk install sbt
# sdk install spark

alias javaSetJDK8='sdk default java 8.0.322-zulu'  # will update JAVA_HOME
alias javaSetJDK11='sdk default java 11.0.14-zulu' # will update JAVA_HOME
alias sparkSetVersion='sdk default spark 3.3.1'

alias javaVersionsAvailableOnMac='/usr/libexec/java_home -V'
#alias javaVersionsAvailableOnJenv='jenv versions'
#alias javaSetJdk8='jenv global openjdk64-1.8.0.292 && srcs'
#alias javaSetJdk11='jenv global openjdk64-11.0.11 && srcs'
#alias javaSetJdk17='jenv global openjdk64-17.0.2 && srcs'
#alias javaVersionActiveOnMac='java -version'

export MVN_HOME=/usr/local/Cellar/maven/3.6.3_1
export MAVEN_OPTS="-client -Duser.timezone=Etc/UTC -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss -Xmx512m -XX:MaxPermSize=256m"
alias mvn='${MVN_HOME}/bin/mvn'
alias mci='mvn  -U clean install -DskipTests=true'
alias mi='mvn -U install -DskipTests=true'
alias mit='mvn install -Pit'





# ------------------------------------------------------------------------
# Python & ML Frameworks
# Python & ML Frameworks
#   Refer to ml-tools.git/tools/notes: tool-poetry.txt tool-python.txt
#   Refer to nlpPyBaySetEnvOnMac command in .bash_ebay_nlp.sh
# ------------------------------------------------------------------------
# Python on Mac is a mess!!!:
#   brew vs defchang
#   lt vs pyenv
#   https://opensource.com/article/19/5/python-3-default-mac

# BREW - I removed all references in my ebay mac
# brew list / brew rm
# brew info python@3.7
# export PATH="/usr/local/opt/python@3.7/bin:$PATH" #sets python/pip to 3.7 for brew
# export PKG_CONFIG_PATH="/usr/local/opt/python@3.7/lib/pkgconfig"
# export LDFLAGS="-L/usr/local/opt/python@3.7/lib"
# export PKG_CONFIG_PATH="/usr/local/opt/python@3.7/lib/pkgconfig"

# PYENV- use pyenv to set default python to use pyenv version
# setup:
#   brew update && brew install pyenv
#   pyenv version
#   pyenv global 3.7
# to set global version, modify vi /Users/chang/.pyenv/version
#   pyenv local 3.7
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# This will tell pyenv to use the python version set by "pyenv local | global"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
export PATH=$(pyenv root)/shims:$PATH

alias python=$(pyenv which python3) # default to python3
alias python3=$(pyenv which python3)

alias pipV="$(pyenv which pip3)" # Pip I am using seems to be from: curl https://bootstrap.pypa.io/get-pip.py | python
alias pip3V="$(pyenv which pip3)"
alias pythonDepTree=pipdeptree

# ocassinally need to update pip for mac
# https://stackoverflow.com/questions/49748063/pip-install-fails-for-every-package-could-not-find-a-version-that-satisfies/49748494#49748494
# curl https://bootstrap.pypa.io/get-pip.py | python
# pip install --upgrade setuptools
# Side: ~/.pip/pip.conf dictates where to look for repo. Each venv has its own pip.conf

export POETRY_VENV="$HOME/Library/Caches/pypoetry/virtualenvs/"
function poetrySetEnvPyBay() {
  pushd $HOME/Documents/dev/git/nlp/pybay/pybay_env
  poetry shell
  poetry env use $POETRY_VENV/pynlp-test-6Qum585p-py3.6/bin/python3
  pip config set --site global.index-url https://artifactory.corp.ebay.com/artifactory/api/pypi/pypi-pynlp/simple
  pip config set --site global.extra-index-url https://pypi.org/simple
  popd
}


function poetrySetEnvMlToolsMacEbay() {
  pushd $OPUS_DIR
  poetry env use $POETRY_VENV/ml-tools-DlOOqhtV-py3.7/bin/python3

  __instruction="
    Copy and paste following commands:
      source 10_environment/.bash_env_vars.sh
      source 10_environment/.bash_terminal_cmds.sh
      source 10_environment/.bash_databases.sh
      source 10_environment/.bash_docker.sh
      source 10_environment/.bash_googlecloud.sh
      source 10_environment/.bash_gitcommands.sh
      source 10_environment/.bash_datapipeline.sh
      source 10_environment/.bash_ebay_k8.sh
      source 10_environment/.bash_ebay_compute.sh
      source 10_environment/.bash_ebay_nlp.sh

    Test:
      python -c 'import pandas'
  "
  echo "$__instruction"

  # Poetry shell wipes out bash-profile https://github.com/python-poetry/poetry/issues/1919
  # In particular, the PS1 variable crashes; probably because poetry shell is not a login shell
  poetry shell



}

#function poetrySetEnvMlToolsMacHome() {
#  pushd $HOME/Documents/dev/git/opus
#  poetry env use $POETRY_VENV/ml-tools-VlfKbyK0-py3.7/bin/python3
#  poetry shell
#  popd
#}


alias fastText="$HOME/Documents/dev/git/fastText/fastText"

function tfVenvActivate() {
  #sudo virtualenv --system-site-packages $HOME/virtualenv/tensorflow
  # Might need to do this: sudo pip install --upgrade tensorflow
  source $HOME/virtualenv/tensorflow/bin/activate
}

function tfVenvDeactivate() {
  deactivate
}

alias tfVersion="tfVersion"
function tfVersion() {
  python -c 'import tensorflow as tf; print(tf.__version__)'
}








###################################################################################
# echo environment variables
###################################################################################
sdkInit
echo " "
echo "    JAVA_HOME=${JAVA_HOME}" # javaSetJDK11
echo "    SBT_HOME=${SBT_HOME}"   # sparkSetVersion
echo "    SPARK_HOME=${SPARK_HOME}"
echo "    PYTHON_VERSION=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
#echo "    PYTHON_VERSION=$(python -V 2>&1)"
echo " "
