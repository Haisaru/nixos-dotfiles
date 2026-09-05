return {
  'lervag/vimtex',
  ft = 'tex',
  init = function()
    -- vim.g.vimtex_view_general_viewer = "SumatraPDF"
    vim.g.vimtex_view_general_viewer =
      'zathura'
  end,
}
