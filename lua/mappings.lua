require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Toggle file tree with Ctrl+b
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Format code on Ctrl+Shift+I
map("n", "<C-S-i>", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format code" })

-- Toggle bottom terminal with Ctrl+~
map({ "n", "t" }, "<C-`>", function()
  require("nvchad.term").toggle {
    pos = "sp", -- horizontal split (bottom)
    size = 0.3, -- 30% высоты окна, можешь поменять
  }
end, { desc = "Toggle bottom terminal" })

-- File search like VS Code: Ctrl + P
map("n", "<C-p>", function()
  require("telescope.builtin").find_files {
    find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
  }
end, { desc = "Find files via ripgrep" })

-- Jump to buffer N (like tabs 1..9)
for i = 1, 9 do
  map("n", "<C-" .. i .. ">", function()
    local bufs = vim.t.bufs or {}
    if bufs[i] then
      vim.api.nvim_set_current_buf(bufs[i])
    end
  end, { desc = "Go to buffer " .. i })
end

map("n", "<C-n>", function()
  vim.cmd "enew" -- создать новый пустой буфер
end, { desc = "New buffer" })

-- New buffer (tab) on Ctrl + N
map("n", "<C-n>", function()
  vim.cmd "enew"
end, { desc = "New buffer" })

-- Close current buffer (tab) on Ctrl + W
map("n", "<C-w>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })

-- Copy relative path of current file to clipboard (Alt + Shift + C)
map("n", "<leader>c", function()
  local path = vim.fn.expand "%"

  if path == "" then
    vim.notify("Текущий буфер не связан с файлом", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", path) -- системный буфер
  vim.fn.setreg("*", path) -- буфер X11/Wayland (на всякий)
  vim.notify("Скопирован путь: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative file path" })

-- Duplicate current line down
map("n", "<leader>d", "yyp", { desc = "Duplicate line down" })

-- map("n", "V", "V", { noremap = true, silent = true, desc = "Line visual mode" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
