-- local config = {
--   cmd = { vim.fn.expand '~/.local/share/nvim/mason/bin/jdtls' },
--   root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
-- }
-- require('jdtls').start_or_attach(config)

local config = {
  cmd = { vim.fn.expand '~/.local/share/nvim/mason/bin/jdtls' },
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
  settings = {
    java = {
      format = {
        enabled = true,
        settings = {
          url = vim.fn.expand '~/.config/nvim/eclipse-formatter.xml',
          profile = 'NoCommentFormatting',
        },
      },
    },
  },
}
require('jdtls').start_or_attach(config)
