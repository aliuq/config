# All my usage aliases

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
alias k='kubectl'
alias kc='kubectl config'

function i() {
  cd ~/apps/$1
}
