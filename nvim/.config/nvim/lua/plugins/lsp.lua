-- LSP: servers, keymaps, diagnostics. Run :Mason to see installed tools.
return {
  -- Lua LSP support for the Neovim API (for editing this config)
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- Java (started from ftplugin/java.lua)
  { 'mfussenegger/nvim-jdtls' },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason must load before its dependents
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} }, -- LSP progress messages
      'saghen/blink.cmp',
    },
    config = function()
      -- [[ Keymaps, set when an LSP attaches to a buffer ]]
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local builtin = require 'telescope.builtin'

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', builtin.lsp_references, '[G]oto [R]eferences')
          map('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')
          map('grd', builtin.lsp_definitions, '[G]oto [D]efinition') -- <C-t> to jump back
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration') -- e.g. a C header
          map('gO', builtin.lsp_document_symbols, 'Open Document Symbols')
          map('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Highlight references of the word under the cursor while it rests there
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints, if the server supports them
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- [[ Diagnostics ]] See `:help vim.diagnostic.Opts`
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }

      -- Extra capabilities from blink.cmp, sent to every server
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- [[ Servers ]] Installed automatically by Mason.
      -- Per-server keys: cmd, filetypes, capabilities, settings. See `:help lspconfig-all`
      local servers = {
        clangd = {},
        gopls = {},
        pyright = {},
        -- rust_analyzer = {},
        ts_ls = {},
        eslint = {},
        html = {},
        cssls = {},
        jsonls = {},
        tailwindcss = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Other tools for Mason to install
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'goimports',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Godot (connects to the running editor)
      vim.lsp.config('gdscript', {
        cmd = { 'nc', '127.0.0.1', '6005' },
        filetypes = { 'gd', 'gdscript' },
        capabilities = capabilities,
      })
      vim.lsp.enable 'gdscript'

      -- Pyright LSP config
      -- vim.lsp.config('pyright', {
      --   settings = {
      --     python = {
      --       analysis = {
      --         typeCheckingMode = 'standard',
      --         diagnosticSeverityOverrides = {
      --           reportMissingParameterType = 'warning',
      --           reportUnknownParameterType = 'warning',
      --           reportUnknownVariableType = 'warning',
      --           reportUnknownMemberType = 'warning',
      --           reportUnknownArgumentType = 'warning',
      --           reportMissingTypeArgument = 'warning', -- e.g. bare `dict` instead of dict[str, int]
      --         },
      --       },
      --     },
      --   },
      -- })

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- installs are handled by mason-tool-installer above
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
