-- lazy.nvim bootstrap + plugin spec (replaces the old packer.lua).
--
-- Plugin *configuration* still lives in after/plugin/*.lua. Nothing here is
-- lazy-loaded except the colorschemes, so every plugin is on the runtimepath
-- by the time those files are sourced, exactly as it worked under packer.
--
-- Plugins wrapped in `ui()` are for a human at the keyboard and are switched
-- off on a headless machine (see profile.lua). They keep their lazy-lock.json
-- entries either way, so the lock file is the same on every host.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Failed to clone lazy.nvim:\n" .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

local theme = require("iryzhkov.theme")
local ui = require("iryzhkov.profile").ui

require("lazy").setup({
    -- nvim look
    ui 'nvim-tree/nvim-web-devicons',
    ui 'nvim-lualine/lualine.nvim',

    -- colorschemes of every installed Omarchy theme, lazy-loaded on
    -- :colorscheme; the current one is applied by after/plugin/colors.lua
    vim.tbl_map(ui, theme.plugins()),

    -- telescope
    ui {
        'nvim-telescope/telescope.nvim',
        -- NOT a tagged release: every tag through 0.1.7 calls the removed
        -- `nvim-treesitter.parsers.ft_to_lang`. master uses
        -- `vim.treesitter.language.get_lang`. Needs nvim >= 0.11.7.
        branch = 'master',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    ui { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    ui 'camgraff/telescope-tmux.nvim',

    -- harpoon
    ui 'theprimeagen/harpoon',

    -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        -- after/plugin/treesitter.lua is written against the `main` rewrite
        -- (ts.setup/get_installed/install, no `configs` module). Pinned so a
        -- change to the repo's default branch can't silently break it.
        branch = 'main',
        build = ':TSUpdate',
    },

    -- lsp
    'neovim/nvim-lspconfig',
    -- feeds lua_ls the Neovim runtime + plugin type definitions
    'folke/lazydev.nvim',
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',

    -- completion
    ui 'hrsh7th/cmp-buffer',
    ui 'hrsh7th/cmp-nvim-lsp',
    ui 'hrsh7th/cmp-path',
    ui 'hrsh7th/nvim-cmp',
    ui 'onsails/lspkind.nvim',

    -- snippets
    ui {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp',
    },
    ui 'saadparwaiz1/cmp_luasnip',

    -- version control
    ui 'tpope/vim-fugitive',
    ui 'mbbill/undotree',


    -- rendered markdown (headings, bullets, and code-block borders)
    ui 'MeanderingProgrammer/render-markdown.nvim',
}, {
    change_detection = { notify = false },
    performance = {
        rtp = {
            -- `<leader>pv` opens netrw (vim.cmd.Ex), so it must stay enabled.
            disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
        },
    },
})
