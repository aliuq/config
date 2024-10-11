#!/bin/sh
#
# 个人开发环境管理脚本
#
# - 目前仅支持 Ubuntu apt 安装
#
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/run.sh)
#
set -e

. /dev/stdin <<EOF
$(curl -sSL https://s.xod.cc/shell-helper-mirror)
$(curl -sSL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/modules/system.sh)
$(curl -sSL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/modules/config.sh)
$(curl -sSL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/modules/web.sh)
EOF

# ======================== 分割线 ========================
echo_commands() {
  clear
  printf "$(gray 脚本名称)    : $(white "个人开发环境管理脚本")\n"
  printf "$(gray 当前版本)    : 1.0.0\n"
  printf "$(gray 作者)        : AliuQ <https://github.com/aliuq>\n"
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
  printf "$(green "100.") 安装 zsh            $(green "101.") 安装 oh-my-zsh            $(green "102.") 覆盖 ~/.zshrc\n"
  printf "$(green "103.") 安装 starship       $(green "104.") 添加 waketime\n"

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
  100)
    install_zsh
    ;;
  101)
    install_oh_my_zsh
    ;;
  102)
    sync_zshrc
    ;;
  103)
    install_starship
    ;;
  104)
    add_wakatime
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

echo_commands
