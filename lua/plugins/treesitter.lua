return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter.setup({})

      local parsers = {
        "bash",
        "c",
        "css",
        "diff",
        "dockerfile",
        "gitcommit",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      vim.schedule(function()
        pcall(function()
          treesitter.install(parsers)
        end)
      end)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "css",
          "dockerfile",
          "gitcommit",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "html",
          "javascript",
          "javascriptreact",
          "json",
          "json5",
          "jsonc",
          "lua",
          "markdown",
          "python",
          "rust",
          "sh",
          "toml",
          "typescript",
          "typescriptreact",
          "vim",
          "yaml",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
