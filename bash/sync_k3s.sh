#! /bin/sh
set -e
#
# Usage
#    curl -fsSL https://github.com/aliuq/config/raw/master/bash/sync_k3s.sh | sh
#
#    Mirror of China:
#    curl -fsSL https://hub.llll.host/aliuq/config/raw/master/bash/sync_k3s.sh | sh -s - --mirror
#

mirror=false
while [ $# -gt 0 ]; do
  case "$1" in
    --mirror|-M) mirror=true shift ;;
    --*) echo "Illegal option $1" ;;
  esac
  shift $(( $# > 0 ? 1 : 0 ))
done

RAW_URL=${RAW_URL:-"https://raw.llll.host"}
HUB_URL=${HUB_URL:-"https://hub.llll.host"}

if ! $mirror; then
  HUB_URL="https://github.com"
  RAW_URL="https://raw.githubusercontent.com"
fi

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if ! command_exists zsh; then
  if ! $mirror; then
    curl -fsSL "$RAW_URL/aliuq/config/master/bash/install_zsh.sh" | sh
  else
    curl -fsSL "$RAW_URL/aliuq/config/master/bash/install_zsh.sh" | sh -s - --mirror
  fi
fi

if ! command_exists git; then
  yum install -y git
fi

# Backup old zsh config
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc ~/.zshrc.bak.`date +%Y%m%d%H%M%S`
fi

custom_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Install zsh-autosuggestions
autosuggestionsDir="$custom_dir/plugins/zsh-autosuggestions"
if [ ! -d "$autosuggestionsDir" ]; then
  git clone $HUB_URL/zsh-users/zsh-autosuggestions $autosuggestionsDir
else
  echo -e "\e[1;32mzsh-autosuggestions is already installed in $autosuggestionsDir\e[0m"
fi

# Install zsh-syntax-highlighting
syntaxHighlightingDir="$custom_dir/plugins/zsh-syntax-highlighting"
if [ ! -d "$syntaxHighlightingDir" ]; then
  git clone $HUB_URL/zsh-users/zsh-syntax-highlighting $syntaxHighlightingDir
else
  echo -e "\e[1;32mzsh-syntax-highlighting is already installed in $syntaxHighlightingDir\e[0m"
fi

curl -fsSL $RAW_URL/aliuq/config/master/bash/k3s.zshrc > ~/.zshrc

