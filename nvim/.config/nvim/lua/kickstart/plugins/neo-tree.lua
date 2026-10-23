-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        width = 40,
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
  init = function()
    -- Neotree show on open and automatically select write buffer first
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.cmd 'Neotree show'
        vim.cmd 'wincmd p'
      end,
    })
    -- Auto close neotree when it is last buffer open
    vim.api.nvim_create_autocmd('BufEnter', {
      nested = true,
      callback = function()
        if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == 'neo-tree' then
          vim.cmd 'quit'
        end
      end,
    })
  end,
}
