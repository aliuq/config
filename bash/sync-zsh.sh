#! /bin/sh
#
# Usage
#    source <(curl -fsSL https://raw.githubusercontent.com/aliuq/config/master/bash/sync-zsh.sh)
#

sudo yum -y update && sudo yum -y install zsh git
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s - -y

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

if [ -f ~/.zshrc ]; then
  echo '[ -s "~/$USER/.alias.bashrc" ] && source "~/$USER/.alias.bashrc"' >> ~/.zshrc
elif [ -f ~/.bashrc ]; then
  echo '[ -s "~/$USER/.alias.bashrc" ] && source "~/$USER/.alias.bashrc"' >> ~/.bashrc
fi

curl -fsS https://raw.githubusercontent.com/aliuq/config/master/bash/.alias.bashrc -o ~/.alias.bashrc
