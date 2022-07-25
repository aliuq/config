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

sudo yum -y update && sudo yum -y install zsh git
# The REMOTE environment variable is used to mirror the repository.
curl -fsSL $raw_url/ohmyzsh/ohmyzsh/master/tools/install.sh | REMOTE="$github_url/ohmyzsh/ohmyzsh.git" sh -s - -y
curl -fsSL $raw_url/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s - -y
git clone $github_url/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone $github_url/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
curl -fsSL $raw_url/aliuq/config/master/bash/.zshrc > ~/.zshrc
chsh -s /bin/zsh root
