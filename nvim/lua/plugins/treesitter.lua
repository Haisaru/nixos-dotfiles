local langs = {
  "c",
  "cpp",
  "haskell",
  "html",
  "javascript",
  "latex",
  "lean",
  "lua",
  "python",
  "query",
  "toml",
  "typescript",
  "vim",
  "vimdoc",
  "zig",
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
