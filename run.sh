#!/bin/sh
#
# 个人开发环境管理脚本
#
# - 目前仅支持 Ubuntu apt 安装
#
# sh <(curl -sL https://raw.githubusercontent.com/aliuq/config/refs/heads/master/run.sh)
# sh <(curl -sL https://s.xod.cc/run)
# MIRROR=true sh <(curl -sL https://s.xod.cc/run-mirror)
# MIRROR=true sh <(curl -sL https://raw.llll.host/aliuq/config/refs/heads/master/run.sh)
#
set -e

# 从环境变量来判断是否通过镜像获取文件，避免请求过慢的问题
global_mirror=${MIRROR:-false}

case $global_mirror in
true)
  global_mirror="https://raw.llll.host"
  ;;
false)
  global_mirror="https://raw.githubusercontent.com"
  ;;
esac

. /dev/stdin <<EOF
$(curl -sSL $global_mirror/aliuq/config/refs/heads/master/helper.sh)
$(curl -sSL $global_mirror/aliuq/config/refs/heads/master/modules/system.sh)
$(curl -sSL $global_mirror/aliuq/config/refs/heads/master/modules/config.sh)
$(curl -sSL $global_mirror/aliuq/config/refs/heads/master/modules/web.sh)
EOF

preset=""
while [ $# -gt 0 ]; do
  case "$1" in
  --preset)
    preset="$2"
    shift
    ;;
  --*)
    echo "Illegal option $1"
    ;;
  esac
  shift $(($# > 0 ? 1 : 0))
done

if $help; then
  yellow "\n暂未实现 help 功能"
  exit 0
fi

echo_info() {
  OS=$(uname -s)
  KERNEL_VERSION=$(uname -r)
  USERNAME=$(whoami)

  # 检查是否在 WSL 环境中
  if grep -qi microsoft /proc/version; then
    IS_WSL="Yes"
  else
    IS_WSL="No"
  fi

  # 获取完整的系统信息
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION"
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS_NAME="$DISTRIB_ID"
    OS_VERSION="$DISTRIB_RELEASE"
  else
    OS_NAME="Unknown"
    OS_VERSION="Unknown"
  fi

  UPTIME_RAW=$(uptime -p)
  UPTIME_CN=$(echo "$UPTIME_RAW" | sed \
    -e 's/up //g' \
    -e 's/ days/天/g' \
    -e 's/ day/天/g' \
    -e 's/ hours/小时/g' \
    -e 's/ hour/小时/g' \
    -e 's/ minutes/分钟/g' \
    -e 's/ minute/分钟/g' \
    -e 's/,//g' \
    -e 's/ and / /g')

  echo
  clear
  printf "脚本名称    : $(white "个人开发环境管理脚本")\n"
  printf "脚本地址    : https://github.com/aliuq/config/blob/master/run.sh\n"
  printf "描述        : 记录一些本人经常使用的脚本操作\n"
  printf "Shell       : %s\n" "$SHELL"
  printf "Hostname    : %s\n" "$(hostname)"
  printf "Username    : %s\n" "$USERNAME"
  printf "IP          : %s\n" "$(hostname -I)"
  printf "公网 IP     : %s\n" "$(green "$(curl -sL https://ip.llll.host)")"
  printf "系统运行时间: %s\n" "$UPTIME_CN"

  if $verbose; then
    echo "_________________________________________\n"
    printf "系统        : %s %s\n" "$OS_NAME" "$OS_VERSION"
    printf "内核        : %s\n" "$KERNEL_VERSION"
    printf "是否是 WSL  : %s\n" "$IS_WSL"
    printf "系统架构    : %s\n" "$(uname -m)"
    printf "Home        : %s\n" "$HOME"
    printf "当前目录    : %s\n" "$(pwd)"
    echo
  fi
}

echo_commands() {
  printf "\n------------------- $(magenta "系统") -------------------\n"
  printf "$(green "1.") 更新软件包    $(green "2.") 修改主机名    $(green "q.") 退出\n"
  printf "$(green "3.") 修改 ssh 端口\n"

  printf "\n\n------------------- $(magenta "配置") -------------------\n"
  printf "$(green "100.") 安装 zsh            $(green "101.") 安装 oh-my-zsh            $(green "102.") 覆盖 ~/.zshrc\n"
  printf "$(green "103.") 安装 starship       $(green "104.") 添加 waketime             $(green "105.") 添加 docker 镜像\n"
  printf "$(green "106.") 生成 ssh 密钥\n"

  printf "\n\n------------------- $(magenta 前端) -------------------\n"
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
  3)
    change_ssh_port
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
  105)
    add_docker_mirror
    ;;
  106)
    generate_ssh_key
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

echo_info
echo_commands
