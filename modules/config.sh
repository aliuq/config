#!/bin/sh
#
# 个人开发环境管理脚本 -  配置模块
#
# - 目前仅支持 Ubuntu apt 安装
#
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/run.sh)
#
set -e

if ! command -v run >/dev/null 2>&1; then
  . /dev/stdin <<EOF
$(curl -sSL https://s.xod.cc/shell-helper-mirror)
EOF
fi

# ======================== 分割线 ========================
install_zsh_from_source() {
  zsh_version=$(read_input "请输入 zsh 版本(5.9): " 5.9)
  echo
  mirror_url=$(read_confirm_and_input "是否使用 mirror，结尾不要有斜杠/ (y/n): " "https://dl.llll.host")

  echo
  info "zsh version: $(cyan $zsh_version)"
  info "mirror  url: $(cyan $mirror_url)"
  echo

  if $dry_run; then
    run "commands_valid curl tar"
  else
    commands_valid curl tar
  fi
  url="https://sourceforge.net/projects/zsh/files/zsh/$zsh_version/zsh-$zsh_version.tar.xz/download"
  download_url=$(curl -s "$url" | grep -oP "(?<=href=\")[^\"]+(?=\")")
  sleep 1
  download_url=$(curl -s "$download_url" | grep -oP "(?<=href=\")[^\"]+(?=\")")
  real_url="$mirror_url$download_url"

  run "apt install -y curl make gcc libncurses5-dev libncursesw5-dev"
  run "curl -fsS -o /tmp/zsh.tar.xz \"$real_url\""
  run "tar -xf /tmp/zsh.tar.xz -C /tmp"

  current_dir=$(pwd)
  run "cd /tmp/zsh-$zsh_version && ./Util/preconfig && ./configure --without-tcsetpgrp --prefix=/usr --bindir=/bin && make -j 20 install.bin install.modules install.fns"
  run "cd $current_dir && rm -rf /tmp/zsh.tar.xz && rm -rf /tmp/zsh-$zsh_version"
  run "zsh --version && echo \"/bin/zsh\" | tee -a /etc/shells && echo \"/usr/bin/zsh\" | tee -a /etc/shells"
}

install_oh_my_zsh() {
  log "安装 oh-my-zsh"

  if read_confirm "是否安装 oh-my-zsh？(y/n): " false; then
    if read_confirm "是否使用 mirror？(y/n): "; then
      HUB_URL="https://hub.llll.host"
      RAW_URL="https://raw.llll.host"
    else
      HUB_URL="https://github.com"
      RAW_URL="https://raw.githubusercontent.com"
    fi

    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    if $dry_run; then
      run "commands_valid curl git"
    else
      commands_valid curl git
    fi
    url="$RAW_URL/ohmyzsh/ohmyzsh/master/tools/install.sh"
    run "curl -fsSL \"$url\" | sh -s - -y"

    # zsh-autosuggestions
    autosuggestionsDir="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    if [ ! -d "$autosuggestionsDir" ]; then
      run "git clone $HUB_URL/zsh-users/zsh-autosuggestions $autosuggestionsDir"
    else
      cyan "zsh-autosuggestions is already installed in $autosuggestionsDir"
    fi

    # zsh-syntax-highlighting
    syntaxHighlightingDir="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    if [ ! -d "$syntaxHighlightingDir" ]; then
      run "git clone $HUB_URL/zsh-users/zsh-syntax-highlighting.git $syntaxHighlightingDir"
    else
      cyan "zsh-syntax-highlighting is already installed in $syntaxHighlightingDir"
    fi
  fi
}

sync_zshrc() {
  log "同步 zshrc，该操作会覆盖现有的 ~/.zshrc"
  if read_confirm "是否更新 zshrc？(y/n): "; then
    if read_confirm "是否使用 mirror？(y/n): "; then
      RAW_URL="https://raw.llll.host"
    else
      RAW_URL="https://raw.githubusercontent.com"
    fi
    run "curl -fsSL $RAW_URL/aliuq/config/master/config/.zshrc >~/.zshrc"
    run "source ~/.zshrc"
  fi
}

install_zsh() {
  log "安装 zsh"

  if read_confirm "是否安装 zsh？(y/n): "; then
    install_type=$(read_input "请选择安装方式(1. apt 安装，2. 源码安装，默认为 1): " "1")
    if [ "$install_type" = "1" ]; then
      run "apt install -y zsh"
    else
      install_zsh_from_source
    fi
    run "chsh -s $(command -v zsh)"
  fi

  echo
  install_oh_my_zsh

  echo
  sync_zshrc
}
