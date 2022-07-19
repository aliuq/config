# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Enable aliases to be sudo’ed
# http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias _='sudo '

alias py="python3"
alias cls="clear"
alias apps="cd ~/apps"
alias szsh="source ~/.zshrc"
alias vzsh="vim ~/.zshrc"
alias sbash="source ~/.bashrc"
alias vbash="vim ~/.bashrc"
alias aptup="sudo apt update && sudo apt -y upgrade"
alias yumup="sudo yum update && sudo yum -y upgrade"
alias s="systemctl"

function i() {
  cd ~/apps/$1
}
function sr() {
  systemctl restart $1
}
function sst() {
  systemctl status $1
}

export PATH=$HOME/bin:/usr/local/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# bun completions
[ -s "~/$USER/.bun/_bun" ] && source "~/$USER/.bun/_bun"

# Bun
export BUN_INSTALL="~/$USER/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Pnpm
export PNPM_HOME="~/$USER/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

source $ZSH/oh-my-zsh.sh
# User configuration
source ~/.bash_profile

# ======== kubectl ========
alias k='kubectl'
alias kc='kubectl config'
alias kpods='kubectl get pods -A'
alias knodes='kubectl get nodes'
