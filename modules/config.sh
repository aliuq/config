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
      run "git clone $HUB_URL/zsh-users/zsh-syntax-highlighting $syntaxHighlightingDir"
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
    info "\n\n请执行 $(cyan "source ~/.zshrc") 使配置生效"
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
    if $dry_run; then
      run "sudo chsh -s $(which zsh)"
    else
      sudo chsh -s $(which zsh)
    fi
  fi

  echo
  install_oh_my_zsh

  echo
  sync_zshrc
}

install_starship_add_config() {
  if read_confirm "是否添加通用配置到 ~/.config/starship.toml？(y/n): " false; then
    if read_confirm "是否使用 mirror？(y/n): "; then
      RAW_URL="https://raw.llll.host"
    else
      RAW_URL="https://raw.githubusercontent.com"
    fi

    run "mkdir -p ~/.config"
    run "curl -fsSL $RAW_URL/aliuq/config/master/config/starship.toml >~/.config/starship.toml"
  fi
}

install_starship_set_cloud() {
  log "设置云服务商环境变量"
  if read_confirm "是否设置云服务商环境变量？(y/n): " false; then
    cloud_server_str="阿里云|腾讯云"
    read_from_options_show $cloud_server_str
    cloud_server=$(read_from_options "请选择云服务厂商?" "" $cloud_server_str)
    echo
    if [ -n "$cloud_server" ]; then
      if echo "$SHELL" | grep -qE "/bash$"; then
        run "echo 'export CLOUD_SERVER=$cloud_server' >>~/.bashrc"
      fi
      if echo "$SHELL" | grep -qE "/zsh$"; then
        run "echo 'export CLOUD_SERVER=$cloud_server' >>~/.zshrc"
      fi
    fi

    cloud_server_region_str="上海|北京|广州|深圳|杭州|香港|新加坡"
    read_from_options_show $cloud_server_region_str
    cloud_server_region=$(read_from_options "请选择所在地域?" "" $cloud_server_region_str)
    echo
    if [ -n "$cloud_server_region" ]; then
      if echo "$SHELL" | grep -qE "/bash$"; then
        run "echo 'export CLOUD_SERVER_REGION=$cloud_server_region' >>~/.bashrc"
      fi
      if echo "$SHELL" | grep -qE "/zsh$"; then
        run "echo 'export CLOUD_SERVER_REGION=$cloud_server_region' >>~/.zshrc"
      fi
    fi
  fi
}

install_starship() {
  log "安装 starship"

  if read_confirm "是否安装 starship？(y/n): "; then
    if $dry_run; then
      run "commands_valid curl"
    else
      commands_valid curl
    fi
    run "curl -sS https://starship.rs/install.sh | sh"

    # 如果 shell 匹配到 /*\/bash/，且 .bashrc 文件中不包含 【eval "$(starship init bash)"】 则添加
    if echo "$SHELL" | grep -qE "/bash$"; then
      if ! grep -q "eval \"\$(starship init bash)\"" ~/.bashrc; then
        run "echo 'eval \"\$(starship init bash)\"' >>~/.bashrc"
      fi
      install_starship_add_config
      info "\n\n请执行 $(cyan "source ~/.bashrc") 使配置生效"
    fi

    # 如果 shell 匹配到 /*\/zsh/，且 .zshrc 文件中不包含 【eval "$(starship init zsh)"】 则添加
    if echo "$SHELL" | grep -qE "/zsh$"; then
      if ! grep -q "eval \"\$(starship init zsh)\"" ~/.zshrc; then
        run "echo 'eval \"\$(starship init zsh)\"' >>~/.zshrc"
      fi
      install_starship_add_config
      info "\n\n请执行 $(cyan "source ~/.zshrc") 使配置生效"
    fi

    install_starship_set_cloud
  fi
}

add_wakatime() {
  log "添加 wakatime"

  if read_confirm "是否添加通用配置到 ~/.wakatime.cfg？(y/n): " false; then
    api_url=$(read_input "请输入 api_url: ")
    api_key=$(read_input "请输入 api_key: ")

    if [ -z "$api_url" ] || [ -z "$api_key" ]; then
      red "api_url 和 api_key 不能为空"
    else
      run "cat >~/.wakatime.cfg <<-EOF
[settings]
api_url = $api_url
api_key = $api_key
EOF"
    fi
  fi
}

add_docker_mirror() {
  log "添加 docker 镜像加速"

  if $dry_run; then
    run "commands_valid docker jq"
  else
    commands_valid docker jq
  fi

  if read_confirm "是否添加 docker 镜像加速？(y/n): "; then
    mirror_url=$(read_input "请输入镜像地址，国内服务器无法访问 https://registry-1.docker.io: ")
    if [ -z "$mirror_url" ]; then
      red "镜像地址不能为空"
    else
      # 判断是否存在 /etc/docker/daemon.json 文件，如果不存在则创建
      if [ ! -f /etc/docker/daemon.json ]; then
        run "mkdir -p /etc/docker"
        run "touch /etc/docker/daemon.json"
      fi
      # 使用 jq 进行修复意外空格或者空行情况
      if ! jq -e '.["registry-mirrors"]' /etc/docker/daemon.json >/dev/null 2>&1; then
        run "jq '. + {\"registry-mirrors\": [\"$mirror_url\"]}' /etc/docker/daemon.json > /tmp/daemon.json && mv /tmp/daemon.json /etc/docker/daemon.json"
      else
        run "jq '.\"registry-mirrors\" += [\"$mirror_url\"]' /etc/docker/daemon.json > /tmp/daemon.json && mv /tmp/daemon.json /etc/docker/daemon.json"
      fi

      run "systemctl restart docker"
    fi
  fi
}
