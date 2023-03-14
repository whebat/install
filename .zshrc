HISTORY_IGNORE="(ls(| *)|cd(| *)|pwd|exit|whoami|man)"

alias ls='ls -AF --color=auto'
alias recent='ls -ltch'
alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
alias ln='ln -v'
alias chmod='chmod -c'
alias chown='chown -c'
alias javac8='javac --release=8'
alias javac11='javac --release=11'
alias zrc="$EDITOR $ZDOTDIR/.zshrc && source $ZDOTDIR/.zshrc"
HISTFILE="$ZDOTDIR/.zsh_history"
SAVEHIST=65536

setopt beep nomatch interactivecomments hist_ignore_dups hist_ignore_space noflowcontrol
unsetopt autocd extendedglob notify
bindkey -e # emacs. -v for vi-style.
autoload -Uz compinit; compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
zstyle ':completion:*' rehash true

fgit() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
      (grep -o '[a-f0-9]\{7\}' | head -1 |
      xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
      {}
FZF-EOF"
}

lgit() {
  local current=$(pwd)
  cd $HOME
  find -name HEAD -execdir test -e refs -a -e objects \; \
    -execdir sh -ec 'GIT_DIR=$PWD git rev-parse --absolute-git-dir 2>&-' \;
  cd $current
}

fman() {
  man $(apropos '' | fzf \
    --no-sort --preview-window=top:25% \
    --bind=ctrl-s:toggle-sort \
    --preview 'echo {} | cut -f 1 -d " " | xargs man' | cut -f 1 -d " ")
}

qrcode() {
  qrencode -o ~/Desktop/qrcode.txt -t UTF8 -m 2 -l H "$1"
  cat ~/Desktop/qrcode.txt
  rm -f ~/Desktop/qrcode.txt
}

source "$HOME/repository/clone/gitstatus/gitstatus.plugin.zsh"
function my_set_prompt() {
# Print Error Code.
  if [ $? -eq 0 ]; then
    PROMPT="%B%F{green}➜  %f%b%~"
  else
    PROMPT="%B%F{red}➜  %f%b%~"
  fi

  if gitstatus_query MY && [[ $VCS_STATUS_RESULT == ok-sync ]]; then
    PROMPT+="%F{cyan} "${${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT}}//\%/%%} # escape %
    PROMPT+="%f"
    # res=''
    # (( VCS_STATUS_COMMITS_BEHIND                              )) && res=" ↓"
    # (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res=" ↑"
    # PROMPT+=$res
    (( VCS_STATUS_NUM_STAGED    )) && PROMPT+=' %B%F{green}+'"$VCS_STATUS_NUM_STAGED"'%f%b'
    (( VCS_STATUS_NUM_UNSTAGED  )) && PROMPT+=' %B%F{red}!'"$VCS_STATUS_NUM_UNSTAGED"'%f%b'
    (( VCS_STATUS_NUM_UNTRACKED )) && PROMPT+=' %B%F{magenta}?'"$VCS_STATUS_NUM_UNTRACKED"'%f%b'
  fi
    PROMPT+=" %% "

  setopt no_prompt_{bang,subst} prompt_percent  # enable/disable correct prompt expansions
}
gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'
autoload -Uz add-zsh-hook
add-zsh-hook precmd my_set_prompt
