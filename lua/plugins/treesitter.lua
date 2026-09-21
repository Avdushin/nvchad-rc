return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter.setup({})


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
