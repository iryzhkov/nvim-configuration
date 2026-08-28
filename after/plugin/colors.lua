-- No Neovim-specific colorscheme: colors come from the terminal, which Omarchy
-- themes globally (`omarchy theme set <name>`). Switching the global theme
-- retheme Neovim too, with no config change here.
--
-- This requires `termguicolors = false` (see lua/iryzhkov/set.lua) so Neovim
-- renders through the terminal's 16-colour ANSI palette instead of hardcoded
-- 24-bit values.

local function inherit_terminal_colors()
    -- Let the terminal background show through instead of Neovim painting its own.
    for _, group in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" }) do
        vim.api.nvim_set_hl(0, group, { ctermbg = "NONE", bg = "NONE" })
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("InheritTerminalColors", { clear = true }),
    callback = inherit_terminal_colors,
})

inherit_terminal_colors()
