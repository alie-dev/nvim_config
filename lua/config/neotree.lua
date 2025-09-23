require("neo-tree").setup({
  close_if_last_window = true,

  event_handlers = {
    {
      event = "file_opened",
      handler = function()
        vim.defer_fn(function()
          require("neo-tree.command").execute({ action = "close" })
        end, 0)
      end,
    },
  },

  filesystem = {
    follow_current_file = { enabled = false }, -- 다시 열림 방지
    filtered_items = { hide_gitignored = false },
  },

  window = { width = 32 },
})

