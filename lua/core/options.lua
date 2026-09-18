local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.showmode = false
opt.laststatus = 3
opt.winborder = "rounded"

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 6
opt.sidescrolloff = 8

opt.splitbelow = true
opt.splitright = true
opt.equalalways = false

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.hlsearch = true

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true
opt.hidden = true

opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12

opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "…",
  precedes = "…",
}

opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = "╱",
}

opt.shortmess:append("I")

vim.filetype.add({
  filename = {
    [".env"] = "sh",
  },
  pattern = {
    [".*%.env%.[%w_.-]+"] = "sh",
  },
})
