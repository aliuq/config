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

if ! $mirror; then
  HUB_URL="https://github.com"
  RAW_URL="https://raw.githubusercontent.com"
fi

# Manualy install zsh v5.9
yum update -y && yum install -y git make ncurses-devel gcc autoconf man
wget https://udomain.dl.sourceforge.net/project/zsh/zsh/5.9/zsh-5.9.tar.xz -O /tmp/zsh.tar.xz
tar -xf /tmp/zsh.tar.xz -C /tmp
current_dir=$(pwd)
cd /tmp/zsh-5.9
./Util/preconfig && ./configure
make -j 20 install.bin install.modules install.fns
command -v zsh | sudo tee -a /etc/shells
chsh -s /usr/local/bin/zsh
cd $current_dir
# Install oh-my-zsh
# The REMOTE environment variable is used to mirror the repository.
curl -fsSL $RAW_URL/ohmyzsh/ohmyzsh/master/tools/install.sh | REMOTE="$HUB_URL/ohmyzsh/ohmyzsh.git" sh -s - -y
git clone $HUB_URL/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone $HUB_URL/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -fsSL $RAW_URL/aliuq/config/master/bash/.zshrc > ~/.zshrc

