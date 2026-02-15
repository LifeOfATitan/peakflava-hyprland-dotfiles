return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Keymap to toggle the sidebar with Ctrl+n
    vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { desc = 'Toggle Neo-tree' })
    vim.keymap.set('n', '<C-b>', ':Neotree buffers<CR>', { desc = 'Open Neo-tree buffers'})

    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = true, -- This shows hidden files in the sidebar
          hide_dotfiles = false,
        }
      }
    })
  end
}

