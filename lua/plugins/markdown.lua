return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
    keys = {
      {
        "<leader>mt",
        "<cmd>RenderMarkdown toggle<cr>",
        desc = "Toggle Markdown rendering",
      },
      {
        "<leader>me",
        "<cmd>RenderMarkdown enable<cr>",
        desc = "Enable Markdown rendering",
      },
      {
        "<leader>md",
        "<cmd>RenderMarkdown disable<cr>",
        desc = "Disable Markdown rendering",
      },
    },
  },
}
