#! /bin/sh
#
# Usage
#    curl -fsSL https://github.com/aliuq/config/raw/master/bash/sync-zsh.sh | sh
#
#    Mirror of China:
#    curl -fsSL https://hub.llll.host/aliuq/config/raw/master/bash/sync-zsh.sh | sh -s - --mirror
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
ZSH_URL=${ZSH_URL:-"https://aliuq.oss-cn-beijing.aliyuncs.com/zsh-5.9.tar.xz"}

if ! $mirror; then
  HUB_URL="https://github.com"
  RAW_URL="https://raw.githubusercontent.com"
  ZSH_URL="https://udomain.dl.sourceforge.net/project/zsh/zsh/5.9/zsh-5.9.tar.xz"
fi

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if ! command_exists zsh; then
  # Manualy install zsh v5.9
  yum update -y && yum install -y make ncurses-devel gcc autoconf man
  wget $ZSH_URL -O /tmp/zsh.tar.xz
  tar -xf /tmp/zsh.tar.xz -C /tmp
  current_dir=$(pwd)
  cd /tmp/zsh-5.9
  ./Util/preconfig && ./configure
  make -j 20 install.bin install.modules install.fns
  command -v zsh | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/zsh
  cd $current_dir
fi

if ! command_exists git; then
  yum install -y git
fi
# Install oh-my-zsh
# The REMOTE environment variable is used to mirror the repository.
curl -fsSL $RAW_URL/ohmyzsh/ohmyzsh/master/tools/install.sh | REMOTE="$HUB_URL/ohmyzsh/ohmyzsh.git" sh -s - -y

