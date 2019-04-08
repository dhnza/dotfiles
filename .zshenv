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
SRC="$HOME/.zshenv.${HOST%%[0-9]}"
if [[ -f "${SRC}" ]]; then
    source "${SRC}"
fi
