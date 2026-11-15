-- Autoformat on save, and <leader>f to format manually
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  init = function()
    -- gq: use conform if this filetype has a formatter, else LSP range
    -- formatting, else Vim's normal text wrapping. (Without this, Go's
    -- built-in formatprg pipes only the selected lines to gofmt, which
    -- fails on partial code.) gw always does plain text wrapping.
    function _G.smart_formatexpr()
      local conform = require 'conform'
      if #conform.list_formatters_to_run(0) > 0 then
        return conform.formatexpr()
      end
      for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
        if client:supports_method 'textDocument/rangeFormatting' then
          return vim.lsp.formatexpr()
        end
      end
      return 1
    end
    vim.o.formatexpr = 'v:lua.smart_formatexpr()'
  end,
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- No format-on-save for languages without one standard style
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      go = { 'goimports', 'gofmt' },
      -- python = { "isort", "black" },
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
