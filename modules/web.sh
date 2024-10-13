#!/bin/sh
#
# 个人开发环境管理脚本 - 前端模块
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

  echo
  green "安装完成，请执行 $(cyan "source ~/.zshrc") 使配置生效"
  echo
  info " - 安装最新的 LTS 版本: $(cyan "nvm install --lts")"
  info " - 查看所有可安装的版本: $(cyan "nvm ls-remote")"
  echo
  info " - 如果遇到错误\n"
  info "   1. $(red "mkdir: cannot create directory '~/.nvm/alias': Permission denied")\n"
  info "      请尝试为 ~/.nvm 目录添加写权限 $(cyan "sudo chmod 777 -R ~/.nvm")"
}
