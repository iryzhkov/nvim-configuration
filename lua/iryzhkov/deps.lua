-- Tools installed on demand, shared by the runtime config and ./setup.sh.
--
-- Startup installs anything missing here in the background; setup.sh does
-- the same synchronously so a fresh machine is ready after one run.
--
-- What belongs here is the languages actually worked in on these machines,
-- because they are also what the agent99 MCP server needs to be useful: its
-- symbol tools read structure from a tree-sitter parser and meaning from a
-- language server, and with neither it degrades to grep. Anything not listed
-- can still be added per-machine at the moment it is needed, with agent99's
-- install_language(); moving a language up here is for the ones that recur
-- often enough to be worth every fresh install paying for them.
return {
    -- nvim-treesitter parser names (after/plugin/treesitter.lua)
    parsers = {
        "bash",
        "c",
        "cpp",
        "diff",
        "go",
        "gomod",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        -- the omarchy-* desktop widgets are QML; no server is listed for it
        -- because qmlls needs a Qt installation that these machines may not
        -- have, and the parser alone already carries the symbol tools
        "qmljs",
        "toml",
        -- TypeScript needs both: .tsx files are a separate grammar
        "tsx",
        "typescript",
        "vimdoc",
        "yaml",
    },

    -- Mason package names (after/plugin/lsp.lua; mason-lspconfig enables
    -- every installed server automatically). These are Mason's own package
    -- names, which are not always the lspconfig name: the TypeScript server
    -- is typescript-language-server here and ts_ls there.
    --
    -- clangd is deliberately absent: Mason has no aarch64 Linux build, so it
    -- comes from the system `clang` package and lsp.lua enables it by hand.
    mason = {
        "bash-language-server",
        "gopls",
        "lua-language-server",
        "pyright",
        "typescript-language-server",
        -- Debug adapters for agent99's debugger tools, one per language
        -- served above (Go, Python, JavaScript/TypeScript); C/C++ use the
        -- system gdb, and Java's jdtls + java-debug-adapter stay on demand
        -- through install_debugger() because they need a JDK.
        "delve",
        "debugpy",
        "js-debug-adapter",
    },
}
