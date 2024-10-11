#!/bin/sh
#
# 个人开发环境管理脚本 - 系统模块
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
update_packages() {
  log "更新软件包"
  read_confirm "是否更新软件包？(y/n): " || return
  run "apt update -y && apt upgrade -y"
}

change_hostname() {
  log "修改主机名和 /etc/hosts："
  read_confirm "是否修改主机名？(y/n): " || return

  new_hostname=$(read_input "请输入新的主机名(如果为空，则填充为 wsl): " wsl)
  HOSTNAME=$(hostname)
  echo
  run "sed -i 's/$HOSTNAME/$new_hostname/g' /etc/hosts"
  run "hostnamectl set-hostname $new_hostname"
  info "主机名修改成功，$(cyan $HOSTNAME) => $(cyan $new_hostname)"
}
