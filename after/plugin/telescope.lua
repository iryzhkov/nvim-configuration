require('telescope').setup({
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                                            -- the default case_mode is "smart_case"
        }
    }
})
require('telescope').load_extension('fzf')
require('telescope').load_extension('tmux')

local builtin = require('telescope.builtin')

-- simple mappings

vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>rs', builtin.resume, {})
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

-- complex mappings

vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find({
        prompt_title = "Search in File",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
    })
end, {})

vim.keymap.set('n', '<leader>nv', function()
    builtin.find_files({
        prompt_title = "NVim Config",
        cwd = "~/.config/nvim/",
    })
end, {})
