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

change_ssh_port() {
  log "修改 SSH 端口："
  read_confirm "是否修改 SSH 端口？(y/n): " || return

  new_port=$(read_input "请输入新的 SSH 端口: ")
  if [ -z "$new_port" ]; then
    red "\n=> 端口不能为空"
  else
    echo
    run "sed -i 's/#Port 22/Port $new_port/g' /etc/ssh/sshd_config"
    if is_ubuntu; then
      run "systemctl restart ssh"
    fi
    if is_centos; then
      run "systemctl restart sshd"
    fi
    echo
    yellow "=> SSH 端口修改成功，$(cyan 22) => $(cyan $new_port)"
    yellow "=> 在云服务器中时，请在云服务商的安全组中开放新的 SSH 端口 $(cyan $new_port)"
    yellow "=> 最后不要忘了重启服务器 $(cyan "sudo reboot")"

    read_confirm "是否立即重启服务器？(y/n): " && run "sudo reboot"
  fi
}

generate_ssh_key() {
  log "生成 SSH 密钥："

  if read_confirm "是否生成 SSH 密钥？(y/n): "; then
    save_dir="/tmp/ssh/$(date "+%Y-%m-%d-%H-%M-%S")"
    name=$(read_input "请输入密钥名称(默认 key): " "key")
    type=$(read_input "请输入密钥类型(1. rsa, 2. ed25519, 默认 2): " "2")
    if [ "$type" = "1" ]; then type="rsa"; else type="ed25519"; fi
    key="$save_dir/$name"

    run "mkdir -p $save_dir"
    run "ssh-keygen -t "$type" -b 4096 -C "aliuq@bilishare.com" -f \"$key\" -N \"\" -q"

    green "\n✅ SSH 密钥生成成功\n"
    info " - 私钥保存在 $(cyan $key)"
    info " - 公钥保存在 $(cyan $key.pub)"
    echo
    info "使用: \n"
    info "  1. 将公钥添加到远程服务器"
    info "     先通过服务器控制台或者密码连接到远程服务器, 然后执行以下命令\n"
    info "     > $(cyan "echo \"$(cat $key.pub)\" >> ~/.ssh/authorized_keys")"
    echo
    info "  2. 将私钥保存到本地, 通常是 $(cyan "~/.ssh") 下\n"
    info "     > $(cyan "cp $key ~/.ssh/")"
    info "     > $(cyan "ssh -i $key user@host")"
    echo
    yellow_bright "  * 注意: 请不要泄露私钥，否则可能导致账号被盗\n"
  fi
}
