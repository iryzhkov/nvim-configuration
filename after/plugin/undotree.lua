vim.g.undotree_DiffAutoOpen = 0
vim.g.undotree_SetFocusWhenToggle = 1
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader><C-u>", vim.cmd.UndotreeFocus)
vim.g.undotree_HelpLine = 0
