return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      local treesitter = require('nvim-treesitter')

      -- Install the parsers you use.
      treesitter.install({
        'c',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'javascript',
        'html',
      })

      -- Enable Tree-sitter highlighting and indentation.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'c',
          'lua',
          'vim',
          'vimdoc',
          'query',
          'javascript',
          'html',
        },
        callback = function()
          vim.treesitter.start()

          vim.bo.indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
