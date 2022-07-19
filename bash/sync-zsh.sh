#! /bin/sh
#
# Usage
#    curl -fsSL https://github.com/aliuq/config/raw/master/bash/sync-zsh.sh | sh
#

sudo yum -y update && sudo yum -y install zsh git
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s - -y

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

curl -fsSL https://raw.githubusercontent.com/aliuq/config/master/bash/.zshrc > ~/.zshrc

chsh -s /bin/zsh root
