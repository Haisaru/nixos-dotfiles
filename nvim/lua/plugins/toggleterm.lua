return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    --[[]
    local powershell_options = {
      shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
      shellcmdflag =
      "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
      shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
      shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
      shellquote = "",
      shellxquote = "",
    }

    for option, value in pairs(powershell_options) do
      vim.opt[option] = value
    end
    --]]

    require(
      'toggleterm'
    ).setup({
      size = 20,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        width = function()
          return math.ceil(
            vim.o.columns
              * 0.95
          )
        end,
        height = function()
          return math.ceil(
            vim.o.lines
              * 0.85
          )
        end,
      },
    })
    local Terminal =
      require(
        'toggleterm.terminal'
      ).Terminal
    local lazygit =
      Terminal:new({
        cmd = 'lazygit',
        hidden = true,
      })

    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    vim.api.nvim_set_keymap(
      'n',
      '<leader>gg',
      '<cmd>lua _LAZYGIT_TOGGLE()<CR>',
      {}
    )
  end,
}
