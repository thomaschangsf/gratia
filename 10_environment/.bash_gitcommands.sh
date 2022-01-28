#!/bin/sh

echo "      | .bash_gitcommands.sh [g*]"

source $devGitOpus/10_environment/git-completion.bash

# ------------------------------------------------------------------------
# Tool: Git
# ------------------------------------------------------------------------
alias gitIgnore='git config --global core.excludesfile ~/.gitignore_global'
# Add colors for git repo to your terminal
function git_branch {
  echo "git_branch"
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

alias gitPasswordToken='echo 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'

export GIT_DEFAULT_BRANCH=develop
# Shortcut to show git status
alias gs="git status"
# Shortcut to show git status as well as what is in the git stash stack
function gss() {
  git status
  echo ' '
  echo '# git stash list'
  git --no-pager stash list
}
# Shortcut to show git log with pretty format
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local"
# Shortcut to show git tags with pretty format
alias glt="git log --tags --no-walk --pretty=format:'%C(yellow)%h%Creset %Cred%D%Creset %Cgreen(%cd) %C(bold blue)<%an>%Creset' --date=local"
# Shortcut to do git add with -A option to also add those removals to staging index
alias ga="git add -v -A"
# Shortcut to do git commit with message
alias gc="git commit -m"
# Shortcut to do ammended git commit with message
alias gca="git commit --amend -m"
# Shortcut to do non-fast-forward git merge
alias gm="git merge --no-ff"
# Shortcut to do git pull
alias gpull="git pull"
# Shortcut to first stash working copy changes and do git pull and then pop and merge the stashed changes
function gpulls() {
  git stash clear
  git stash
  git pull
  git stash pop
  git stash clear
}

function gitPull() {
  # Pull from remote to local tracking branch
  git fetch origin ${1}

  # Rebase from local tracking branch to local working branch
  git rebase origin/${1}

  # Terminology: origin is an alias to a remote repository.  To see what it points to, 
  #   git remote show origin
}


# Shortcut to do git push to correct remote branch
function gpush() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  git push origin $gitbranch $*
}
# Shortcut to do set remote branch as upstream
function gbtrack() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  git branch --set-upstream-to=origin/$gitbranch $gitbranch $*
}
# Shortcut to do git diff and ignore whitespace differences
alias gdiff="git diff -w"
# Shortcut to do git diff on a specific commit against the previous commit
function gdiffc() {
  local gitcommit=$1
  shift
  git diff -w ${gitcommit}^1..${gitcommit} $*
}
# Shortcut to do git visual diff on a specific commit against the previous commit
function gvdiffc() {
  local gitcommit=$1
  # git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitcommit}^1..${gitcommit} 2> >(grep -v CoreText 1>&2)
  git difftool -d --no-symlinks -x "/usr/local/bin/bcomp" ${gitcommit}^1..${gitcommit}
}
# Shortcut to show list of git-ignored files in working directory
alias gignored="git ls-files -o -i --exclude-standard"
# Shortcut to show remote branch details
alias grso="git remote show origin | grep -v 'stale '"
# Shortcut to create new local branch to follow remote branch
function grb() {
  git fetch origin $1
  if [ $? -eq 0 ]; then
    git checkout -B $1 origin/$1
  fi
}
# Shortcut to switch current local branch based on search string
function gb() {
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
    searchstr=${GIT_DEFAULT_BRANCH}
  fi
  local newbranch=`git rev-parse --abbrev-ref --branches=${searchstr}* | head -1`
  if [ "$newbranch" == "" ] ; then
    newbranch=`git rev-parse --abbrev-ref --branches=*${searchstr}* | head -1`
  fi
  if [ "$newbranch" == "" ] ; then
    echo Cannot find branch ${searchstr}, switching to ${GIT_DEFAULT_BRANCH} instead
    git checkout ${GIT_DEFAULT_BRANCH}
  else
    git checkout $newbranch
  fi
}
# Shortcut to create new local branch from current local branch, and then push it as a new remote branch
function gbnew() {
  local newbranchname=${1}
  git checkout -b ${newbranchname}
  git push -u origin ${newbranchname}
  git branch --set-upstream-to=origin/$gitbranch ${newbranchname}
}
# Shortcut to list all local branches
alias gbv="git branch -v"
# Shortcut to list all remote branches
alias gbvr="git branch -r"
# Shortcut to use git difftool to compare current branch with another branch
function gbc() {
  local gitbranch=`git rev-parse --abbrev-ref HEAD`
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
    searchstr=${GIT_DEFAULT_BRANCH}
  fi
  local newbranch=`git rev-parse --abbrev-ref --branches=${searchstr}* | head -1`
  if [ "$newbranch" == "" ] ; then
    newbranch=`git rev-parse --abbrev-ref --branches=*${searchstr}* | head -1`
  fi
  if [ "$newbranch" == "" ] ; then
    echo Cannot find branch matching "*"${searchstr}"*"
  elif [ "${gitbranch}" == "${newbranch}" ] ; then
    echo Cannot compare ${gitbranch} branch to itself
  else
    echo Compare ${gitbranch}..${newbranch}
    #git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" ${gitbranch}..${newbranch} 2> >(grep -v CoreText 1>&2)
    #git difftool -d --no-symlinks -x "/Applications/PyCharm.app/Contents/MacOS/pycharm diff" ${gitbranch}..${newbranch}
    #git difftool -d --no-symlinks -x "/usr/local/bin/ksdiff" ${gitbranch}..${newbranch}
    git difftool -d --no-symlinks -x "/usr/local/bin/bcomp" ${gitbranch}..${newbranch}
  fi
}
function gvdiff() {
  # git difftool -d --no-symlinks -x "/Applications/DiffMerge.app/Contents/MacOS/DiffMerge" $* 2> >(grep -v CoreText 1>&2)
  git difftool -d --no-symlinks -x "/usr/local/bin/bcomp" $*
}

