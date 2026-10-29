require("conform").setup({
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
    -- Lean has no standalone formatter and its LSP doesn't implement
    -- formatting, so just clean up whitespace
    lean = { "trim_whitespace", "trim_newlines" },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
