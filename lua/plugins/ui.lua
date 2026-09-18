local function winmove(direction)
  return function()
    vim.cmd("stopinsert")
    vim.cmd("wincmd " .. direction)
  end
end

local function close_picker(picker)
  picker:close()
end

local function project_replace(picker)
  local search = vim.trim(picker.input.filter.search or "")
  if search == "" then
    search = vim.trim(picker.input.filter.pattern or "")
  end

  picker:close()

  vim.schedule(function()
    local instance = require("grug-far").open({
      prefills = {
        search = search,
      },
    })

    if instance and instance.when_ready then
      instance:when_ready(function()
        pcall(function()
          instance:goto_input("replacement")
        end)
      end)
    end
  end)
end

return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      bigfile = { enabled = true },
      bufdelete = {},
      explorer = { enabled = true },
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = {
        enabled = true,

        actions = {
          window_left = winmove("h"),
          window_down = winmove("j"),
          window_up = winmove("k"),
          window_right = winmove("l"),
          close_sidebar = close_picker,
          project_replace = project_replace,
        },

        sources = {
          explorer = {
            -- Sidebar survives focus changes; Ctrl+B is its explicit toggle.
            auto_close = false,

            win = {
              input = {
                keys = {
                  -- Esc leaves Explorer alive instead of cancelling it.
                  ["<Esc>"] = { "toggle_focus", mode = { "n", "i" } },

                  -- Close the sidebar from either Explorer input or list.
                  ["<C-b>"] = { "close_sidebar", mode = { "n", "i" } },

                  -- Disable Snacks Explorer's default Ctrl+T terminal action.
                  ["<C-t>"] = "",

                  -- Window navigation while Explorer has focus.
                  ["<C-h>"] = { "window_left", mode = { "n", "i" } },
                  ["<C-j>"] = { "window_down", mode = { "n", "i" } },
                  ["<C-k>"] = { "window_up", mode = { "n", "i" } },
                  ["<C-l>"] = { "window_right", mode = { "n", "i" } },
                },
              },

              list = {
                keys = {
                  -- Empty string really disables the key. `false` would fall
                  -- back to another/default mapping.
                  ["<Esc>"] = "",
                  ["<C-t>"] = "",
                  ["<C-b>"] = "close_sidebar",

                  ["<C-h>"] = "window_left",
                  ["<C-j>"] = "window_down",
                  ["<C-k>"] = "window_up",
                  ["<C-l>"] = "window_right",
                },
              },
            },
          },

          grep = {
            win = {
              input = {
                keys = {
                  -- Ctrl+Shift+F opens grep as before. While it is open,
                  -- Ctrl+R transfers the current project search to GrugFar.
                  ["<C-r>"] = { "project_replace", mode = { "n", "i" } },
                },
              },
              list = {
                keys = {
                  ["<C-r>"] = "project_replace",
                },
              },
            },
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      terminal = {},
      words = { enabled = true },
      styles = {
        terminal = {
          wo = {
            winbar = "",
          },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code / copy" },
        { "<leader>f", group = "find" },
        { "<leader>m", group = "markdown" },
        { "<leader>s", group = "search / replace" },
        { "<leader>t", group = "terminal" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        numbers = "ordinal",
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        close_command = function(buffer)
          Snacks.bufdelete(buffer)
        end,
        right_mouse_command = function(buffer)
          Snacks.bufdelete(buffer)
        end,
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1,
          },
        },
      },
    },
  },
}
