return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- 상태바
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- LSP
  { "neovim/nvim-lspconfig" },

  -- 문제 리스트
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- 파일 트리 (Neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- 버퍼라인
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Git signs
  { "lewis6991/gitsigns.nvim" },
}
