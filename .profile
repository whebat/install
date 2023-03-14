export EDITOR=nano
export VISUAL=nano
export PAGER=less
export MANPAGER='less -R -J --use-color --status-line -DSY -Du+G -S --mouse --wheel-lines=1'
export HISTSIZE=65536
HISTFILE=~/.histfile
SAVEHIST=65536

export ZDOTDIR=~/.config/zsh

export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state

export GOPATH=~/.local/share/go
export GOPROXY=direct
export GOSUMDB=off
export GOTELEMETRY=off
export GOTOOLCHAIN=local

# Use default .bashrc if running bash
if [ -n "\$BASH_VERSION" ]; then
  source /etc/skel/.bashrc
elif [ -n "\$ZSH_VERSION" ]; then
  source \$ZDOTDIR/.zshrc
# Fallback default PS1
else
  : "\${HOSTNAME:=\$(hostname)}"
  PS1='\${HOSTNAME%%.*}:\${PWD}'
  PS1="\${PS1}\\\$ "
fi
