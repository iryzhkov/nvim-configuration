-- Omarchy theme bridge.
--
-- `omarchy theme set <name>` writes a lazy.nvim spec for the theme's
-- colorscheme to ~/.local/state/omarchy/current/theme/neovim.lua (either the
-- theme's native plugin, or aether.nvim fed the theme's colors.toml). The
-- spec targets LazyVim: the colorscheme plugin entries are plain lazy.nvim
-- specs, and a trailing `LazyVim/LazyVim` entry carries the colorscheme
-- name in `opts.colorscheme`. This module splits the two so a non-LazyVim
-- config can use them.
--
-- Missing plugins are installed by lazy.nvim on the next startup
-- (`install.missing`), so switching to a theme that needs a new plugin only
-- costs one slow start.

local M = {}

M.path = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

--- Load the Omarchy spec, returning the plugin specs and colorscheme name.
--- Both are empty/nil when there is no current theme file or it fails to load.
---@return table plugins lazy.nvim plugin specs
---@return string|nil colorscheme
function M.load()
    local ok, spec = pcall(dofile, M.path)
    if not ok or type(spec) ~= "table" then
        return {}, nil
    end

    local plugins, colorscheme = {}, nil
    for _, plugin in ipairs(spec) do
        if plugin[1] == "LazyVim/LazyVim" then
            colorscheme = plugin.opts and plugin.opts.colorscheme
        else
            table.insert(plugins, plugin)
        end
    end
    return plugins, colorscheme
end

--- Plugin specs to include in `require("lazy").setup()`. Also records the
--- colorscheme name for `M.apply()`.
function M.plugins()
    local plugins, colorscheme = M.load()
    M.colorscheme = colorscheme
    return plugins
end

--- Activate the current theme's colorscheme. Falls back to Neovim's default
--- when nothing is active yet and the theme provides none, or its plugin is
--- not installed yet.
---@return boolean applied whether the theme colorscheme took effect
function M.apply()
    if M.colorscheme and pcall(vim.cmd.colorscheme, M.colorscheme) then
        return true
    end
    if not vim.g.colors_name then
        vim.cmd.colorscheme("default")
    end
    return false
end

--- Lua module a lazy.nvim spec resolves to, the way lazy.nvim derives it:
--- explicit `main`, else the repo name minus its `.nvim`/`-nvim`/`.lua` suffix.
local function main_module(plugin)
    if plugin.main then
        return plugin.main
    end
    local name = plugin.name or plugin[1]:match("[^/]+$")
    return (name:gsub("[.-]nvim$", ""):gsub("%.lua$", ""))
end

--- Re-read the theme file after `omarchy theme set` and re-theme this running
--- instance. Plugins already installed are re-configured with the new `opts`
--- (aether.nvim takes its palette that way); a plugin not installed yet is
--- left to the next startup, and the current colorscheme stays.
function M.reload()
    local plugins, colorscheme = M.load()
    M.colorscheme = colorscheme
    for _, plugin in ipairs(plugins) do
        if type(plugin.opts) == "table" then
            local ok, mod = pcall(require, main_module(plugin))
            if ok and type(mod) == "table" and type(mod.setup) == "function" then
                pcall(mod.setup, plugin.opts)
            end
        end
    end
    M.apply()
end

return M
