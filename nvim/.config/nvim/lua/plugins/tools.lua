-- Previews and layout helpers
return {
  -- :MarkdownPreview in the browser
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },

  -- :SwaggerPreview for OpenAPI files
  {
    'vinnymeller/swagger-preview.nvim',
    cmd = { 'SwaggerPreview', 'SwaggerPreviewStop', 'SwaggerPreviewToggle' },
    build = 'npm i',
    config = function()
      require('swagger-preview').setup {
        port = 8000,
        host = 'localhost',
      }
    end,
  },

  -- Center the buffer (:NoNeckPain)
  {
    'shortcuts/no-neck-pain.nvim',
    version = '*',
    opts = {
      autocmds = {
        enableOnVimEnter = false,
      },
      buffers = {
        right = { enabled = false },
      },
    },
  },
}
