return {
  {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope.nvim", -- Optional for session browsing
    },
    config = function()
      require("auto-session").setup({
        auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        -- This ensures that if you start nvim without arguments, it restores the session
        auto_restore_enabled = true,
        auto_session_use_git_branch = nil,
      })
    end,
  },
}
