return {
	{
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      require("ayu").setup({
        mirage = false,
        overrides = {},
      })
      vim.cmd.colorscheme("ayu")
    end,
  }
}
