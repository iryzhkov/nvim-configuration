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

    -- agent99: agentic edits with LSP-backed tools (github.com/iryzhkov/agent99).
    -- Keymaps live in opts.keymaps so they are easy to look up here;
    -- provider presets: deepseek (default), openai, openrouter, ollama, claude.
    -- The build step also produces bin/agent99-bridge, which is the MCP
    -- server other agents (Claude Code) use to reach this Neovim; setup.sh
    -- registers it.
    {
        'iryzhkov/agent99',
        build = 'make build',
        -- nvim-dap backs agent99's debugger tools (debug_launch, ...); the
        -- MCP server advertises them only with debug.enabled below.
        dependencies = { 'mfussenegger/nvim-dap' },
        opts = {
            debug = { enabled = true },
            -- claude runs on the Max subscription (no per-token cost); the chat
            -- panel cannot use it (no transcript from claude -p) and falls back
            -- to chat_provider automatically (deepseek key: keyring, :Agent99SetKey).
            provider = 'claude',
            chat_provider = 'deepseek',
            -- Apply edits directly instead of opening a confirmation preview.
            preview = false,
            keymaps = {
                auto = '<leader>99',            -- x: compose, model infers edit/ask
                compose = '<leader>99',         -- n: reopen compose draft
                edit = '<leader>9e',            -- x: compose, hardcoded edit
                ask = '<leader>9a',             -- x: compose, hardcoded ask
                chat = '<leader>9c',            -- n: toggle chat panel
                chat_selection = '<leader>9c',  -- x: panel with selection as context
                followup = '<leader>9f',        -- n: follow up on last edit/answer
                cancel = '<leader>9x',          -- n: cancel request
                history = '<leader>9h',         -- n: request history
                record = '<leader>9r',          -- n: re-open last record view
                logs = '<leader>9l',            -- n: view logs
            },
        },
    },

    -- rendered markdown (headings, bullets, code-block borders); picks up
    -- the agent99 chat panel automatically since it is a markdown buffer
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
