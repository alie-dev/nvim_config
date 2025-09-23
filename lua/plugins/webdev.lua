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
    -- 더 이상: local lspconfig = require("lspconfig")  ← ❌
    local util = require("lspconfig.util")  -- 유틸은 그대로 사용 가능
    local caps = require("cmp_nvim_lsp").default_capabilities()

    -- TypeScript / JavaScript
    vim.lsp.config("ts_ls", {
  capabilities = caps,
  single_file_support = true,  -- 루트 못 잡아도 붙게
  cmd = { vim.fn.exepath("typescript-language-server"), "--stdio" }, -- 실행파일 확실히 고정
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_dir = function(fname)
    -- 1) 보편 루트
    local root = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(fname)
               or util.find_git_ancestor(fname)
               or util.path.dirname(fname)
    -- 디버그 출력
    vim.schedule(function()
      vim.notify("[ts_ls] root_dir = " .. (root or "nil") .. " (file=" .. fname .. ")", vim.log.levels.INFO)
    end)
    return root
  end,
  on_init = function(client, _)
    vim.schedule(function()
      vim.notify("[ts_ls] started: " .. table.concat(client.config.cmd or {}, " "), vim.log.levels.INFO)
    end)
  end,
})

    -- Tailwind CSS
    vim.lsp.config("tailwindcss", {
      capabilities = caps,
      on_attach = on_attach,
      settings = {
        tailwindCSS = {
          experimental = {
            -- 역따옴표/따옴표 이스케이프 주의
            classRegex = { "tw`([^`]*)", 'tw%("([^"]*)', "tw%('([^']*)" },
          },
        },
      },
    })

    -- ESLint
    vim.lsp.config("eslint", {
      capabilities = caps,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function() pcall(vim.cmd, "EslintFixAll") end,
        })
      end,
      root_dir = function(fname)
        return util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
                                 ".eslintrc.json", "package.json", ".git")(fname)
          or util.path.dirname(fname)
      end,
    })

    -- Lua (lua_ls)
    vim.lsp.config("lua_ls", {
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

    -- 실제로 서버들을 켜기
    for _, name in ipairs({ "ts_ls", "tailwindcss", "eslint", "lua_ls" }) do
      vim.lsp.enable(name)
    end
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

