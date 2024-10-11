#!/bin/sh

#
# 初始化 WSL 环境和依赖
#
# sh <(curl -L -s https://raw.githubusercontent.com/aliuq/config/refs/heads/master/bash/init_wsl.sh)
#

set -e

# . /home/aliuq/apps/config/helper.sh

. /dev/stdin <<EOF
$(curl -sSL https://s.xod.cc/shell-helper-mirror)
EOF

# ======================== 分割线 ========================

echo_help() {
  echo
  echo "###################################################################"
  echo "#                                                                 #"
  echo "# WSL Ubuntu 环境初始化                                           #"
  echo "# Author: AliuQ                                                   #"
  echo "#                                                                 #"
  echo "###################################################################"
  echo
}

echo_commands() {
  array="更新软件包|修改主机名并同步到 /etc/hosts|安装 zsh|安装 oh-my-zsh|同步 zshrc|安装 nvm|退出"
  IFS="|"

  # 脚本信息
  SCRIPT_NAME="WSL Ubuntu 环境初始化"
  VERSION="1.0.0"
  AUTHOR="AliuQ"
  DESCRIPTION="安装通用的环境和依赖，确保各机器之间保持体验一致"
  REQUIRED_SHELL="sh"

  # 打印格式化信息
  echo
  echo
  printf "%s\n" $(dim "####################################################################")
  printf "%s %74s \n" $(dim "##") $(dim "##")
  printf "%s %-15s : %-63s %s\n" $(dim "##") "脚本名称" $(white "$SCRIPT_NAME") $(dim "##")
  printf "%s %-15s : %-58s %s\n" $(dim "##") "当前版本" $(white "$VERSION") $(dim "##")
  printf "%s %-15s : %-58s %s\n" $(dim "##") "脚本作者" $(white "$AUTHOR") $(dim "##")
  printf "%s %-15s : %-50s %s\n" $(dim "##") "脚本描述" $(white "$DESCRIPTION") $(dim "##")
  printf "%s %-15s : %-58s %s\n" $(dim "##") "运行环境" $(white "WSL2 Ubuntu") $(dim "##")
  printf "%s %-15s : %-58s %s\n" $(dim "##") "脚本环境" $(white "$REQUIRED_SHELL") $(dim "##")
  printf "%s %74s \n" $(dim "##") $(dim "##")
  printf "%s\n" $(dim "####################################################################")
  echo
  echo

  printf "%-5s  %-20s\n" $(green "序号") $(cyan "命令")
  printf "%-5s  %-20s\n" $(gray "====") $(gray "====")

  index=1
  for item in $array; do
    if [ "$item" = "退出" ]; then
      echo "$(green q)     $(cyan $item)"
    else
      echo "$(green $index)     $(cyan $item)"
    fi
    index=$(($index + 1))
  done

  unset IFS

  echo
  read -p "请输入要执行的命令编号: " command_index
  echo
  echo

  case $command_index in
  1) update_packages ;;
  2) change_hostname ;;
  3) install_zsh ;;
  4) install_oh_my_zsh ;;
  5) sync_zshrc ;;
  6) install_nvm ;;
  q) exit 0 ;;
  *)
    red "命令编号错误: $command_index"
    exit 1
    ;;
  esac
  echo
  echo
}

# ======================== 分割线 ========================

update_packages() {
  log "更新软件包"
  read_confirm "是否更新软件包？(y/n): " || return
  run "apt update -y && apt upgrade -y"
}

change_hostname() {
  log "修改主机名和 /etc/hosts："
  read_confirm "是否修改主机名？(y/n): " || return

  new_hostname=$(read_input "请输入新的主机名(wsl): " wsl)
  HOSTNAME=$(hostname)
  echo
  run "sed -i 's/$HOSTNAME/$new_hostname/g' /etc/hosts"
  run "hostnamectl set-hostname $new_hostname"
  info "主机名修改成功，$(cyan $HOSTNAME) => $(cyan $new_hostname)"
}

install_zsh() {
  log "安装 zsh"
  read_confirm "是否安装 zsh？(y/n): " || return

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
  run "chsh -s /usr/bin/zsh"

  echo
  install_oh_my_zsh
  echo
  sync_zshrc
}

install_oh_my_zsh() {
  log "安装 oh-my-zsh"
  read_confirm "是否安装 oh-my-zsh？(y/n): " false || return

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
}

sync_zshrc() {
  log "同步 zshrc，执行会追加一些内容到 ~/.zshrc，最好只执行一次！！！"
  read_confirm "是否更新 zshrc？(y/n): " || return

  # 修改主题为 agnoster
  run "sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g' ~/.zshrc"
  # 添加插件
  run "sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc"

  # 将多行文本，写入到 ~/.zshrc 文件中
  run "cat >>~/.zshrc <<-EOF

# Enable aliases to be sudo’ed
# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias _=\"sudo \"
alias cls=\"clear\"
alias szsh=\"source ~/.zshrc\"
alias vzsh=\"vim ~/.zshrc\"
alias sbash=\"source ~/.bashrc\"
alias vbash=\"vim ~/.bashrc\"
alias aptup=\"sudo apt update && sudo apt -y upgrade\"

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

function get_ip() { curl -s ip.llll.host }

export PATH=\\\$HOME/bin:/usr/local/bin:\\\$PATH
EOF"
}

install_nvm() {
  log "安装 nvm"
  read_confirm "是否安装 nvm？(y/n): " || return

  # 判断当前终端 echo $SHELL 是否是 zsh
  if [ "$SHELL" != "/usr/bin/zsh" ]; then
    red "==> 当前终端不是 zsh，请先安装 zsh"
    read_confirm "是否继续安装 nvm？(y/n): " || return
  fi

  if $dry_run; then
    run "commands_valid curl"
  else
    commands_valid curl
  fi
  echo
  version=$(read_input "请输入 nvm 版本(默认最新版 master/v0.40.1): " "master")
  echo
  run "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh | bash"
}

# ======================== 分割线 ========================

echo_commands
