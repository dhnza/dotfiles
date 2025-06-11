#==============================================================================
#  Bootstrap
#==============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Start oh-my-zsh
source $ZSH/oh-my-zsh.sh

#==============================================================================
#  Functions
#==============================================================================
## fgst - pick files from `git status -s`
## Source: https://github.com/junegunn/fzf/wiki/Examples
is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
}

fgst() {
    # "Nothing to see here, move along"
    is_in_git_repo || return

    local cmd="${FZF_CTRL_T_COMMAND:-"command git status -s"}"

    eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" fzf -m "$@" | while read -r item; do
        echo "$item" | awk '{print $2}'
    done
    echo
}

#==============================================================================
#  Aliases
#==============================================================================
# Use dotfiles command to manage the dotfiles repo
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias ls='eza'
alias ll='eza -lF --git --icons=auto'
alias l='eza -alF --git --icons=auto'
alias tree='eza --tree'

alias bcl='bc -l'
alias grin='grep -rin'
alias batp='bat -p'
alias g-='git log --graph --color --oneline --decorate'
alias g-a='git log --graph --color --oneline --decorate --all'
alias gdo='git diff origin/$(git rev-parse --abbrev-ref HEAD)'
alias todos='rg -p -A 2 TODO'

alias squeuel="squeue -o '%.18i %.9P %.8j %.8u %.8T %.10M %.10l %.10L %.20S %.20e %.5D %R'"
alias sqnext='squeuel -u $USER | (IFS=""; read -r line; echo "$line"; sort -k 10)'

#==============================================================================
#  Plugins
#==============================================================================
#------------------------------------------------
#    ZPLUG
#------------------------------------------------
source ~/.zplug/init.zsh

# Let zplug manage itself
zplug 'zplug/zplug', hook-build: 'zplug --self-manage'

# Load oh-my-zsh plugins
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/dircycle", from:oh-my-zsh
zplug "plugins/fancy-ctrl-z", from:oh-my-zsh
zplug "plugins/fzf", from:oh-my-zsh

# Third-party plugins
zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "supercrabtree/k"

# Install plugins if there are any that have not been installed
if ! zplug check --verbose && [[ -o  interactive ]]; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

#------------------------------------------------
#    Plugin Configuration
#------------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
# For coloring man pages
export GROFF_NO_SGR=1

#==============================================================================
#  FZF
#==============================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use fd for file and directory search
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --follow --exclude .git"

# Syntax hihglighting in preview window
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {}'"

# Show directory contents with 'eza --tree'
export FZF_ALT_C_OPTS="--preview 'eza --tree {} | head -200'"

# Use fd for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

#==============================================================================
#  Navi
#==============================================================================
# Load navi shell widget
eval "$(navi widget zsh)"

#==============================================================================
#  Zoxide
#==============================================================================
# Load zoxide zsh integration
eval "$(zoxide init zsh)"

# Use 'eza --tree' in fzf preview
_ZO_FZF_PREVIEW='awk "{print \$2}" <<< {} | xargs eza --tree | head -100'
export _ZO_FZF_OPTS="--layout=reverse --height=40% --preview '$_ZO_FZF_PREVIEW'"

#==============================================================================
#  Powerlevel10k
#==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Shorten prompt paths
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

# Customize left promopt
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs prompt_char)

#==============================================================================
#  Custom .zshrc
#==============================================================================
# Load custom .zshrc for this host
HOST=$(hostname -s)
SRC="$HOME/.zshrc.$(sed 's/\([a-zA-Z]\)[0-9]$/\1/' <<< $HOST)"
if [[ -f "${SRC}" ]]; then
    source "${SRC}"
fi
