require("lualine").setup({
  options = {
    theme = "everforest",
    disabled_filetypes = {
      "neo-tree",
    },
    ignore_focus = {
      "dapui_watches",
      "dapui_breakpoints",
      "dapui_scopes",
      "dapui_console",
      "dapui_stacks",
      "dap-repl",
    },
  },
})
