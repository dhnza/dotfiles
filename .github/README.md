# dotfiles 

## Installation

### Automatic

Run the automatic installation script:
```sh
curl -Ls https://gist.github.com/DeoxNA/6b384f52ce32342761cc00f9d26311fa/raw/dotfiles-install.sh | /bin/bash
```

### Manual

Clone dotfiles into a bare git repository. The git tracking information will be stored in `~/.dotfiles`.
```sh
git clone --bare git@github.com:DeoxNA/dotfiles.git ~/.dotfiles
```

For convenience, create a `dotfiles` alias for managing the repositroy.

```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Disable showing files not tracked by the git repositry,
```sh
dotfiles config --local status.showUntrackedFiles no
```

Backup your existing configuration into `~/.dotfiles-backup`.
```sh
mkdir -p ~/.dotfiles-backup && dotfiles checkout 2>&1 | egrep '\s+\.' | xargs -i mv {} ~/.dotfiles-backup
```

Checkout your dotfiles to your `$HOME`:
```sh
dotfiles checkout 
```

## Sources

1. https://www.anand-iyer.com/blog/2018/a-simpler-way-to-manage-your-dotfiles.html
2. https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/
