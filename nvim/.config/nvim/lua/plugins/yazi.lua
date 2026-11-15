---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  version = '*', -- use the latest stable version
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '<leader>-',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      -- Open in the current working directory
      '<leader>cw',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
    {
      '<c-up>',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  ---@type YaziConfig | {}
  opts = {
    -- Keep netrw for directories (so :Ex / <leader>fe still work).
    -- If you set this to true, also add an init that sets
    -- vim.g.loaded_netrwPlugin = 1 (see mikavilpas/yazi.nvim#802).
    open_for_directories = false,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
