vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "fog-and-ember"

local c = {
  bg = "#1B222C",
  bg_dark = "#151A22",
  bg_deep = "#11141A",

  bg1 = "#202833",
  bg2 = "#26303B",
  bg3 = "#303946",
  selection = "#3B4854",

  fg = "#EAE6DD",
  fg_soft = "#D5D4CE",
  fg_bright = "#F3F0E8",

  grey = "#46515D",
  grey_search = "#59616C",
  grey_muted = "#727D89",
  grey_comment = "#82909B",
  grey_light = "#94AEBB",

  red = "#CF6C73",
  green = "#82A184",
  yellow = "#D0A35D",
  blue = "#86A5B6",
  purple = "#A7849B",
  cyan = "#8DAFB1",

  bright_red = "#E1848A",
  bright_green = "#9DB79F",
  bright_yellow = "#E3BD75",
  bright_blue = "#94AEBB",
  bright_purple = "#C09AAF",
  bright_cyan = "#9AB8BA",

  cursor = "#7895A6",
  ember = "#BF8950",
}

local function set(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Core UI
set("Normal", { fg = c.fg, bg = c.bg })
set("NormalNC", { fg = c.fg_soft, bg = c.bg })
set("NormalFloat", { fg = c.fg, bg = c.bg_dark })
set("FloatBorder", { fg = c.grey, bg = c.bg_dark })
set("FloatTitle", { fg = c.bright_yellow, bg = c.bg_dark, bold = true })
set("WinSeparator", { fg = c.grey, bg = c.bg })
set("Cursor", { fg = c.bg, bg = c.cursor })
set("CursorLine", { bg = c.bg1 })
set("CursorColumn", { bg = c.bg1 })
set("CursorLineNr", { fg = c.bright_yellow, bold = true })
set("LineNr", { fg = c.grey })
set("SignColumn", { fg = c.grey_muted, bg = c.bg })
set("ColorColumn", { bg = c.bg1 })
set("EndOfBuffer", { fg = c.bg })
set("NonText", { fg = c.grey })
set("Whitespace", { fg = c.grey })

-- Selection / search
set("Visual", { bg = c.selection, fg = c.fg_bright })
set("Search", { bg = c.grey_search, fg = c.fg_bright })
set("IncSearch", { bg = c.ember, fg = c.bg_deep, bold = true })
set("CurSearch", { bg = c.ember, fg = c.bg_deep, bold = true })
set("MatchParen", { bg = c.selection, fg = c.bright_yellow, bold = true })

-- Popup menu
set("Pmenu", { fg = c.fg, bg = c.bg1 })
set("PmenuSel", { fg = c.fg_bright, bg = c.selection, bold = true })
set("PmenuSbar", { bg = c.bg2 })
set("PmenuThumb", { bg = c.grey_muted })

-- Status / tabs
set("StatusLine", { fg = c.fg, bg = c.bg1 })
set("StatusLineNC", { fg = c.grey_muted, bg = c.bg_dark })
set("TabLine", { fg = c.grey_muted, bg = c.bg_dark })
set("TabLineSel", { fg = c.fg_bright, bg = c.bg2, bold = true })
set("TabLineFill", { bg = c.bg_dark })
set("WinBar", { fg = c.fg_soft, bg = c.bg })
set("WinBarNC", { fg = c.grey_muted, bg = c.bg })

-- Syntax
set("Comment", { fg = c.grey_comment, italic = true })
set("String", { fg = c.green })
set("Character", { fg = c.green })
set("Number", { fg = c.ember })
set("Float", { fg = c.ember })
set("Boolean", { fg = c.bright_red })
set("Constant", { fg = c.ember })
set("Identifier", { fg = c.fg_soft })
set("Function", { fg = c.blue })
set("Statement", { fg = c.purple })
set("Keyword", { fg = c.purple })
set("Conditional", { fg = c.purple })
set("Repeat", { fg = c.purple })
set("Operator", { fg = c.cursor })
set("Type", { fg = c.yellow })
set("StorageClass", { fg = c.yellow })
set("Structure", { fg = c.yellow })
set("Typedef", { fg = c.yellow })
set("PreProc", { fg = c.bright_purple })
set("Include", { fg = c.purple })
set("Special", { fg = c.bright_cyan })
set("Delimiter", { fg = c.grey_light })
set("Directory", { fg = c.blue })
set("Title", { fg = c.bright_yellow, bold = true })

-- Treesitter
set("@comment", { fg = c.grey_comment, italic = true })
set("@string", { fg = c.green })
set("@string.escape", { fg = c.bright_cyan })
set("@function", { fg = c.blue })
set("@function.call", { fg = c.blue })
set("@function.method", { fg = c.blue })
set("@keyword", { fg = c.purple })
set("@keyword.function", { fg = c.purple })
set("@type", { fg = c.yellow })
set("@type.builtin", { fg = c.bright_yellow })
set("@number", { fg = c.ember })
set("@boolean", { fg = c.bright_red })
set("@property", { fg = c.cyan })
set("@operator", { fg = c.cursor })
set("@punctuation.bracket", { fg = c.fg_soft })
set("@punctuation.delimiter", { fg = c.grey_light })

-- Diagnostics
set("DiagnosticError", { fg = c.red })
set("DiagnosticWarn", { fg = c.yellow })
set("DiagnosticInfo", { fg = c.blue })
set("DiagnosticHint", { fg = c.cyan })
set("DiagnosticVirtualTextError", { fg = c.red, bg = c.bg1 })
set("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.bg1 })
set("DiagnosticVirtualTextInfo", { fg = c.blue, bg = c.bg1 })
set("DiagnosticVirtualTextHint", { fg = c.cyan, bg = c.bg1 })

-- Git
set("GitSignsAdd", { fg = c.green })
set("GitSignsChange", { fg = c.yellow })
set("GitSignsDelete", { fg = c.red })

-- Snacks
set("SnacksNormal", { fg = c.fg, bg = c.bg })
set("SnacksNormalNC", { fg = c.fg_soft, bg = c.bg })
set("SnacksPickerBorder", { fg = c.grey, bg = c.bg_dark })
set("SnacksPickerTitle", { fg = c.bright_yellow, bold = true })
set("SnacksPickerMatch", { fg = c.bright_yellow, bold = true })
set("SnacksPickerDir", { fg = c.blue })
set("SnacksPickerFile", { fg = c.fg })
set("SnacksPickerListCursorLine", { bg = c.selection })

-- Bufferline
set("BufferLineFill", { bg = c.bg_dark })
set("BufferLineBackground", { fg = c.grey_muted, bg = c.bg_dark })
set("BufferLineBufferSelected", { fg = c.fg_bright, bg = c.bg, bold = true })
set("BufferLineIndicatorSelected", { fg = c.ember, bg = c.bg })

-- Which-key
set("WhichKey", { fg = c.blue })
set("WhichKeyGroup", { fg = c.yellow })
set("WhichKeyDesc", { fg = c.fg })
set("WhichKeySeparator", { fg = c.grey })
