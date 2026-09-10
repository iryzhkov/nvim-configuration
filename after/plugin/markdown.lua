-- render-markdown.nvim: rendered headings, bullets, and code blocks in Markdown buffers.
local ok, rm = pcall(require, "render-markdown")
if not ok then
    return
end
rm.setup({
    file_types = { "markdown" },
    -- Render in normal and command mode; show raw markup on the insert line.
    render_modes = { "n", "c", "t" },
})
