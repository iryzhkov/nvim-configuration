-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
-- `vim.diagnostic.goto_prev/goto_next` are deprecated (removal in 0.13);
-- `jump` replaces them. `float = true` keeps the old auto-float behaviour.
vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = true }
end)
vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = true }
end)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist)


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<leader>K', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

-- lazydev feeds lua_ls the Neovim runtime + plugin type definitions on demand,
-- so `vim.*` and `require "telescope.builtin"` resolve instead of being `unknown`.
-- Must run before lua_ls attaches.
local ok_lazydev, lazydev = pcall(require, 'lazydev')
if ok_lazydev then
    lazydev.setup {
        library = {
            -- vim.uv is a separate meta definition
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
    }
end

-- Mason set-up
--
-- mason-lspconfig v2 dropped `setup_handlers`. With Neovim 0.11+ it now calls
-- `vim.lsp.enable()` for every installed server automatically, so per-server
-- settings go through `vim.lsp.config` instead of a handler table.
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {},
})

-- Advertise nvim-cmp's completion capabilities to every server. `vim.lsp.config`
-- with '*' merges into all configs, including the ones mason-lspconfig enables.
local ok_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok_cmp_lsp then
    vim.lsp.config('*', {
        capabilities = cmp_lsp.default_capabilities(),
    })
end

-- clangd comes from the system `clang` package (Mason ships no aarch64 Linux
-- build), so mason-lspconfig does not know about it and it is enabled here.
if vim.fn.executable('clangd') == 1 then
    vim.lsp.enable('clangd')
end

-- qmlls also ships with Qt itself rather than with Mason, and Qt installs it
-- in a directory that is not on PATH, so it is resolved by hand as well.
-- Without this, editing the omarchy-* QML plugins gets a tree-sitter outline
-- and no diagnostics at all.
local qmlls = vim.fn.exepath('qmlls')
if qmlls == '' then
    for _, candidate in ipairs({
        '/usr/lib/qt6/bin/qmlls',
        '/usr/lib64/qt6/bin/qmlls',
        '/usr/lib/qt6/libexec/qmlls',
        '/opt/homebrew/share/qt/bin/qmlls',
    }) do
        if vim.fn.executable(candidate) == 1 then
            qmlls = candidate
            break
        end
    end
end

if qmlls ~= '' then
    -- -E adds QML_IMPORT_PATH, and ~/.local/share/qml-imports is where this
    -- machine keeps import roots that live outside the project. An Omarchy
    -- shell plugin imports `qs.Commons`, whose module root is the shell's own
    -- source directory, so that directory is symlinked in there as `qs`.
    -- Without it every Color and Style reference resolves to nothing and the
    -- real diagnostics drown in unqualified-access noise.
    local cmd = { qmlls, '-E', '--no-cmake-calls' }
    local imports = vim.fn.expand('~/.local/share/qml-imports')
    if vim.fn.isdirectory(imports) == 1 then
        vim.list_extend(cmd, { '-I', imports })
    end

    vim.lsp.config('qmlls', {
        cmd = cmd,
        -- manifest.json covers an Omarchy plugin edited in place under
        -- ~/.config/omarchy/plugins/, a plugin root that has no .git.
        root_markers = { '.qmlls.ini', 'manifest.json', '.git' },
    })
    vim.lsp.enable('qmlls')
end
-- make sure lua doesn't highlight vim as unknown
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            completion = {
                -- Expand a completed function into a call snippet with the
                -- parameters as jumpable placeholders (<C-L>/<C-J> to move).
                -- "Replace" = one item, the snippet; "Both" = plain + snippet.
                callSnippet = "Replace",
            },
            diagnostics = {
                globals = { "vim" }
            }
        }
    }
})


-- linter set-up
-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--     callback = function()
--         require("lint").try_lint()
--     end,
-- })
