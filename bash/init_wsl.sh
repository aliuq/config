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
$(curl -sSL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/modules/system.sh)
$(curl -sSL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/modules/config.sh)
$(curl -sSL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/modules/web.sh)
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
  clear
  printf "$(gray 脚本名称)    : $(white "个人开发环境管理脚本")\n"
  printf "$(gray 当前版本)    : 1.0.0\n"
  printf "$(gray 作者)        : AliuQ<https://github.com/aliuq>\n"
  printf "$(gray 脚本描述)    : 安装通用的环境和依赖，确保各机器之间保持体验一致\n"
  printf "$(gray 运行环境)    : $(red WSL2 Ubuntu)\n"
  printf "$(gray "所用 Shell")  : sh\n"
  echo

  # 脚本信息
  SCRIPT_NAME="WSL Ubuntu 环境初始化"
  VERSION="1.0.0"
  AUTHOR="AliuQ"
  DESCRIPTION="安装通用的环境和依赖，确保各机器之间保持体验一致"
  REQUIRED_SHELL="sh"

  echo "------------------- $(magenta 系统) -------------------"
  printf "$(green "1.") 更新软件包    $(green "2.") 修改主机名    $(green "q.") 退出\n"

  echo "\n\n------------------- $(magenta 配置) -------------------"
  printf "$(green "100.") 安装 zsh    $(green "101.") 安装 oh-my-zsh    $(green "102.") 覆盖 ~/.zshrc\n"

  echo "\n\n------------------- $(magenta 前端) -------------------"
  printf "$(green "200.") 安装 nvm    \n"

  echo
  echo
  read -p "$(magenta "=> 请输入要执行的命令编号:") " command_index
  echo
  echo

  case $command_index in
  1)
    update_packages
    ;;
  2)
    change_hostname
    ;;
  200)
    install_zsh
    ;;
  101)
    install_oh_my_zsh
    ;;
  102)
    sync_zshrc
    ;;
  200)
    install_nvm
    ;;
  [qQ] | [eE][xX][iI][tT] | [qQ][uU][iI][tT])
    exit 0
    ;;
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

install_nvm() {
  log "安装 nvm"
  read_confirm "是否安装 nvm？(y/n): " || return

  # 判断当前终端 echo $SHELL 是否是 zsh
  if [ "$SHELL" != "/usr/bin/zsh" ]; then
    red "==> 当前终端不是 zsh，请在 zsh 环境下执行"
    return
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

  echo "--------------------------------------------"
  info "安装完成，请执行 $(cyan "source ~/.zshrc") 使配置生效"
  info "安装完成后，可以执行 $(cyan "nvm install --lts") 安装最新的 LTS 版本"
  info "安装完成后，可以执行 $(cyan "nvm ls-remote") 查看所有可安装的版本"
  echo
}

# ======================== 分割线 ========================

echo_commands
