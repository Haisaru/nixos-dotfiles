local langs = {
  "c",
  "cpp",
  "haskell",
  "html",
  "javascript",
  "latex",
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

-- FileType names differ from parser names for a few languages
local filetypes = vim.list_extend(vim.deepcopy(langs), { "tex", "help" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  pattern = filetypes,
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
