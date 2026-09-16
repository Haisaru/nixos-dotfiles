local langs = {
  "c",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "javascript",
  "html",
}

require("nvim-treesitter").install(langs)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  pattern = langs,
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
