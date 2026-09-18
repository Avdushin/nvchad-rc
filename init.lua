vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("core.options")
require("core.autocmds")
require("core.keymaps")
require("core.lazy")

vim.cmd.colorscheme("fog-and-ember")
