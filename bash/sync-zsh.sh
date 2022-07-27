#! /bin/sh
#
# Usage
#    curl -fsSL https://github.com/aliuq/config/raw/master/bash/sync-zsh.sh | sh
#
#    Mirror of China:
#    curl -fsSL https://hub.fastgit.xyz/aliuq/config/raw/master/bash/sync-zsh.sh | sh -s - --mirror
#

mirror=false
while [ $# -gt 0 ]; do
	case "$1" in
		--mirror|-M) mirror=true shift ;;
		--*) echo "Illegal option $1" ;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

if $mirror; then
  github_url="https://hub.fastgit.xyz"
  raw_url="https://raw.fastgit.org"
else
  github_url="https://github.com"
  raw_url="https://raw.githubusercontent.com"
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
curl -fsSL $raw_url/ohmyzsh/ohmyzsh/master/tools/install.sh | REMOTE="$github_url/ohmyzsh/ohmyzsh.git" sh -s - -y
curl -fsSL $raw_url/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s - -y
git clone $github_url/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone $github_url/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -fsSL $raw_url/aliuq/config/master/bash/.zshrc > ~/.zshrc