# git flow
# Shortcut to start new feature branch from current local branch using git flow
function gffnew() {
  local featurebranchname=${1}
  echo Start feature ${featurebranchname}
  git flow feature start ${featurebranchname}
}
# Shortcut to finish feature branch using git flow
function gffend() {
  local searchstr=${1}
  if [ "$searchstr" == "" ] ; then
    searchstr=`git rev-parse --abbrev-ref HEAD`
    if [ "${searchstr:0:8}" == "feature/" ] ; then
      searchstr=${searchstr:8}
    fi
  fi
  local foundbranch=`git rev-parse --abbrev-ref --branches=feature/*${searchstr}* | head -1`
  if [ "$foundbranch" == "" ] ; then
    echo Cannot find feature matching "*"${searchstr}"*"
  else
    echo Finish feature ${foundbranch:8}
    git flow feature finish ${foundbranch:8}
  fi
}
# Shortcut to publish a feature
function gffpub() {
  local searchstr=${1}
  local foundbranch=`git rev-parse --abbrev-ref --branches=feature/*${searchstr}* | head -1`
  if [ "$foundbranch" == "" ] ; then
    echo Cannot find feature matching "*"${searchstr}"*"
  else
    echo Publish feature ${foundbranch:8}
    git flow feature publish ${foundbranch:8}
  fi
}
# Shortcut to pull a feature
function gffget() {
  local featurebranchname=${1}
  echo Pull and track feature ${featurebranchname}
  git flow feature track ${featurebranchname}
}
# Shortcut to search a git commit based on a search string
function gcfind() {
  git show --name-only --oneline :/"$@"
}

function gitClearHistory() {
  #References: 
  # https://stackoverflow.com/questions/6403601/purging-file-from-git-repo-failed-unable-to-create-new-backup?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
  # https://stackoverflow.com/questions/19573031/cant-push-to-github-because-of-large-file-which-i-already-deleted
  # https://stackoverflow.com/questions/5798930/git-rm-cached-x-vs-git-reset-head-x?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

  git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch ${1}' HEAD
}

# gitBranchDeleteRemote origin/feature/mergeGoolgeAssistant3IntoDevBranch
alias gitBranchDeleteRemote="gitBranchDeleteRemote"
function gitBranchDeleteRemote() {
 git push origin --delete ${1}
}
