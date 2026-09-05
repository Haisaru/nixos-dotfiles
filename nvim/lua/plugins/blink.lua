return {
  'saghen/blink.nvim',
  build = 'cargo build --release',
  keys = {
    -- tree
    { '<C-e>',     '<cmd>BlinkTree reveal<cr>',       desc = 'Reveal current file in tree' },
    { '<leader>E', '<cmd>BlinkTree toggle<cr>',       desc = 'Reveal current file in tree' },
    { '<leader>e', '<cmd>BlinkTree toggle-focus<cr>', desc = 'Toggle file tree focus' },
  },
  lazy = false,
  opts = {
    chartoggle = { enabled = false },
    tree = { enabled = false },
  }
}
