return {
  -- Mason: LSP server installer
  {
    "williamboman/mason.nvim",
    priority = 100,
    build = ":MasonUpdate", -- Updates registry contents
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          },
          check_outdated_packages_on_open = false, -- Disable to prevent EPIPE
        },
        PATH = "prepend",
        pip = {
          upgrade_pip = false,
        },
        max_concurrent_installers = 1, -- Install one at a time to avoid EPIPE
      })
    end,
  },

  -- Mason-LSPconfig: Bridge between Mason and vim.lsp
  {
    "williamboman/mason-lspconfig.nvim",
    priority = 99,
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Only list servers you want auto-installed
        ensure_installed = {
          "lua_ls",
          "pyright", 
          "ts_ls",
          "html",
          "cssls",
        },
        automatic_installation = false, -- Disable auto to avoid EPIPE, install manually
      })
    end,
  },
}
