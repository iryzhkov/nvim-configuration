# My NeoVim configuration

Based on [ThePrimeagen's NeoVim config](https://github.com/ThePrimeagen/init.lua),
managed with lazy.nvim. Colors follow the current
[Omarchy](https://omarchy.org) theme (see `lua/iryzhkov/theme.lua`).

## Setup

```sh
git clone <this repo> ~/.config/nvim
~/.config/nvim/setup.sh
```

`setup.sh` checks the required system tools, installs plugins at the versions
pinned in `lazy-lock.json`, installs the tree-sitter parsers and Mason packages
listed in `lua/iryzhkov/deps.lua`, and on Omarchy links the theme-set hook so
running instances re-theme on `omarchy theme set`. It is safe to re-run.

Requires Neovim 0.11.7+, git, make, a C compiler, tree-sitter-cli, ripgrep
and fd. On Arch: `sudo pacman -S --needed git make gcc tree-sitter-cli ripgrep fd`.
