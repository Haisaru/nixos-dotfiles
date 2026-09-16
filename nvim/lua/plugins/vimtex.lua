-- vimtex was `ft = 'tex'` under lazy.nvim. vim.pack can reproduce that:
-- `load = false` clones the plugin into pack/*/opt without sourcing it, then
-- :packadd pulls it in on the first tex buffer.

-- vim.g.vimtex_view_general_viewer = "SumatraPDF"
vim.g.vimtex_view_general_viewer = "sioyek"

vim.pack.add({
  { src = "https://github.com/lervag/vimtex" },
}, { load = false })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vimtex-load", { clear = true }),
  pattern = "tex",
  once = true,
  callback = function()
    vim.cmd.packadd("vimtex")
  end,
})
