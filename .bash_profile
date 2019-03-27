#!/bin/sh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

case $- in
    *i*)    # interactive shell
    ;;
    *)      # non-interactive shell
    return
    ;;
esac

# Don't use ^D to exit
set -o ignoreeof

# turn on vi editing command line
set -o vi

# turn on minor directory spellchecking for `cd`
shopt -s cdspell

# Don't put duplicate lines in the history.
export HISTCONTROL=ignoredups

# huge hist files aren't a problem
export HISTFILESIZE=100000

# and huge history lists are very useful
export HISTSIZE=100000

# nearly nothing I work on has ever fit in the default of 64m, so embiggen this
#export MAVEN_OPTS=-Xmx512m

## Automatically pushd - then I can go to an old dir with cd - <tab> (pick no.)
#setopt AUTOPUSHD           # this doesn't work in cygwin/bash....
#export DIRSTACKSIZE=11     # stack size of eleven gives me a list with ten entries

##############################################################
#                      Aliases
##############################################################
alias ~="cd /Users/`whoami`"
alias ..='cd ..' >/dev/null
alias ....='cd ../..'
alias ......='cd ../../..'
alias ........='cd ../../../..'
alias l='ls -hG'
alias la='ls -haG'
alias ll='ls -hlG'
alias lla='ls -hlaG'
alias rebash='source ~/.bash_profile'
alias ssh='ssh -q'
alias screen='screen -DR'
alias dynago="cd /Users/`whoami`/apps/dynamo && java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb"
alias gimmae='for remote in `git branch -r | grep -v HEAD | grep -v master`; do git branch --track ${remote#origin/} $remote; done'
alias GIMMAE='for repo in `ls -d ./*/`; do cd $repo; git pull; gimmae; cd ..; done'
alias foff='sudo /opt/cisco/anyconnect/bin/acwebsecagent -disablesvc -websecurity'
alias splle="vi /Users/`whoami`/Library/Spelling/LocalDictionary"

# Use these to prevent host employer .gitconfig from contaminating personal repo
alias ungit="ln -fs ~/.cynoclast.gitconfig ~/.gitconfig"
alias regit="ln -fs  ~/.nike.gitconfig ~/.gitconfig"


#  misspellings
alias exti="exit"
alias mroe="less"

##############################################################
#             Environment specific settings
##############################################################


