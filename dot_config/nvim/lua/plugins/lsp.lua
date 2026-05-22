local function has_eslint_config(ctx)
  return vim.fs.find({
    ".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
    ".eslintrc.yaml", ".eslintrc.yml", ".eslintrc.json",
    "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
  }, { path = ctx.filename, upward = true })[1]
end

local function has_prettier_config(ctx)
  return vim.fs.find({
    ".prettierrc", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs",
    ".prettierrc.json", ".prettierrc.json5", ".prettierrc.yaml", ".prettierrc.yml",
    "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs",
    "prettier.config.ts", "prettier.config.cts", "prettier.config.mts",
  }, { path = ctx.filename, upward = true })[1]
end

local function has_biome_config(ctx)
  return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1]
end

return {
  -- tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "css-lsp",
        "astro-language-server",
        "prettierd",
        "prettier",
        "eslint_d",
        "biome",
        "black",
        "isort",
        "flake8",
        "ruff",
        "markdownlint-cli2",
        "markdown-toc",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "json5", "jsonc", "markdown" },
    },
  },
  -- for yaml schema support?
  { "b0o/SchemaStore.nvim" },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      ---@type lspconfig.options
      servers = {
        tailwindcss = {
          root_markers = { ".git" },
        },
        vtsls = {
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = { only = { "source.organizeImports.ts" }, diagnostics = {} },
                })
              end,
              desc = "Organize Imports",
            },
          },
          settings = {
            javascript = {
              inlayHints = {
                variableTypes = { enabled = true },
              },
            },
          },
        },
        biome = {
          keys = {
            {
              "<leader>ca",
              function()
                local ctx = { filename = vim.api.nvim_buf_get_name(0) }
                if has_eslint_config(ctx) then
                  vim.lsp.buf.code_action()
                else
                  vim.lsp.buf.code_action({
                    context = { only = { "source.fixAll.biome", "quickfix", "refactor", "source" } },
                  })
                end
              end,
              desc = "Code Action",
            },
          },
        },
        eslint = {
          validate = "On",
          format = false,
        },
        html = {},
        jsonls = {
          before_init = function(_, config)
            config.settings = config.settings or {}
            config.settings.json = config.settings.json or {}
            config.settings.json.schemas = config.settings.json.schemas or {}
            vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
          filetypes = { "json", "jsonc", "tmpl" },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              format = true, -- let prettier handle yaml
            },
          },
        },
        ty = {},
        ruff = {
          init_options = {
            settings = {
              args = {},
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      setup = {},
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["biome"] = {
          condition = function(_, ctx)
            return not has_prettier_config(ctx)
          end,
        },
        ["eslint_d"] = {
          condition = function(_, ctx)
            return has_eslint_config(ctx) ~= nil
          end,
        },
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        typescriptreact = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        typescript = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        javascript = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
        json = { "biome", "prettierd", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        zsh = { "shfmt", stop_after_first = true },
      },
    },
  },
}
