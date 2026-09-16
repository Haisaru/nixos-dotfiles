require("blink").setup({
  chartoggle = { enabled = false },
  tree = { enabled = false },
})

-- NOTE: these commands come from blink.nvim's tree module, which is disabled
-- above, so they currently do nothing. Flip `tree.enabled` to true to use them.
vim.keymap.set("n", "<C-e>", "<cmd>BlinkTree reveal<cr>", { desc = "Reveal current file in tree" })
vim.keymap.set("n", "<leader>E", "<cmd>BlinkTree toggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>e", "<cmd>BlinkTree toggle-focus<cr>", { desc = "Toggle file tree focus" })