case "`uname`" in

    CYGWIN*)

        #Just windows things.
        shortcutfix() {
          find . -name "*.exe - Shortcut.lnk" | while read -r file; do mv "${file}" "$(echo ${file} | sed 's/.exe\ -\ Shortcut.lnk/.lnk/')"; done
        }

        # Cygwin specific stuff goes here
        JAVA_HOME=`cygpath "${JAVA_HOME}"` 2>/dev/null 2>&2


        PATH="$PATH:${JAVA_HOME}/bin:~/bin"
        alias ls='ls -Fph --color=tty --group-directories-first '


        # flowers?
        function flowers() {
            let "flowers = $RANDOM % 25";
            echo -en "\nI should"; if [[ ${flowers} != 0 ]]; then echo -n " not";fi;echo -e " buy flowers today.\n\n"
        }

        #flowers

        # if fortune is installed
        if [ `which fortune 2>/dev/null` ]; then
          # run it
          fortune
        fi

        # Host-specific cygwin settings
        case "`uname -n`" in
            Proteus)
              # nada
              #alias dropbox='cd ~/Dropbox'
            ;;

      # Work machine(s)
            workhost|workhost.*)

                alias g='cd /cygdrive/c/devel'
                alias svnstatus="svn status | grep -v \"^\?\""

            ;;
        esac
    ;;

    Linux*)

      alias ls='ls -Fph --color=tty '

      #allow tab completion in the middle of a word
      #setopt COMPLETE_IN_WORD   # this doesn't work in cygwin/bash....

      # Host specific Linux settings

      case "`uname -n`" in

            somehost*)

                export PATH=$PATH:/home/tk37823/bin
                export P4PORT="hostname.tld:1666"
            ;;

            *)
              # unknown host, path only
              PATH=$PATH:~/bin
            ;;

      esac
  ;;

    # OS X
    Darwin*)

        alias gradle="./gradlew"
        alias tm="java -classpath /Users/`whoami`/apps/time.jar com.cynoclast.time.Time"

        export M2_HOME="/Users/`whoami`/.m2"

        #Makes gradle be able to use maven settings.xml and reach artifactory
        export SA_U="maven"

        if [[ -z ${JAVA_HOME+x} ]]; then : ; else export PATH=$PATH:$JAVA_HOME/bin; fi

        [[ "`whoami`" != "root" ]]; export PATH="$PATH:/home/`whoami`/bin"

        complete -C '/usr/local/aws/bin/aws_completer' aws

        export GRADLE_OPTS="-Dorg.gradle.daemon=false -XX:MaxHeapSize=512m -Xmx1024m"

        PATH=$PATH:~/apps:~/apps/squid_toolkit

        # sets javahome
        # tells you what it set it to
        # prints the version
        jhome () {
         export JAVA_HOME=`/usr/libexec/java_home $@`
         echo "JAVA_HOME:" ${JAVA_HOME}
         java -version
        }

        # Renames the OSX box
        # $1 = new hostname
        renamehost () {
            if [[ ! -z "$1" ]] ; then
                sudo scutil --set HostName $1 && \
                sudo scutil --set LocalHostName $1 && \
                sudo scutil --set ComputerName $1 && \
                dscacheutil -flushcache && \
                echo "Host renamed. Reboot for it to take full effect."
            else
                echo "Need a hostname to give this host."
                return 1
            fi
        }

        # Makes a prompt that looks something like this:
        #   ~/home 01:56 PM
        #   [ 317 ] luser@host $
        #
        # And like this if you're on a git branch (in below example, branch is "test"):
        #
        #   ~/home (test) 01:56 PM
        #   [ 317 ] luser@host $
        #
        #   [ 317 ] <- is the command number of the current command
        #
        # The backslash-fest inline command below causes it to look like this if you're on master:
        #   ~/home ((( MASTER ))) 01:56 PM
        #   [ 318 ] luser@host $
        #
        # The "((( MASTER )))" bit is also red, and bold.
        #
        function colorMyPrompt {

            local RED="\[\033[0;31m\]"
            local YELLOW="\[\033[0;33m\]"
            local GREEN="\[\033[0;32m\]"
            local TEAL="\[\033[0;36m\]"
            local BLUE="\[\033[0;34m\]"
            local PURPLE="\[\033[0;35m\]"
            local LIGHT_GRAY="\[\033[0;37m\]"
            local DARK_GRAY="\[\033[0;30m\]"

            local BOLD_RED="\[\033[1;31m\]"
            local BOLD_YELLOW="\[\033[1;33m\]"
            local BOLD_GREEN="\[\033[1;32m\]"
            local BOLD_TEAL="\[\033[1;36m\]"
            local BOLD_BLUE="\[\033[1;34m\]"
            local BOLD_PURPLE="\[\033[1;35m\]"
            local BOLD_LIGHT_GRAY="\[\033[1;37m\]"
            local BOLD_DARK_GRAY="\[\033[1;30m\]"

            local NO_COLOR="\[\033[0m\]"

            # escaped - not directly useful, but the correct number of backslashes are recorded here
            # local YELLOW_BACKGROUND="\\\\\[\\\\\033[43m\\\\\]"
            # local DARK_GREY_BACKGROUND="\\\\\[\\\\\033[40m\\\\\]"

            local workingDirectory="$BOLD_YELLOW\w"
            local currentGitBranch='`git branch 2> /dev/null | grep -e ^[*] | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\/ | sed -E s/[\(]master[\)]/\\\\\[\\\\\033[01\;31m\\\\\]\\(\(\(\ MASTER\ \\\\)\)\)/`'
            local historyBlock="$BOLD_RED[ $BOLD_LIGHT_GRAY\! $BOLD_RED]"
            local timeBlock="$BOLD_LIGHT_GRAY\@"
            local userAndHost="$BOLD_TEAL\u$BOLD_GREEN@$BOLD_BLUE\h"
            local promptTail="$BOLD_LIGHT_GRAY\$"

            # BOLD_LIGHT_GRAY is overridden in the above currentGitBranch command above when on master
            export PS1="$workingDirectory $BOLD_LIGHT_GRAY$currentGitBranch $timeBlock\n $historyBlock $userAndHost $promptTail$NO_COLOR "
        }
        colorMyPrompt
