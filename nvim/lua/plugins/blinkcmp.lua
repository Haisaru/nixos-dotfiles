-- LuaSnip (the `make install_jsregexp` build runs from the PackChanged hook)
require("luasnip.loaders.from_lua").load({
  paths = vim.fn.stdpath("config") .. "/snippets",
})

require("luasnip").setup({
  enable_autosnippets = true,
  store_selection_keys = "<Tab>",
})

require("blink.cmp").setup({
  -- 'default' (recommended) for mappings similar to built-in completions
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  --
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = { preset = "default" },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = { documentation = { auto_show = false } },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
