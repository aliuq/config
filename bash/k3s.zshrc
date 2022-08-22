# This configuration is used for k3s cluster node servers
# Copyright (c) by aliuq
#

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# https://kubernetes.io/zh-cn/docs/tasks/tools/included/optional-kubectl-configs-zsh/
autoload -Uz compinit
compinit

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(git kubectl zsh-autosuggestions zsh-syntax-highlighting)

# Enable aliases to be sudo’ed
# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias _='sudo '
alias cls="clear"
alias szsh="source ~/.zshrc"
alias vzsh="vim ~/.zshrc"
alias aptup="sudo apt update && sudo apt -y upgrade"
alias yumup="sudo yum update && sudo yum -y upgrade"

export PATH=$HOME/bin:/usr/local/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

source $ZSH/oh-my-zsh.sh
# User configuration
source ~/.bash_profile

# Variables
# kgpa | awk "$AWK_SPACE{print \$1,\$2}"
AWK_SPACE="BEGIN { FPAT = \"([[:space:]]*[[:alnum:][:punct:][:digit:]]+)\"; OFS = \"\"; }"

# Alias
alias s="systemctl"
alias sr="systemctl restart"
alias srf="systemctl daemon-reload && systemctl restart"
alias sst="systemctl status"
alias sync_zsh_conf_mirror="curl -fsSL https://hub.llll.host/aliuq/config/raw/master/bash/sync_k3s.sh | sh -s - --mirror"
alias sync_zsh_conf="curl -fsSL https://github.com/aliuq/config/raw/master/bash/sync_k3s.sh | sh"
alias ktn="kubectl top node"

# Functions
get_ip() { curl -s ip.llll.host }

# Force delete namespace
kdelnsf() {
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "\e[1;33mjq is not installed, please install it first, \"yum install -y jq\"\e[0m"
    return 0
  fi
  if [ $1 ]; then
    file="$1_tmp.json"
    echo "kubectl get namespace $1 -o json > $file"
    kubectl get namespace $1 -o json > $file >/dev/null 2>&1
    echo "echo \`cat $file\` | perl -pe \"s/\\\"finalizers\\\": \[.*?\]/\\\"finalizers\\\": \[\]/g\" | jq . > $file"
    echo `cat $file` | perl -pe "s/\"finalizers\": \[.*?\]/\"finalizers\": \[\]/g" | jq . > $file >/dev/null 2>&1
    echo "kubectl replace --raw \"/api/v1/namespaces/$1/finalize\" -f $file"
    kubectl replace --raw "/api/v1/namespaces/$1/finalize" -f $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "namespace $1 deleted"
      echo "rm $file -rf"
      rm $file -rf
    else
      echo "failed deleted namespace $1"
    fi
    return 0
  fi
}

# Delete pod by matching label
kdelpm() {
  pod=$1
  if [ $pod ]; then
    shift
    kubectl get pods -A | grep $pod | awk '{print $1,$2}' | while read ns name; do
      kubectl delete -n $ns pod $name $@
    done
  fi
}

_kde_comp() {
  local curword="${COMP_WORDS[COMP_CWORD]}"
  if [ $curword ]; then
    pods=$(kubectl get pods -A | grep $curword | awk '{print $2}')
  else
    pods=$(kubectl get pods -A | awk '{if (NR>1){print $2}}')
  fi
  local completions=(${(@f)pods})
  _describe 'command' completions
}

compdef _kde_comp kdelpm

ktp() {
  if [ $# -eq 0 ]; then
    kubectl top pods -A | awk 'NR == 1 {print $0};NR != 1 {print $0 | "sort -n -k 4 -r"}'
  else
    kubectl top pods -A | awk 'NR == 1 {print $0};NR != 1 {print $0 | "sort -n -k 4 -r | grep -P '$1'"}'
  fi
}
