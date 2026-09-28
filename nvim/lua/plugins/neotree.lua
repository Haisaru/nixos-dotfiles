require("neo-tree").setup({
  filesystem = {
    hijack_netrw_behavior = "open_current",
  },
})

vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle left<CR>")
