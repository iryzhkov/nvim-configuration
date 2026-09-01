-- Tools installed on demand, shared by the runtime config and ./setup.sh.
--
-- Startup installs anything missing here in the background; setup.sh does
-- the same synchronously so a fresh machine is ready after one run.
return {
    -- nvim-treesitter parser names (after/plugin/treesitter.lua)
    parsers = {
        "bash",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "vimdoc",
    },

    -- Mason package names (after/plugin/lsp.lua; mason-lspconfig enables
    -- every installed server automatically)
    mason = {
        "lua-language-server",
    },
}
