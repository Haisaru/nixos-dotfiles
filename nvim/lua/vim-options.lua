vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.conceallevel = 0
vim.opt.undofile = true
vim.opt.fileencoding = "utf-8"
vim.opt.signcolumn = "yes"
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.clipboard = "unnamedplus"
vim.loader.enable()
vim.opt.autochdir = true

-- vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>", { silent = true })

vim.keymap.set("n", "<leader>se", ":setlocal spell spelllang=en_us<cr>", { desc = "spelling en", noremap = true })
vim.keymap.set("n", "<leader>sd", ":setlocal nospell<cr>", { desc = "spelling disable", noremap = true })

-- vim.g.plenary_curl_bin_path = "C:\\Users\\jason\\AppData\\Local\\Microsoft\\WinGet\\Links\\curl.exe"

vim.keymap.set('n', '<leader>bf', function() vim.lsp.buf.format({ async = true }) end)
