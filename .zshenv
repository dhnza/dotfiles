#==============================================================================
#  Environment Variables
#==============================================================================
# Use vim as default editor in git and other programs
export VISUAL=vim
export EDITOR="$VISUAL"

#==============================================================================
#  Custom environment
#==============================================================================
# Load custom environment for this host
HOST=$(hostname -s)
SRC="$HOME/.zshenv.$(sed 's/\([a-zA-Z]\)[0-9]$/\1/' <<< $HOST)"
if [[ -f "${SRC}" ]]; then
    source "${SRC}"
fi

