-- See `:help lua-guide-autocommands`

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Don't continue comments when starting a new line from a comment,
-- except C/C++ /* */ blocks (VS Code style ` * ` continuation; // comments still don't continue)
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    if args.match == 'c' or args.match == 'cpp' then
      require('config.c_comments').attach(args.buf)
      require('config.clang_format').apply(args.buf)
    else
      vim.opt_local.formatoptions:remove { 'r', 'o' }
    end
  end,
})
