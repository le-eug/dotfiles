-- See `:help vim.o` and `:help option-list`

-- [[ Indentation ]]
local function set_indent(width, use_tabs)
  vim.opt.tabstop = width
  vim.opt.softtabstop = width
  vim.opt.shiftwidth = width
  vim.opt.expandtab = not use_tabs
end

-- Default
set_indent(4, false)

-- Per-filetype overrides
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp', 'go' },
  callback = function()
    set_indent(4, true)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'html',
    'css',
    'markdown',
  },
  callback = function()
    set_indent(2, false)
  end,
})

-- [[ Editor ]]
-- vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false -- already shown in the statusline

-- Sync clipboard with the OS. Scheduled because it can slow down startup.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true

-- Case-insensitive search unless \C or a capital letter is used
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

-- Show certain whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview :substitute live
vim.o.inccommand = 'split'

vim.o.cursorline = true
vim.o.scrolloff = 10
vim.opt.colorcolumn = '80'

-- Ask to save instead of failing on things like :q with unsaved changes
vim.o.confirm = true
