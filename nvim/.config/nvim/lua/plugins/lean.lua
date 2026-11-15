return {
  'Julian/lean.nvim',
  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
  -- lean.nvim no longer has a setup() function; it reads vim.g.lean_config instead
  init = function()
    vim.g.lean_config = {
      mappings = true, -- turns on the default keybindings
    }
  end,
}
