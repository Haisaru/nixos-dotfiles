require("neo-tree").setup({
  hijack_netrw_behaviour = "open_current",
})

vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle left<CR>")
