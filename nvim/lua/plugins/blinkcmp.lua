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
  keymap = {
    preset = "super-tab",
    -- Same as the super-tab preset's <Tab>, but with an extra fallback: if
    -- there's no completion/snippet to act on and the cursor is right
    -- before a closing delimiter, jump over it instead of inserting a tab.
    ["<Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        end
        return cmp.select_and_accept()
      end,
      "snippet_forward",
      function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local next_char = line:sub(col + 1, col + 1)
        if next_char:match("[%)%]}\"'`]") then
          vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col + 1 })
          return true
        end
      end,
      "fallback",
    },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = { documentation = { auto_show = false } },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
