local ts = require 'nvim-treesitter'

ts.setup {}

-- Parsers to keep installed. The `main` branch has no `auto_install`, so we
-- install anything missing at startup instead (a no-op once they are present).
local ensure_installed = {
    "bash",
    "lua",
    "markdown",
    "python",
    "vimdoc",
}

local installed = ts.get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(installed, lang)
end, ensure_installed)

if #missing > 0 then
    ts.install(missing)
end

-- The `main` branch no longer enables highlighting for you.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitter", {}),
    callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if lang and pcall(vim.treesitter.language.add, lang) then
            pcall(vim.treesitter.start, ev.buf, lang)
        end
    end,
})
