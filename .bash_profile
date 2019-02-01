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

# I can vi, so use it for SVN commit messages
export SVN_EDITOR=/usr/bin/vi

## Automatically pushd - then I can go to an old dir with cd - <tab> (pick no.)
#setopt AUTOPUSHD           # this doesn't work in cygwin/bash....
#export DIRSTACKSIZE=11     # stack size of eleven gives me a list with ten entries

##############################################################
#                      Aliases
##############################################################
alias ~='cd /Users/tkirk'
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
alias dynago='cd /Users/tkirk/apps/dynamo && java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb'
#alias gimmae='git branch -r | grep -v "\->" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done'
alias gimmae='for remote in `git branch -r | grep -v HEAD | grep -v master`; do git branch --track ${remote#origin/} $remote; done'
alias foff='sudo /opt/cisco/anyconnect/bin/acwebsecagent -disablesvc -websecurity'
alias splle='vi /Users/tkirk/Library/Spelling/LocalDictionary'


#  misspellings
alias exti="exit"
alias mroe="less"

##############################################################
#             Environment specific settings
##############################################################


case "`uname`" in

    CYGWIN*)
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

            tkirk)
              # Linux specific stuff goes here
              export JDK_HOME=~/apps/jdks/jdk
              export JAVA_HOME=${JDK_HOME}

              # this seems to make IntelliJ IDEA crash on startup so it's commented out:
              # export AWT_TOOLKIT="MToolkit"

              export PATH="${JAVA_HOME}/bin:$PATH:/home/tkirk/bin"
              export CLASSPATH=/home/tkirk/apps/tomcat/common/lib/jsp-api.jar:/home/tkirk/apps/tomcat/common/lib/servlet-api.jar
            ;;


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

    Darwin*)

        export M2_HOME=/Users/tkirk/apps/maven

        export PATH=$PATH:/Users/tkirk/bin:$M2_HOME/bin:$JMETER_HOME/bin:$MEMCACHED_HOME/bin:$JAVA_HOME/bin:/Users/tkirk/src/phylord/tools/triceracop

        function color_my_prompt {

            local    BLUE="\[\033[1;34m\]"
            local    LIGHT_GRAY="\[\033[0;37m\]"

            historyBlock="${BLUE}[ ${LIGHT_GRAY}\!${BLUE} ]"


            local __user_and_host="\[\033[01;32m\]\u@\h"
            local __cur_location="\[\033[01;34m\]\w"
            # local __git_branch_color="\[\033[31m\]"
            local __git_branch_color="\[\033[0;37m\]"
            #local __git_branch="\`ruby -e \"print (%x{git branch 2> /dev/null}.grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`"
            local __git_branch='`git branch 2> /dev/null | grep -e ^.* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
            # local __prompt_tail="\[\033[35m\]$"
            local __prompt_tail="\[\033[1;37m\]$"
            local __last_color="\[\033[00m\]"
            # export PS1="$__user_and_host $__cur_location $__git_branch_color$__git_branch$__prompt_tail$__last_color "
            export PS1="$__cur_location $__git_branch_color$__git_branch\n $historyBlock $__user_and_host $__prompt_tail$__last_color "

        }
        color_my_prompt
esac

###################################################
# My implementation of a TODO thingy stolen from http://blog.jerodsanto.net/2010/12/minimally-awesome-todos/
# Includes support to sync with subversion repository
###################################################
export TODO_FILE=~/.todo

function todo {
  if [ $# == "0" ]; then
    cat "${TODO_FILE}";
  else
    svn up "${TODO_FILE}"
    echo "â¢ $*" >> "${TODO_FILE}";
    svn ci "${TODO_FILE}" -m "todo autoupdate"
  fi
}

function todone {
    svn up "${TODO_FILE}"
    sed -i -e "/$*/d" "${TODO_FILE}";
    svn ci "${TODO_FILE}" -m "todo autoupdate"
}


###################################################
#  Functions
###################################################

shortcutfix() {
  find . -name "*.exe - Shortcut.lnk" | while read -r file; do mv "${file}" "$(echo ${file} | sed 's/.exe\ -\ Shortcut.lnk/.lnk/')"; done
}


function alldo {
   command=${@}
   exec $command
}
#--------------------------------------------------
#    Initializes informative and pretty prompts
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

#--------------------------------------------------
#    Look up a definition - beta
#--------------------------------------------------

define () {
  lynx -dump "http://www.google.com/search?hl=en&q=define%3A+${1}&btnG=Google+Search" | grep -m 5 -w "*"  | sed 's/;/ -/g' | cut -d- -f5 > /tmp/templookup.txt
              if [[ -s  /tmp/templookup.txt ]] ;then
                  until ! read response
                      do
                      echo "${response}"
                      done < /tmp/templookup.txt
                  else
                      echo "Sorry ${USER}, I can't find the term \"${1} \""
              fi
  rm -f /tmp/templookup.txt
}
#--------------------------------------------------
#    Look up a definition - without writing to the disk - alpha
#--------------------------------------------------

define2 () {
  outputOn=1

  lynx -dump "http://www.google.com/search?hl=en&q=define%3A+${1}&btnG=Google+Search" | while read line; do
    isDefinitionLine=$(echo ${line} | grep -q "\*")
    isUrlLine=$(echo ${line} | grep -q "\[")


    if [ ${isDefinitionLine} ]; then
      outputOn=0
    elif [ ${isUrlLine} ]; then
      outputOn=1
    fi

    if [ ${outputOn} ]; then
      echo "${line}"
    fi
  done

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

jhome () {
 export JAVA_HOME=`/usr/libexec/java_home $@`
 echo "JAVA_HOME:" $JAVA_HOME
 java -version
}


#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
export GVM_DIR="/Users/tkirk/.gvm"
[[ -s "/Users/tkirk/.gvm/bin/gvm-init.sh" ]] && source "/Users/tkirk/.gvm/bin/gvm-init.sh"

export PATH="$PATH:/Applications/HP_Fortify/HP_Fortify_SCA_and_Apps_4.40/bin:/usr/local/squid_toolkit/"
