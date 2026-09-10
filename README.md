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

Requires Neovim 0.11.7+, git, make, a C compiler, tree-sitter-cli, ripgrep,
fd and Go. On Arch:
`sudo pacman -S --needed git make gcc tree-sitter-cli ripgrep fd go`.

### Servers

`setup.sh --headless` sets up a machine where nobody edits interactively and
Neovim exists only as Huyang's semantic provider with tree-sitter and language
servers. The interactive plugins (completion, telescope, harpoon,
statusline, colorschemes, ...) are neither installed nor loaded there; they
keep their `lazy-lock.json` entries, so the lock file is identical on every
machine. The choice is a gitignored `.headless` marker (`NVIM_PROFILE=headless`
does the same for one run); re-running `setup.sh` without the flag turns the
machine back into a workstation.

## Colors

The colorscheme follows the current Omarchy theme. Every installed theme's
colorscheme plugin is in the lazy.nvim spec, lazy-loaded, so `omarchy theme
set` re-themes running instances through the linked hook without a network
round trip, and switching themes never touches `lazy-lock.json`. A theme
added later (in `~/.config/omarchy/themes`) is picked up on the next start.

## Huyang

[Huyang](https://github.com/iryzhkov/huyang) is installed separately as a user
service and MCP adapter. This Neovim configuration supplies parsers, language
servers, formatters, and debugger adapters; it no longer installs an agent plugin
or registers a harness endpoint.
