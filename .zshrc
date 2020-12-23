autoload colors && colors

# ==============================================================================
# @@@ color / palette
# ==============================================================================
bg="221A0F"
bg_faint="2B2114"
fg="B48E56"
fg_faint="837668"
red="BD5157"
blue="6589AA"
cyan="558F7F"
brown="A4654E"
green="809044"
green2="689d6a"
orange="D2651D"
yellow="C19133"
magenta="AA73A1"


# ==============================================================================
# @@@ Vi mode
# ==============================================================================
bindkey -v

export EDITOR=vim
export VISUAL=vim

bindkey -M viins 'jk' vi-cmd-mode # exit insert mode

# enable quote and bracket objects
autoload -U select-bracketed
autoload -U select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in  visual viopp; do
    bindkey -M $km -- '-' vi-up-line-or-history

    for c in {a,i}"${(s..)^:-\'\"\`\|,./:;-=+@}"; do
        bindkey -M $km $c select-quoted
    done

    for c in {a,i}${(s..)^:-\(\)\[\]\{\}\<\>bB}; do
        bindkey -M $km $c select-bracketed
    done
done


# ==============================================================================
# @@@ General
# ==============================================================================
PROMPT="%{$fg_bold[cyan]%}%c >>>%{$reset_color%} "

unset SSH_ASKPASS
stty -ixon
setopt auto_cd

bindkey "^o" clear-screen

# Better tab completion
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# History
if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
setopt +o nomatch


# ==============================================================================
# @@@ Aliases
# ==============================================================================
alias gvim='gvim -geometry 200x200' # seems to work to make it fullscreen
alias ve='gvim -geometry 200x200 ~/.vimrc'
alias ze='gvim -geometry 200x200 ~/.zshrc'
alias ls='ls --group-directories-first --color'
alias lsa='ls --group-directories-first -a --color'
alias ymp='youtube-dl -x --audio-format mp3 -o Music/%(title)s.%(ext)s'
alias am1='amixer set -c 0 Speaker 100% unmute'
alias am0='amixer set -c 0 Speaker mute'

alias g='git'
alias gg='git add :/ ; git commit -m "gg" ; git push'
alias ga='git add'
alias gp='git push'
alias gb='git branch'
alias grb='git rebase'
alias gc='git commit -v'
alias gC='git add :/ ; git commit -v'
alias gd='git diff'
alias gs='git status'
alias gss='git status -s'
alias gco='git checkout'
alias gcm='git checkout master'
alias gcl='git clone --recursive'
alias glo="git log --pretty='%C(cyan)%h %C(cyan)%ad%Creset%C(yellow)%d%Creset %s' --date=short"
alias glog="git log --graph --pretty='%C(cyan)%h %C(cyan)%ad%Creset%C(yellow)%d%Creset %s' --date=short"
alias gloa="git log --pretty='%C(cyan)%h %C(cyan)%ad %C(magenta)a:%an %C(yellow)c:%cn%Creset%C(yellow)%d%Creset %s' --date=short"


# ==============================================================================
# @@@ color / apply
# ==============================================================================
color00=$bg
color01=$red
color02=$green
color03=$yellow
color04=$blue
color05=$magenta
color06=$cyan
color07=$fg
color08=$fg_faint
color09=$color01
color10=$color02
color11=$color03
color12=$color04
color13=$color05
color14=$color06
color15=$fg
color16=$orange
color17=$brown
color18=$bg_faint
color19=$bg_faint
color20=$fg_faint
color21=$fg

if [ -n "$TMUX" ]; then
    # Tell tmux to pass the escape sequences through
    # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
    printf_template='\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\033\\'
    printf_template_var='\033Ptmux;\033\033]%d;rgb:%s\033\033\\\033\\'
    printf_template_custom='\033Ptmux;\033\033]%s%s\033\033\\\033\\'
elif [ "${TERM%%-*}" = "screen" ]; then
    # GNU screen (screen, screen-256color, screen-256color-bce)
    printf_template='\033P\033]4;%d;rgb:%s\033\\'
    printf_template_var='\033P\033]%d;rgb:%s\033\\'
    printf_template_custom='\033P\033]%s%s\033\\'
else
    printf_template='\033]4;%d;rgb:%s\033\\'
    printf_template_var='\033]%d;rgb:%s\033\\'
    printf_template_custom='\033]%s%s\033\\'
fi

# 16 color space
printf $printf_template 0  $color00
printf $printf_template 1  $color01
printf $printf_template 2  $color02
printf $printf_template 3  $color03
printf $printf_template 4  $color04
printf $printf_template 5  $color05
printf $printf_template 6  $color06
printf $printf_template 7  $color07
printf $printf_template 8  $color08
printf $printf_template 9  $color09
printf $printf_template 10 $color10
printf $printf_template 11 $color11
printf $printf_template 12 $color12
printf $printf_template 13 $color13
printf $printf_template 14 $color14
printf $printf_template 15 $color15

# 256 color space
printf $printf_template 16 $color16
printf $printf_template 17 $color17
printf $printf_template 18 $color18
printf $printf_template 19 $color19
printf $printf_template 20 $color20
printf $printf_template 21 $color21
