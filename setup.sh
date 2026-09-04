#!/usr/bin/env bash
#
# One-time setup for this Neovim config on a fresh machine. Safe to re-run.
#
#   1. Checks the system tools the config needs and prints what is missing.
#   2. Installs plugins at the versions pinned in lazy-lock.json (lazy.nvim
#      bootstraps itself on first start), including their build steps.
#   3. Installs the tree-sitter parsers and Mason packages listed in
#      lua/iryzhkov/deps.lua.
#   4. On Omarchy, links the theme-set hook so running instances re-theme
#      when the desktop theme changes.

set -euo pipefail

CONFIG_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MIN_NVIM="0.11.7"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# A headless nvim that loads this config even when run from elsewhere.
headless() {
  NVIM_APPNAME=${NVIM_APPNAME:-nvim} nvim --headless --cmd 'let g:nvim_setup = 1' "$@"
}

version_ge() {
  [[ $(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1) == "$2" ]]
}

log "Checking system tools"
command -v nvim >/dev/null || die "nvim not found"
nvim_version=$(nvim --version | sed -n '1s/^NVIM v\([0-9.]*\).*/\1/p')
version_ge "$nvim_version" "$MIN_NVIM" || die "Neovim $nvim_version found, need >= $MIN_NVIM"
echo "nvim $nvim_version"

# tool -> Arch package. git clones plugins; make/cc build telescope-fzf-native,
# LuaSnip's jsregexp and tree-sitter parsers; tree-sitter generates parsers
# that ship no parser.c; rg backs Telescope live_grep; fd backs find_files;
# clangd is the C/C++ language server (Mason has no aarch64 Linux build).
declare -A packages=(
  [git]=git
  [make]=make
  [cc]=gcc
  [tree-sitter]=tree-sitter-cli
  [rg]=ripgrep
  [fd]=fd
  [clangd]=clang
)
missing=()
for tool in "${!packages[@]}"; do
  if command -v "$tool" >/dev/null; then
    echo "$tool ok"
  else
    missing+=("${packages[$tool]}")
  fi
done
if (( ${#missing[@]} )); then
  echo "missing: ${missing[*]}"
  if command -v pacman >/dev/null; then
    echo "install with: sudo pacman -S --needed ${missing[*]}"
  fi
  die "install the missing tools and re-run"
fi

log "Installing plugins from lazy-lock.json"
headless "+Lazy! restore" +qa

log "Installing tree-sitter parsers"
headless \
  "+lua require('nvim-treesitter').install(require('iryzhkov.deps').parsers):wait(600000)" \
  +qa

log "Installing Mason packages"
headless +'lua
  local names = require("iryzhkov.deps").mason
  local registry = require("mason-registry")
  local pending = 0
  local function done()
    pending = pending - 1
    if pending == 0 then vim.cmd.qa() end
  end
  registry.refresh(function()
    for _, name in ipairs(names) do
      local package = registry.get_package(name)
      if package:is_installed() then
        print(name .. " ok")
      else
        pending = pending + 1
        print(name .. " installing")
        package:install():once("closed", vim.schedule_wrap(function()
          print(name .. (package:is_installed() and " installed" or " FAILED"))
          done()
        end))
      end
    end
    if pending == 0 then vim.cmd.qa() end
  end)
  vim.wait(600000, function() return false end)
  vim.cmd.qa()
'
echo

if [[ -d $HOME/.config/omarchy/hooks ]]; then
  log "Linking Omarchy theme-set hook"
  hook_dir=$HOME/.config/omarchy/hooks/theme-set.d
  mkdir -p "$hook_dir"
  ln -sfn "$CONFIG_DIR/omarchy/hooks/theme-set.d/neovim-reload" "$hook_dir/neovim-reload"
  echo "$hook_dir/neovim-reload -> $CONFIG_DIR/omarchy/hooks/theme-set.d/neovim-reload"
fi

log "Done. Run :checkhealth inside Neovim to verify."
