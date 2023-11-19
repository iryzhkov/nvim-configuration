function ColorMyPencils(color) 
	color = color or "nordfox"
	vim.cmd.colorscheme(color)
end

ColorMyPencils()
