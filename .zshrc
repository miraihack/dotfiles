source ~/.zplug/init.zsh

# KEYBIND
bindkey -v

zplug "nvbn/thefuck"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "sunlei/zsh-ssh"
zplug "junegunn/fzf"
zplug load


HISTSIZE=1000000
SAVEHIST=1000000


## historyコマンドをヒストリリストから取り除く。
setopt hist_no_store
## すぐにヒストリファイルに追記する。
setopt inc_append_history
## 直前と同じコマンドをヒストリに追加しない
setopt hist_ignore_dups
## ヒストリを呼び出してから実行する間に一旦編集
setopt hist_verify
## コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space
# 他のターミナルとヒストリーを共有
setopt share_history
## zsh の開始, 終了時刻をヒストリファイルに書き込む
setopt extended_history

# 補完
autoload -Uz compinit
compinit
## The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'
## 補完候補を一覧表示
setopt auto_list
## TAB で順に補完候補を切り替える
setopt auto_menu
## 補完候補一覧でファイルの種別をマーク表示
setopt list_types
## カッコの対応などを自動的に補完
setopt auto_param_keys
## ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
## 補完候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1
## 補完候補の色づけ
export ZLS_COLORS=$LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
## 補完候補を詰めて表示
setopt list_packed
## スペルチェック
setopt correct
## ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs
## 最後のスラッシュを自動的に削除しない
setopt noautoremoveslash

## コアダンプサイズを制限
limit coredumpsize 102400
## 出力の文字列末尾に改行コードが無い場合でも表示
unsetopt promptcr
## ビープを鳴らさない
setopt nobeep
## 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs
## サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_resume
## cd 時に自動で push
setopt auto_pushd
## 同じディレクトリを pushd しない
setopt pushd_ignore_dups
## ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob
## =command を command のパス名に展開する
setopt equals
## --prefix=/usr などの = 以降も補完
setopt magic_equal_subst
## ファイル名の展開で辞書順ではなく数値的にソート
setopt numeric_glob_sort
## 出力時8ビットを通す
setopt print_eight_bit
## ディレクトリ名だけで cd
setopt auto_cd
## ドットなしでもドットファイルにマッチ
setopt globdots
## {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl

autoload -Uz colors
colors
zstyle ':completion:*' list-colors "${LS_COLORS}"

CURRENT_DIR="%{${fg[blue]}%}[%~]%{${reset_color}%}"

autoload -Uz vcs_info
setopt PROMPT_SUBST
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
 
# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..
 
# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

#Ctrl-Dでシェルからログアウトしない
setopt ignoreeof
 
# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'


function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    ls -alGt
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo
        echo -e "e[0;33m--- git status ---e[0m"
        git status -sb
    fi
    zle reset-prompt
    return 0
}
zle -N do_enter
bindkey '^m' do_enter

zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|jj?|lazygit|la|ll|ls|rm|rmdir)($| )" ]]
}

function peco-history-selection() {
    local selected_log=`history | tac | awk '!a[$0]++' | peco`
    if [ -n "$selected_log" ]; then
    BUFFER=`echo $selected_log | cut -d ' ' -f 6-`
    CURSOR=$#BUFFER
    zle reset-prompt
fi
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

function peco-src () {
  local selected_dir=$(ghq list -p | peco --prompt="repositories >" --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

export TEXT_BROWSER=w3m

function _space2p20 {
    echo $@ |sed -e "s/ /%20/g"
}

function _space2plus {
    echo $@ | sed -e "s/ /+/g"
}

function google {
    ${TEXT_BROWSER} "https://www.google.co.jp/search?q="`_space2plus $@`"&hl=ja"
}

function wikipedia {
    ${TEXT_BROWSER} "https://ja.wikipedia.org/wiki/"`_space2p20 $@`
}

function hatena {
    ${TEXT_BROWSER} "https://b.hatena.ne.jp/q/"`_space2p20 $@`"?target=text&users=3&date_range=5y&sort=recent&safe=on"
}

function amazon {
    ${TEXT_BROWSER} "https://www.amazon.co.jp/s?k="`_space2p20 $@`
}

function opengoogle() {
  local str opt
  if [ $# != 0 ]; then
    for i in $*; do
      str="$str+$i"
    done
    str=`echo $str | sed 's/^\+//'`
    opt='search?num=100&hl=ja&ie=utf-8&oe=utf-8&lr=lang_ja'
    opt="${opt}&q=${str}"
  fi
  browser https://www.google.co.jp/$opt
}

export FZF_DEFAULT_OPTS="--preview 'tree -C {} | head -200'"

autoload -U tetriscurses

## 全てのユーザのログイン・ログアウトを監視する。
watch="all"
## ログイン時にはすぐに表示する。
if (builtin log) >& /dev/null; then
  builtin log
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"
export PATH="/Library/TeX/texbin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin/:$PATH"


export XDG_CONFIG_HOME=~/.config
export PATH=$PATH:/path/to/Neovim/bin
export PATH=/usr/local/bin:$PATH
alias vi="nvim"
alias vim="nvim"
alias history="history -d -f 0"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias ls="ls -alGt"
alias du="du -h"
alias df="df -h"
alias zshrc="vi ~/.zshrc"
alias top="htop"
alias cat="ccat"
alias cpu="top -o cpu"
alias mem="top -o rsize"
alias find="fd"
alias aws="/usr/local/aws-cli/aws"
alias browser="open -a 'Google Chrome'"
alias -s txt=vi
alias -s php=vi
alias -s py=vi
alias -s pyc=vi
alias -s json=vi
alias -s csv=vi
alias tenki='() { curl -H "Accept-Language: ${LANG%_*}" wttr.in/"${1:-Tokyo}" }'
eval $(thefuck --alias)
