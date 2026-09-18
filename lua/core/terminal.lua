local M = {}

local function snacks()
  if not _G.Snacks then
    vim.notify("Snacks.nvim is not loaded yet", vim.log.levels.WARN)
    return nil
  end
  return _G.Snacks
end

local function toggle(count, win)
  local s = snacks()
  if not s then
    return
  end

  s.terminal.toggle(nil, {
    count = count,
    cwd = vim.fn.getcwd(),
    win = win,
  })
end

function M.bottom()
  toggle(1, {
    position = "bottom",
    height = 0.32,
    border = "top",
  })
end

function M.right()
  toggle(2, {
    position = "right",
    width = 0.36,
    border = "left",
  })
end

function M.float()
  toggle(3, {
    position = "float",
    width = 0.90,
    height = 0.85,
    border = "rounded",
  })
end

function M.new_bottom()
  vim.cmd("botright 15new")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

function M.tab()
  vim.cmd("tabnew")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

function M.list()
  local s = snacks()
  if not s then
    return
  end

  local terminals = s.terminal.list()
  if #terminals == 0 then
    vim.notify("No terminal sessions", vim.log.levels.INFO)
    return
  end

  local items = {}
  for index, terminal in ipairs(terminals) do
    local title
    if type(terminal.cmd) == "table" then
      title = table.concat(terminal.cmd, " ")
    elseif type(terminal.cmd) == "string" and terminal.cmd ~= "" then
      title = terminal.cmd
    else
      title = vim.o.shell
    end
    items[index] = {
      text = string.format("%d. %s", index, title),
      terminal = terminal,
    }
  end

  vim.ui.select(items, {
    prompt = "Terminal sessions",
    format_item = function(item)
      return item.text
    end,
  }, function(item)
    if item and item.terminal then
      item.terminal:show()
    end
  end)
end

return M
