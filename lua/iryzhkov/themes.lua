-- Colorscheme plugins of the Omarchy themes, as Omarchy's own neovim.lua
-- files declare them (repo, `name`, `branch`), minus the per-theme `opts`
-- and `priority`, which theme.lua reads from the current theme when it is
-- applied.
--
-- theme.lua also scans the themes installed on the machine, so this list is
-- not what makes a theme work; it is what keeps lazy-lock.json the same on
-- every machine. A plugin that is only in the scan on one host (a newer
-- Omarchy, a user theme) would be in that host's lock and absent from the
-- others', and a headless server with no Omarchy at all would drop every
-- theme entry. Listing them here puts them in every host's spec, so lazy
-- keeps their lock entries even where they are switched off.
--
-- When a theme scan finds a plugin missing here, startup says so
-- (`:messages`); add the line it prints.
return {
    { "bjarneo/aether.nvim", name = "aether", branch = "v3" },
    { "bjarneo/hackerman.nvim", dependencies = { "bjarneo/aether.nvim" } },
    { "catppuccin/nvim", name = "catppuccin" },
    { "EdenEast/nightfox.nvim" },
    { "ellisonleao/gruvbox.nvim" },
    { "ficcdaf/ashen.nvim" },
    { "folke/tokyonight.nvim" },
    { "kepano/flexoki-neovim" },
    { "neanias/everforest-nvim" },
    { "OldJobobo/retro-82.nvim" },
    { "omacom-io/lumon.nvim" },
    { "rebelot/kanagawa.nvim" },
    { "ribru17/bamboo.nvim" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "tahayvr/matteblack.nvim" },
}
