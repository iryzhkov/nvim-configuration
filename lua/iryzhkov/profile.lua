-- Which kind of machine this is.
--
-- "headless": a server whose Neovim exists only so the Huyang MCP server has
-- tree-sitter and language servers to work with. Everything a human at the
-- keyboard would want (completion, telescope, statusline, colors, ...) is
-- disabled: the plugins get `cond = false`, which keeps their lazy-lock.json
-- entries but neither installs nor loads them, and the after/plugin files
-- that configure them return early.
--
-- The profile is chosen by a marker file that setup.sh --headless writes
-- (gitignored, so one checkout serves both kinds of machine), or by
-- NVIM_PROFILE=headless in the environment for a one-off.
local M = {}

local marker = vim.fn.stdpath("config") .. "/.headless"
M.headless = vim.env.NVIM_PROFILE == "headless"
    or (vim.uv or vim.loop).fs_stat(marker) ~= nil

--- Mark a plugin spec as interactive-only.
---@param spec string|table
---@return table
function M.ui(spec)
    if type(spec) == "string" then
        spec = { spec }
    end
    spec.cond = not M.headless
    return spec
end

return M
