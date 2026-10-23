-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    -- [[Harpoon]]
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      -- REQUIRED
      harpoon:setup {}
      -- REQUIRED

      -- basic telescope configuration
      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
        -- toggle_telescope(harpoon:list())
      end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-p>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<C-n>', function()
        harpoon:list():next()
      end)
    end,
  },

  -- [[swagger-preview]]
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

  -- [[nvim-jdtls]]
  {
    'mfussenegger/nvim-jdtls',
  },

  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup {
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
      }
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
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
