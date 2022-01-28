# .bash_profile file
# By Balaji S. Srinivasan (balajis@stanford.edu)
#
# Concepts:
# http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html
#
#    1) .bashrc is the *non-login* config for bash, run in scripts and after
#        first connection.
#
#    2) .bash_profile is the *login* config for bash, launched upon first
#        connection (in Ubuntu)
#
#    3) .bash_profile imports .bashrc in our script, but not vice versa.
#
#    4) .bashrc imports .bashrc_custom in our script, which can be used to
#        override variables specified here.
#
# When using GNU screen:
#
#    1) .bash_profile is loaded the first time you login, and should be used
#       only for paths and environmental settings

#    2) .bashrc is loaded in each subsequent screen, and should be used for
#       aliases and things like writing to .bash_eternal_history (see below)
#
# Do 'man bashrc' for the long version or see here:
# http://en.wikipedia.org/wiki/Bash#Startup_scripts
#
# When Bash starts, it executes the commands in a variety of different scripts.
#
#   1) When Bash is invoked as an interactive login shell, it first reads
#      and executes commands from the file /etc/profile, if that file
#      exists. After reading that file, it looks for ~/.bash_profile,
#      ~/.bash_login, and ~/.profile, in that order, and reads and executes
#      commands from the first one that exists and is readable.
#
#   2) When a login shell exits, Bash reads and executes commands from the
#      file ~/.bash_logout, if it exists.
#
#   3) When an interactive shell that is not a login shell is started
#      (e.g. a GNU screen session), Bash reads and executes commands from
#      ~/.bashrc, if that file exists. This may be inhibited by using the
#      --norc option. The --rcfile file option will force Bash to read and
#      execute commands from file instead of ~/.bashrc.

## -----------------------
## -- 1) Import .bashrc --
## -----------------------
export OPUS_DIR="/Users/$USER/Documents/dev/git/opus"

echo ""
echo "Running $OPUS_DIR/10_environment/.bash_profile"

alias srcs='source $OPUS_DIR/10_environment/.bash_profile'

# Setup on new instance to use mltools.git !!! TWC: :
alias srcsWithBashProfile="cp $OPUS_DIR/10_environment/.bash_profile ~/.bash_profile && srcs"

# Factor out all repeated profile initialization into .bashrc
#  - All non-login shell parameters go there
#  - All declarations repeated for each screen session go there
#TWC: I am replacing bashrc with mltools.git if [ -f ~/.bashrc ]; then
#   source ~/.bashrc
#fi



if [ -f $OPUS_DIR/10_environment/.bashrc ]; then
   source $OPUS_DIR/10_environment/.bashrc
else
   source ~/.bashrc
fi

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi


# Configure PATH
#  - These are line by line so that you can kill one without affecting the others.
#  - Lowest priority first, highest priority last.
export PATH=$PATH
export PATH=$HOME/bin:$PATH
export PATH=/usr/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH


#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
#eval "$(rbenv init -)"


if ! command -v brew &> /dev/null
then
    echo 'brew cannot be found'
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.bash_profile
    eval $(/opt/homebrew/bin/brew shellenv)
fi



export PATH="/usr/local/opt/elasticsearch@2.4/bin:$PATH"
export PATH="/usr/local/opt/node@8/bin:$PATH"

export PATH="/usr/local/opt/sphinx-doc/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"


function git_branch {
  echo "git_branch"
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
PS1='\[\033[0;37m\][\[\033[01;36m\]\W\[\033[0;37m\]] \[\033[0;32m\]$(git_branch)\[\033[00m\]\$ '
