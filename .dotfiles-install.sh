#!/bin/zsh

# A script to automatically download packages required by my dotfiles.

function command_exists {
    command -v "$@" > /dev/null
}

# Checks if command exists. Must pass the command NAME.
function chk_command {
    command_exists "$1" || {
        echo "Error: '$1' is not installed. Check your PATH." >&2
        exit 1
    }
}


################################################################################
#  Set up
################################################################################
# Check dependencies
chk_command "vim"
chk_command "awk"
chk_command "git"
chk_command "curl"
chk_command "zsh"
chk_command "ctags"

# Check dotfiles exist
if ! [[ -d "$HOME/.dotfiles" ]]; then
    echo "Error: dotfiles are not installed." >&2
    exit 1
fi

CURL="curl -sSL --proto-redir -all,https"


################################################################################
#  Install packages
################################################################################
# oh-my-zsh
if ! [[ -d "$HOME/.oh-my-zsh" ]]; then
    eval $CURL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended --keep-zshrc
else
    echo "oh-my-zsh! is already installed."
fi

# zplug
export ZPLUG_HOME="$HOME/.zplug"
export ZPLUG_INIT="$ZPLUG_HOME/init.zsh"
if ! [[ -f "$ZPLUG_INIT" ]]; then
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
else
    echo "zplug is already installed."
fi

# zplug plugins
# TODO: switch from here-string. It's a work around to zplug's incompatibility with pipes.
zsh <<< "source $HOME/.zshrc; zplug install"

# rust language
export CARGO_HOME="$HOME/.cargo"
if ! command_exists "cargo"; then
    if ! [[ -d "$CARGO_HOME" ]]; then
        eval $CURL https://sh.rustup.rs | sh -s -- -y
    fi
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "cargo is already installed."
fi

# rust packages
chk_command "cargo"
cargo install fd-find ripgrep bat

# vim plugins
vim +PlugUpdate +qall <<< "\n" > /dev/null
