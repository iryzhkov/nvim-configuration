-- Omarchy theme bridge.
--
-- Every Omarchy theme ships a lazy.nvim spec for its colorscheme in
-- <theme>/neovim.lua (either the theme's native plugin, or aether.nvim fed the
-- theme's colors.toml), and `omarchy theme set <name>` points
-- ~/.local/state/omarchy/current/theme at the chosen one. The spec targets
-- LazyVim: the colorscheme plugin entries are plain lazy.nvim specs, and a
-- trailing `LazyVim/LazyVim` entry carries the colorscheme name in
-- `opts.colorscheme`. This module splits the two so a non-LazyVim config can
-- use them.
--
-- The plugin spec handed to lazy.nvim is the union of *every* installed
-- theme's plugins, marked lazy, not just the current theme's. lazy.nvim loads
-- a lazy colorscheme plugin the moment `:colorscheme` asks for one of its
-- colors, so this costs nothing at startup, and it keeps lazy-lock.json the
-- same on every machine whatever theme each one is showing: with only the
-- current theme in the spec, each `omarchy theme set` rewrote the lock file
-- and the hosts' checkouts disagreed on it forever. It also means a theme
-- switch never needs the network or a restart, since the plugin is already
-- cloned.

local M = {}

M.path = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

-- Where Omarchy keeps its themes and where user-added ones go.
M.theme_dirs = {
    vim.fn.expand("~/.local/share/omarchy/themes"),
    vim.fn.expand("~/.config/omarchy/themes"),
}

--- Read one theme spec file, returning the plugin specs and colorscheme name.
--- Both are empty/nil when the file is missing or fails to load.
---@param path string
---@return table plugins lazy.nvim plugin specs
---@return string|nil colorscheme
local function read_spec(path)
    local ok, spec = pcall(dofile, path)
    if not ok or type(spec) ~= "table" then
        return {}, nil
    end
    local plugins, colorscheme = {}, nil
    for _, plugin in ipairs(spec) do
        if type(plugin) == "string" then
            plugin = { plugin }
        end
        if type(plugin) == "table" then
            if plugin[1] == "LazyVim/LazyVim" then
                colorscheme = plugin.opts and plugin.opts.colorscheme
            else
                table.insert(plugins, plugin)
            end
        end
    end
    return plugins, colorscheme
end

--- The current theme's plugin specs and colorscheme name.
---@return table plugins
---@return string|nil colorscheme
function M.load()
    return read_spec(M.path)
end

--- Plugin specs of every installed theme, each marked lazy, for lazy.setup().
--- Also records the current theme's colorscheme for apply().
---@return table plugins
function M.plugins()
    local _, colorscheme = M.load()
    M.colorscheme = colorscheme

    local all, seen = {}, {}
    for _, dir in ipairs(M.theme_dirs) do
        for _, file in ipairs(vim.fn.glob(dir .. "/*/neovim.lua", true, true)) do
            for _, plugin in ipairs((read_spec(file))) do
                plugin.lazy = true
                plugin.priority = nil -- meaningless on a lazy plugin
                local key = plugin.name or plugin[1]
                -- The same repo can appear under several themes (catppuccin
                -- and catppuccin-latte). lazy.nvim merges duplicate specs,
                -- but one entry per repo keeps the spec readable in :Lazy.
                if not seen[key] then
                    seen[key] = true
                    table.insert(all, plugin)
                end
            end
        end
    end
    -- The current theme may live outside the theme dirs (a one-off written by
    -- hand); make sure its plugins are in the spec too.
    for _, plugin in ipairs((M.load())) do
        local key = plugin.name or plugin[1]
        if not seen[key] then
            seen[key] = true
            plugin.lazy = true
            plugin.priority = nil
            table.insert(all, plugin)
        end
    end
    return all
end

--- Apply the recorded colorscheme, falling back to the default when there
--- is none or it fails. Returns true when the theme's colorscheme took.
---@return boolean
function M.apply()
    if M.colorscheme and pcall(vim.cmd.colorscheme, M.colorscheme) then
        return true
    end
    if not vim.g.colors_name then
        vim.cmd.colorscheme("default")
    end
    return false
end

--- The Lua module a plugin's setup() lives in, the way lazy.nvim guesses it
--- (`main`, else the repo name minus a .nvim/-nvim/.lua suffix).
---@param plugin table
---@return string
local function main_module(plugin)
    if plugin.main then
        return plugin.main
    end
    local name = plugin.name or plugin[1]:match("[^/]+$")
    return (name:gsub("[.-]nvim$", ""):gsub("%.lua$", ""))
end

--- Re-read the current theme and apply it to this running instance. Called
--- by the omarchy theme-set hook over --remote-expr. The theme's plugins are
--- already in the spec (see plugins()), so loading them is a local operation;
--- lazy.nvim runs their `opts` setup on load.
---@return boolean
function M.reload()
    local plugins, colorscheme = M.load()
    M.colorscheme = colorscheme
    local ok_lazy, lazy = pcall(require, "lazy")
    if ok_lazy then
        local names = {}
        for _, plugin in ipairs(plugins) do
            table.insert(names, plugin.name or plugin[1]:match("[^/]+$"))
        end
        if #names > 0 then
            pcall(lazy.load, { plugins = names })
        end
    end
    -- Two themes can share a plugin with different `opts` (every aether-based
    -- theme is aether.nvim fed its own colors), and lazy.nvim ran setup with
    -- whichever theme's opts came first. Re-run it with the current theme's.
    for _, plugin in ipairs(plugins) do
        if type(plugin.opts) == "table" then
            local ok, mod = pcall(require, main_module(plugin))
            if ok and type(mod) == "table" and type(mod.setup) == "function" then
                pcall(mod.setup, plugin.opts)
            end
        end
    end
    return M.apply()
end

return M
