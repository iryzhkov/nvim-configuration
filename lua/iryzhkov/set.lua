vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true -- Omarchy theme colorschemes are 24-bit (see theme.lua)

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- When nvim is launched from the home directory (the SUPER+CTRL+N terminal
-- opens there), follow the first real file opened to its project root, so
-- telescope and other cwd-relative tools work on the project instead of all
-- of ~. Launches from inside a project keep their cwd untouched.
if vim.fn.getcwd() == vim.env.HOME then
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("iryzhkov_project_root", {}),
        callback = function()
            if vim.bo.buftype ~= "" or vim.fn.getcwd() ~= vim.env.HOME then
                return
            end
            local root = vim.fs.root(0, {
                ".git", "go.mod", "Cargo.toml", "package.json", "pyproject.toml",
            })
            if root and root ~= vim.env.HOME then
                vim.fn.chdir(root)
            end
        end,
    })
end

-- No remote-plugin providers are used; disabling them removes 6 checkhealth
-- warnings and skips the interpreter probing at startup.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
