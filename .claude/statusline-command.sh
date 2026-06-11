#!/usr/bin/env bash
# Claude Code status line. Dir and git styling mirror Powerlevel10k;
# also shows the model (with reasoning effort) and context-window usage.

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten path: replace $HOME with ~, then truncate every component except the
# last to its first character (matches Powerlevel10k's truncate_from_right).
short_path() {
    local p="${1/#$HOME/~}"
    echo "$p" | awk -F'/' '{
        out = ""
        for (i = 1; i <= NF; i++) {
            seg = (i == NF || length($i) == 0) ? $i : substr($i, 1, 1)
            out = (i == 1) ? seg : out "/" seg
        }
        print out
    }'
}

# Folder icon mirrors p10k nerdfont-v3 dir segment (home / sub / etc / other)
case "$cwd" in
    "$HOME")        dir_icon=$'' ;;
    /etc|/etc/*)    dir_icon=$'' ;;
    "$HOME"/*)      dir_icon=$'' ;;
    *)              dir_icon=$'' ;;
esac
dir_part=$'\033[34m'"${dir_icon} $(short_path "$cwd")"$'\033[0m'

# Git section: branch + p10k-style status (⇣behind ⇡ahead *stash ~conflicted +staged !unstaged ?untracked)
git_part=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

    # File-state counts from a single porcelain call
    eval "$(git -C "$cwd" status --porcelain 2>/dev/null | awk '
        { x=substr($0,1,1); y=substr($0,2,1)
          if ($0 ~ /^\?\?/)                                            ut++
          else if (x=="U"||y=="U"||(x=="A"&&y=="A")||(x=="D"&&y=="D"))  cf++
          else { if (x!=" "&&x!="") st++; if (y!=" ") un++ } }
        END { printf "stg=%d uns=%d unt=%d cfl=%d", st+0, un+0, ut+0, cf+0 }')"

    # Commits ahead/behind upstream (empty if no upstream tracking branch)
    ab=$(git -C "$cwd" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    behind=${ab%%[!0-9]*}; ahead=${ab##*[!0-9]}
    : "${behind:=0}" "${ahead:=0}"
    stash=$(git -C "$cwd" stash list 2>/dev/null | grep -c '')

    # Whole git segment shares one state colour: green when clean (or only stashes
    # / untracked), yellow when staged/unstaged/conflicted. Only ~conflicted is red.
    # Markers are distinguished by symbol, not by colour.
    if (( stg || uns || cfl )); then base=$'\033[33m'; else base=$'\033[32m'; fi
    git_part="${base} ${branch}"

    (( behind )) && git_part+=" ⇣${behind}"
    (( ahead ))  && git_part+=" ⇡${ahead}"
    (( stash ))  && git_part+=" *${stash}"
    (( cfl ))    && git_part+=$'\033[31m'" ~${cfl}""${base}"
    (( stg ))    && git_part+=" +${stg}"
    (( uns ))    && git_part+=" !${uns}"
    (( unt ))    && git_part+=" ?${unt}"
    git_part+=$'\033[0m'
fi

# Context usage indicator: braille progress bar + percentage, colored by threshold
ctx_part=""
if [ -n "$used_pct" ]; then
    printf -v used_int "%.0f" "$used_pct"
    # Braille bar: each cell fills dot-by-dot bottom-up (left column, then right),
    # giving 6 sub-steps over a ⣀ baseline track. 5 cells = 30 levels.
    ramp=( $'⣀' $'⣄' $'⣆' $'⣇' $'⣧' $'⣷' $'⣿' )   # cell fill levels 0..6
    cells=5
    sub=6
    total=$(( cells * sub ))
    units=$(( (used_int * total + 50) / 100 ))   # rounded sub-steps, 0..total
    [ "$units" -gt "$total" ] && units=$total
    bar=""
    for (( i = 0; i < cells; i++ )); do
        u=$(( units - i * sub ))
        if   [ "$u" -le 0 ];    then bar+="${ramp[0]}"
        elif [ "$u" -ge "$sub" ]; then bar+="${ramp[sub]}"
        else                         bar+="${ramp[u]}"
        fi
    done
    icon=$'\U000F035B'   # nf-md-memory: context window = token memory
    if [ "$used_int" -ge 80 ]; then
        ctx_part=$'\033[31m'"${icon} ${bar} ${used_int}"$'%\033[0m'
    elif [ "$used_int" -ge 50 ]; then
        ctx_part=$'\033[33m'"${icon} ${bar} ${used_int}"$'%\033[0m'
    else
        ctx_part="${icon} ${bar} ${used_int}%"
    fi
fi

# Join non-empty segments with a dim vertical-bar divider
divider=$' \033[2m│\033[0m '
out=""
model_label="$model"
[ -n "$effort" ] && model_label="${model} · ${effort}"
model_part=$'\033[2m'"${model_label}"$'\033[0m'

for seg in "$dir_part" "$git_part" "$model_part" "$ctx_part"; do
    [ -z "$seg" ] && continue
    if [ -z "$out" ]; then
        out="$seg"
    else
        out="${out}${divider}${seg}"
    fi
done

printf "%s" "$out"
