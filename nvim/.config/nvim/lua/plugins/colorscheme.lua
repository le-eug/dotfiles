return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000, -- load before other plugins
  opts = {},
  config = function()
    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
