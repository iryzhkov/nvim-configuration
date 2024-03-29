vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_HelpLine = 0
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_WindowLayout = 2

vim.keymap.set("n", "<leader><C-u>", vim.cmd.UndotreeFocus)
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
