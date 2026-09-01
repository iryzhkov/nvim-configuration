local ts = require 'nvim-treesitter'

ts.setup {}

-- Parsers to keep installed. The `main` branch has no `auto_install`, so we
-- install anything missing at startup instead (a no-op once they are present).
-- setup.sh installs the same list synchronously and sets `g:nvim_setup` so the
-- two do not race on the same parser.
local ensure_installed = require("iryzhkov.deps").parsers

local installed = ts.get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(installed, lang)
end, ensure_installed)

if #missing > 0 and not vim.g.nvim_setup then
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
