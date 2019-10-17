#==============================================================================
#  Bootstrap
#==============================================================================
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="agnoster"

# Start oh-my-zsh
source $ZSH/oh-my-zsh.sh

#==============================================================================
#  Plugins 
#==============================================================================
#------------------------------------------------
#    ZPLUG
#------------------------------------------------
source ~/.zplug/init.zsh

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

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi  
fi

# Then, source plugins and add commands to $PATH
zplug load

#------------------------------------------------
#    Powerlevel10k
#------------------------------------------------
# Only show hostname in context
POWERLEVEL9K_CONTEXT_TEMPLATE="@%m"

# Shorten prompt paths
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

# Customize git repository segment
POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-remotebranch git-tagname)

# Customize left promopt
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda context dir vcs)

# Customize right promopt
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)

#------------------------------------------------
#    Other Plugin Configuration
#------------------------------------------------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
# For coloring man pages
export GROFF_NO_SGR=1 


#==============================================================================
#  FZF 
#==============================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use fd for file and directory search
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

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
    git status -s | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%}\
        --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" fzf -m "$@" | awk '{print $2}'
}

# Fixes vim tab completion
fix_vim() {
    rm $ZSH_COMPDUMP
    rm -f $ZPLUG_HOME/zcompdump
    exec zsh
}

#==============================================================================
#  Aliases 
#==============================================================================
# Use dotfiles command to manage the dotfiles repo
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias ll='ls -lhF'
alias bcl='bc -l'
alias grin='grep -rin'
alias git-graph='git log --graph --color --oneline --decorate'
alias g-='git-graph'
alias gdo='git diff origin/$(git rev-parse --abbrev-ref HEAD)'

#==============================================================================
#  Custom .zshrc
#==============================================================================
# Load custom .zshrc for this host
HOST=$(hostname -s)
SRC="$HOME/.zshrc.${HOST%%[0-9]}"
if [[ -f "${SRC}" ]]; then
    source "${SRC}"
fi
