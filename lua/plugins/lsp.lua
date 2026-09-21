local servers = {
  "bashls",
  "cssls",
  "eslint",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "pyright",
  "rust_analyzer",
  "taplo",
  "ts_ls",
  "yamlls",
}

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    lazy = false,
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "enter" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
        },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {
          ui = { border = "rounded" },
        },
      },
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
    opts = {
      ensure_installed = servers,
      automatic_enable = true,
    },
    config = function(_, opts)
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {
          capabilities = capabilities,
        })
      end

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim", "Snacks" } },
            runtime = { version = "LuaJIT" },
            telemetry = { enable = false },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
            validate = true,
          },
        },
      })

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      require("mason-lspconfig").setup(opts)
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "goimports",
        "prettierd",
        "ruff",
        "shfmt",
        "stylua",
      },
      auto_update = false,
      -- The standalone bootstrap installs tools explicitly. Avoid starting a
      -- second background Mason installation in headless bootstrap sessions.
      run_on_start = vim.env.NVIM_BOOTSTRAP ~= "1",
      start_delay = 2500,
      debounce_hours = 24,
    },
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        underline = true,
        virtual_text = {
          spacing = 2,
          source = "if_many",
        },
        float = {
          border = "rounded",
          source = true,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("NvimConfigLsp", { clear = true }),
        callback = function(args)
          local map = function(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, {
              buffer = args.buf,
              silent = true,
              desc = desc,
            })
          end

          map("gd", function()
            Snacks.picker.lsp_definitions()
          end, "Goto definition")
          map("gD", function()
            Snacks.picker.lsp_declarations()
          end, "Goto declaration")
          map("gr", function()
            Snacks.picker.lsp_references()
          end, "References")
          map("gI", function()
            Snacks.picker.lsp_implementations()
          end, "Implementations")
          map("gy", function()
            Snacks.picker.lsp_type_definitions()
          end, "Type definition")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ss", function()
            Snacks.picker.lsp_symbols()
          end, "Document symbols")
          map("<leader>sS", function()
            Snacks.picker.lsp_workspace_symbols()
          end, "Workspace symbols")
          map("<leader>cl", "<cmd>LspInfo<cr>", "LSP information")
          map("<leader>uh", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = args.buf })
          end, "Toggle inlay hints")
        end,
      })
    end,
  },
}
