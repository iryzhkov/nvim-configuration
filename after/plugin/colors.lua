-- Colors come from the current Omarchy theme (`omarchy theme set <name>`),
-- whose generated colorscheme spec is loaded by lua/iryzhkov/theme.lua.
-- Running instances keep the old colors; new ones pick up the new theme.

local theme = require("iryzhkov.theme")

local function inherit_terminal_background()
    -- Let the terminal background show through instead of Neovim painting its
    -- own, so the terminal's opacity rule still applies.
    for _, group in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" }) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("InheritTerminalBackground", { clear = true }),
    callback = inherit_terminal_background,
})

theme.apply()
