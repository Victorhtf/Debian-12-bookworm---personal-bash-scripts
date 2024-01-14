#Open alias configurations
alias aliasconf='code ~/.bash_aliases'

alias ..='cd ..'
alias cdd='cd /home/victorhtf/Desktop'
alias open='xdg-open .'
alias su='su -'
alias fp='apt list -i | grep'
alias ips='ip -c -br a'
alias upd='sudo apt update && sudo apt upgrade -y'
alias ports='sudo netstat -tulanp'
alias fh='history|grep'
alias mkdir='mkdir -pv'
alias ll='ls -l'
alias la='ls -la'

#Colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls --color=auto'
alias dir='dir --color=auto'

#NPM aliases

#Docker aliases
alias duprb='docker compose up -d --force-recreate --build'
alias dup='docker up'

#Fun
alias matrix='cmatrix'
alias nf='neofetch'

#Network
alias rebootlinksys="curl -u 'admin:my-super-password' 'http://192.168.1.2/setup.cgi?todo=reboot'"
