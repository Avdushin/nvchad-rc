return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- === Markdown render (как в Obsidian) ===
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons", -- NvChad обычно уже имеет иконки
    },
    opts = {
      -- Оставляем дефолты — уже красиво работает.
      -- Если захочешь кастомную тему — могу сделать.
    },
  },
  -- === Multicursor (vim-visual-multi) ===
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.g.VM_maps = {
        ["Add Cursor Down"] = "<A-j>",
        ["Add Cursor Up"] = "<A-k>",

        ["Find Under"] = "<leader>n",
        ["Find Subword Under"] = "<leader>n",
        ["Select Next"] = "<leader>n",
        ["Select Prev"] = "<leader>N",
      }
    end,
  },
  -- === Images in Neovim ===
  {
    "3rd/image.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    build = false, -- чтобы не пытался собирать luarocks-рок
    opts = {
      -- backend = "ueberzug", -- для Alacritty
      backend = "kitty",
      processor = "magick_cli", -- дефолтный вариант через CLI ImageMagick

      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          only_render_image_at_cursor_mode = "popup", -- или "inline"
          floating_windows = false,
          filetypes = { "markdown" },
        },
      },

      max_width = 80,
      max_height = 40,
      max_width_window_percentage = 50,
      max_height_window_percentage = 50,
    },
  },
}
