-- Linting (runs on enter, save and leaving insert mode)
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      -- markdown = { 'markdownlint' },
    }

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      callback = function()
        -- Skip read-only buffers like LSP hover popups
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