esac

#--------------------------------------------------
#    Initializes informative and pretty prompts (old)
#--------------------------------------------------
function setprompt {

    #define the colors
    local    BLUE="\[\033[1;34m\]"
    local    LIGHT_GRAY="\[\033[0;37m\]"
    local    DARK_GRAY="\[\033[1;30m\]"
    local    RED="\[\033[1;31m\]"
    local    BOLD_WHITE="\[\033[1;37m\]"
    local    NO_COLOR="\[\033[0m\]"

    # The prompt will look something like this:
    #[ 9287 ][ ~ ]
    # [luser@host] $

    # since the shell windows on some systems are white, and some are black, some of the colors need tweaking
    case "`uname`" in

        CYGWIN* | Linux*)
            # black background
            historyBlock="${BLUE}[ ${LIGHT_GRAY}\!${BLUE} ]"
            pathBlock="${BLUE}[ ${RED}\w${BLUE} ]"
            userHostBlock="${BLUE}[${RED}\u${LIGHT_GRAY}"@"${RED}\h${BLUE}]"
            #promptChar="$BOLD_WHITE\$$LIGHT_GRAY"
            promptChar="${BOLD_WHITE}\$${NO_COLOR}"

            ps2arrow="${BLUE}-${BOLD_WHITE}> ${NO_COLOR}"
        ;;

        # something-with-a-white-background)
            # BOLD_WHITE background
            #historyBlock="$BLUE[ $DARK_GRAY\!$BLUE ]"
            #pathBlock="$BLUE[ $RED\w$BLUE ]"
            #userHostBlock="$BLUE[$RED\u$DARK_GRAY"@"$RED\h$BLUE]"
            #promptChar="$DARK_GRAY\$$NO_COLOR"

            #ps2arrow="$BLUE-$DARK_GRAY> $NO_COLOR"
        #;;

        *)
            unameString=`uname`
            echo "Unknown environment detected, not setting pretty prompt.  Edit .bashrc to account for ${unameString}."
            return
        ;;

    esac

    # prompt structure
    PS1="\n${historyBlock}${pathBlock}\n ${userHostBlock} ${promptChar} "
    PS2="${ps2arrow}"
}

#--------------------------------------------------
#    Extracts most files, mostly
#--------------------------------------------------

extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xjf $1    ;;
      *.tar.gz)   tar xzf $1    ;;
      *.bz2)      bunzip2 $1    ;;
      *.rar)      rar x $1      ;;
      *.gz)       gunzip $1     ;;
      *.tar)      tar xf $1     ;;
      *.tbz2)     tar xjf $1    ;;
      *.tgz)      tar xzf $1    ;;
      *.zip)      unzip $1      ;;
      *.Z)        uncompress $1 ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

#--------------------------------------------------
#    Greps ps -e for you
#--------------------------------------------------

psg() {
  if [ ! -z "$1" ] ; then
    ps aux | grep -i "$1" | grep -v grep
  else
    echo "Need a process name to grep processes for"
  fi
}

#--------------------------------------------------
#    Greps history
#--------------------------------------------------

histg() {
  if [ ! -z "$1" ] ; then
    history | grep "$1" | grep -v histg
  else
    echo "Need a command to grep history for"
  fi
}

# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
cd_func () {
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

alias cd='cd_func'


[[ -s "/Users/`whoami`/.gvm/scripts/gvm" ]] && source "/Users/`whoami`/.gvm/scripts/gvm"
