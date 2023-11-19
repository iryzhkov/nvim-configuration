require('lualine').setup({
    options = {
        theme = 'seoul256',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },

        refresh = {
            statusline = 200,
            tabline = 1000,
            winbar = 1000,
        },
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'filename'},
        lualine_c = {'diff'},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {'filename'},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {
        lualine_a = {},
        lualine_b = {'buffers'},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {'branch'},
        lualine_z = {'hostname'}
    },
})
