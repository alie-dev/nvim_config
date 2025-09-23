-- webdev.lua
-- 플러그인: cmp / treesitter / mason / mason-lspconfig / lspconfig / null-ls

return {
  -- 🔹 nvim-cmp (자동완성)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = { format = require("tailwindcss-colorizer-cmp").formatter },
      })
    end,
  },

  -- 🔹 Treesitter (문법 하이라이트/인덴트)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "typescript", "tsx", "javascript",
        "css", "html", "json", "lua", "bash", "markdown",
      },
      highlight = { enable = true },
      indent = { enable = true },
-- 🔹 Incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "-", -- 처음 선택 시작
      node_incremental  = "-", -- 더 큰 노드로 확장
      node_decremental  = "0", -- 다시 줄이기
      -- scope_incremental = "=", -- (원하면 스코프 단위 확장도 추가 가능)
    },
  },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- 🔹 JSX/HTML 자동 태그
  { "windwp/nvim-ts-autotag", event = "InsertEnter", config = true },

  -- 🔹 Mason (서버/툴 설치)
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
      -- mason/bin 경로 PATH에 보장(일부 셸에서 미인식 대비)
      if not string.find(vim.env.PATH or "", "mason/bin", 1, true) then
        vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. (vim.env.PATH or "")
      end
    end,
  },

  -- 🔹 mason-lspconfig (설치 연계)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "ts_ls",       -- Neovim 0.11+ typescript server 이름
        "tailwindcss",
        "eslint",
        "lua_ls",
      },
      automatic_installation = true,
    },
  },

  -- 🔹 LSP 설정 (lspconfig만 사용: 수동 vim.lsp.start() 제거)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")
      local caps = require("cmp_nvim_lsp").default_capabilities()

      local function on_attach(_, bufnr)
        local function map(m, lhs, rhs, desc)
          vim.keymap.set(m, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "LSP: Goto Definition")
        map("n", "<leader>rn", vim.lsp.buf.rename,      "LSP: Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
        map("n", "gr", vim.lsp.buf.references,          "LSP: References")

        -- Inlay hints (NVIM 0.11)
        if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
          pcall(vim.lsp.inlay_hint.enable, bufnr, true)
        end
      end

      -- TypeScript / JavaScript
      lspconfig.ts_ls.setup({
        capabilities = caps,
        on_attach = on_attach,
        root_dir = function(fname)
          return util.root_pattern("tsconfig.json", "package.json", ".git")(fname)
            or util.path.dirname(fname)
        end,
      })

      -- Tailwind CSS
      lspconfig.tailwindcss.setup({
        capabilities = caps,
        on_attach = on_attach,
        -- 기본 root_dir가 충분히 잘 동작. 별도 설정 불필요.
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = { "tw`([^`]*)", 'tw\\("([^"]*)', "tw\\('([^']*)" },
            },
          },
        },
      })

      -- ESLint (프로젝트 루트에서만 의미가 있으므로 root 없으면 자동으로 안 붙음)
      lspconfig.eslint.setup({
        capabilities = caps,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function() pcall(vim.cmd, "EslintFixAll") end,
          })
        end,
      })

      -- Lua (NVIM 설정 포함 케이스 대비: root_dir 폴백 확실히)
      lspconfig.lua_ls.setup({
        capabilities = caps,
        on_attach = on_attach,
        root_dir = function(fname)
          return util.root_pattern(
            ".luarc.json", ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml", "stylua.toml",
            "selene.toml", "selene.yml",
            ".git"
          )(fname) or util.path.dirname(fname) or vim.fn.getcwd()
        end,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = { enable = false },
          },
        },
      })
    end,
  },

  -- 🔹 Prettier/ESLint_d (none-ls)
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "jay-babu/mason-null-ls.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end,
      })
    end,
  },

  -- 🔹 mason-null-ls (툴 설치)
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = { "prettierd", "eslint_d" },
      automatic_installation = true,
    },
  },
}

