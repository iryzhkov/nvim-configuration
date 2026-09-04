-- Tools installed on demand, shared by the runtime config and ./setup.sh.
--
-- Startup installs anything missing here in the background; setup.sh does
-- the same synchronously so a fresh machine is ready after one run.
return {
    -- nvim-treesitter parser names (after/plugin/treesitter.lua)
    parsers = {
        "bash",
        "c",
        "cpp",
        "diff",
        "go",
        "gomod",
        "javascript",
        "jsdoc",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "tsx",
        "typescript",
        "vimdoc",
    },

    -- Mason package names (after/plugin/lsp.lua; mason-lspconfig enables
    -- every installed server automatically). clangd is not here: Mason has
    -- no aarch64 Linux build, so it comes from the system `clang` package
    -- and lsp.lua enables it by hand.
    mason = {
        "gopls",
        "lua-language-server",
        "pyright",
        "typescript-language-server",
    },
}
