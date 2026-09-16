if vim.fn.has("nvim-0.12") == 0 then
  vim.notify("vim.pack requires Neovim 0.12 or newer", vim.log.levels.ERROR)
  return
end

---------------------------------------------------------------------------
-- Build steps
---------------------------------------------------------------------------

-- PackChanged fires on install/update/delete of a plugin. It has to be
-- registered *before* vim.pack.add() or the first-install build is missed.
local build_cmds = {
  ["LuaSnip"] = { "make", "install_jsregexp" },
  ["blink.nvim"] = { "cargo", "build", "--release" },
}

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-build", { clear = true }),
  callback = function(ev)
    local data = ev.data
    if data.kind == "delete" then
      return
    end

    local cmd = build_cmds[data.spec.name]
    if cmd then
      vim.notify(("[pack] building %s"):format(data.spec.name))
      local res = vim.system(cmd, { cwd = data.path }):wait()
      if res.code ~= 0 then
        vim.notify(
          ("[pack] build failed for %s\n%s"):format(data.spec.name, res.stderr or ""),
          vim.log.levels.ERROR
        )
      end
    end

    -- nvim-treesitter's `build = ':TSUpdate'`
    if data.spec.name == "nvim-treesitter" then
      vim.schedule(function()
        local ok, ts = pcall(require, "nvim-treesitter")
        if ok then
          ts.update()
        end
      end)
    end
  end,
})

---------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------

vim.pack.add({
  -- shared dependencies first: vim.pack adds to 'runtimepath' and sources in
  -- list order, so anything required at load time must come before its users
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- colorscheme early so nothing renders with the default one first
  { src = "https://github.com/rebelot/kanagawa.nvim" },

  -- completion + snippets
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2") },
  { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1") },
  { src = "https://github.com/Saghen/blink.nvim" },
  { src = "https://github.com/Saghen/blink.indent" },

  -- lsp
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

  -- editor
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = "v3.x" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/RRethy/vim-illuminate" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },

  -- language / task specific
  { src = "https://github.com/xeluxee/competitest.nvim" },
  { src = "https://github.com/Julian/lean.nvim" },
})

---------------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------------

require("plugins")
require("vim-options")

---------------------------------------------------------------------------
-- Convenience commands
---------------------------------------------------------------------------

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update all plugins" })

vim.api.nvim_create_user_command("PackClean", function()
  local active = {}
  for _, p in ipairs(vim.pack.get()) do
    if not p.active then
      table.insert(active, p.spec.name)
    end
  end
  if #active == 0 then
    vim.notify("[pack] nothing to remove")
    return
  end
  vim.pack.del(active)
end, { desc = "Remove plugins no longer in the spec list" })
