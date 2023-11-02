# dotfiles
[![CI](https://github.com/dhnza/dotfiles/actions/workflows/main.yml/badge.svg)](https://github.com/dhnza/dotfiles/actions/workflows/main.yml)


## Installation


### Automatic

Run the automatic installation script:
```sh
curl -Ls https://gist.github.com/dhnza/6b384f52ce32342761cc00f9d26311fa/raw/dotfiles-init.sh | /bin/bash
```


### Manual

Clone dotfiles into a bare git repository. The git tracking information will be stored in `~/.dotfiles`.
```sh
git clone --bare git@github.com:dhnza/dotfiles.git ~/.dotfiles
```

For convenience, create a `dotfiles` alias for managing the repository.

```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Disable showing files not tracked by the git repository,
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


## Dependencies

My configuration expects the following packages are installed.

- [vim](https://www.vim.org/download.php)
- [zsh](http://www.zsh.org)
    - [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
    - [zplug](https://github.com/zplug/zplug)
- [cargo](https://www.rust-lang.org/learn/get-started) (Rust package manager)
    - `fd-find`
    - `ripgrep`
    - `bat`
    - `git-delta`
    - `exa`
    - `zoxide`
    - `navi`
- [universal-ctags](https://github.com/universal-ctags/ctags)

To install (most of) these automatically, run the `.dotfiles-install.sh` script included in this repository.


## Additional Configuration

Some tools require additional manual configuration, as described below.


### iTerm2

See [iTerm2 preferences](../.config/iterm2/profile/README.md) for details on how to load and sync iTerm2 preferences with the files tracked by this repository.


## Sources

1. https://www.anand-iyer.com/blog/2018/a-simpler-way-to-manage-your-dotfiles.html
2. https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo
