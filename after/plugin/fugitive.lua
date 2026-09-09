if require("iryzhkov.profile").headless then return end

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
