-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- lsp plugins
  use {
    "williamboman/nvim-lsp-installer",
    {
      "neovim/nvim-lspconfig",
      config = function()
        require("nvim-lsp-installer").setup {}
      end
    }
  }
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "f3fora/cmp-spell",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "rafamadriz/friendly-snippets",
    }
  }
  use { 'folke/lua-dev.nvim' }
  use {
    'folke/lsp-trouble.nvim',
    config = function()
      vim.keymap.set('n', '<Leader>xx', '<cmd>TroubleToggle<CR>', { noremap = true, silent = false })
    end
  }
  use {'stevearc/dressing.nvim'}
  use {
    'mhartington/formatter.nvim',
    config = function ()
      local util = require("formatter.util")
      require('formatter').setup({
          filetype = {
            javascript = {
              function()
                return {
                  exe = "prettierd",
                  args = {util.escape_path(util.get_current_buffer_file_path())},
                  stdin = true
                }
              end
            },
            go = {
              -- go fmt
              function()
                return {
                  exe = "gofmt", -- might prepend `bundle exec `
                  args = {},
                  stdin = true,
                }
              end
            }
          }
        })
    end
  }
  use { 'ray-x/lsp_signature.nvim' }
  use {
    'j-hui/fidget.nvim',
    config = function ()
      require"fidget".setup{}
    end
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = { 'yuezk/vim-js' }
  }
  use { 'maxmellon/vim-jsx-pretty' }

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { {'kyazdani42/nvim-web-devicons'}, {'ryanoasis/vim-devicons'} },
    -- your statusline
    config = function()
      require('lualine').setup{
        sections = {
          lualine_a = {  },
          lualine_b = { {'branch', icon = ''} },
          lualine_c = {
            {'filename', file_status = true, path = 1, separator = ''},
            { 'diff' }, {
              -- Lsp server name .
              -- ref: https://gist.github.com/shadmansaleh/cd526bc166237a5cbd51429cc1f6291b
              function ()
                local msg = 'No Active Lsp'
                local buf_ft = vim.api.nvim_buf_get_option(0,'filetype')
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then return msg end

                local client_table = {}
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    table.insert(client_table,  client.name)
                  end
                end

                if table.getn(client_table) > 0 then
                  return '[' .. table.concat(client_table, ',') .. ']'
                end

                return msg
              end,
              icon = '⚙️ :',
              color = {fg = '#a69ded'},
              separator = ''
            }, {'diagnostics', sources = {'nvim_diagnostic'}, icon = '🚦:'}},
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = {   },
        },
        inactive_sections = {
          lualine_a = {  },
          lualine_b = {  },
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {  },
          lualine_z = {  },
        },
      }
    end,
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function()
      local actions = require('telescope.actions')
      local mappings = {
        i = {
          ["<c-p>"] = actions.cycle_history_prev,
          ["<c-n>"] = actions.cycle_history_next,

          ["<c-u>"] = actions.preview_scrolling_up,
          ["<c-d>"] = actions.preview_scrolling_down,

          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
        n = {
          ["<esc>"] = actions.close,
        },
      }
      -- Global remapping
      ------------------------------
      require('telescope').setup{
        defaults = {
          -- please install fzy
          file_sorter = require'telescope.sorters'.get_fzy_sorter,
          generic_sorter = require'telescope.sorters'.get_fzy_sorter,
          mappings = mappings,
        },
        pickers = {
          -- Your special builtin config goes in here
          buffers = {
            prompt_title = '✨ Search Buffers ✨',
            mappings = mappings,
            sort_mru = true,
            preview_title = false,
            theme="ivy",
          },
          git_files = {
            mappings = mappings,
            sort_mru = true,
            preview_title = false,
            prompt_title = "",
            prompt_prefix = "     ",
            selection_caret = "  ",
            entry_prefix = "  ",
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = {
              horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
              },
              vertical = {
                mirror = false,
              },
              width = 0.80,
              height = 0.85,
              preview_cutoff = 120,
            },
            winblend = 0,
            set_env = { ["COLORTERM"] = "truecolor" },
            selection_strategy = "reset",
            results_title = "",
            color_devicons = true,
            use_less = true,
          },
          grep_string = {
            mappings = mappings,
          },
          registers = {
            mappings = mappings,
            theme="ivy",
          },
          git_bcommits = {
            mappings = mappings,
            theme="ivy",
          },
        },
      }

      vim.keymap.set('n', '<Leader>t', '<cmd>Telescope git_files<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', ';', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<Leader>g', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<Leader>y', ":lua require'telescope.builtin'.registers{}<CR>", { noremap = true, silent = true })
      -- vim.keymap.set('n', '<C-g>l', ":lua require'telescope.builtin'.git_bcommits{}<CR>", { noremap = true, silent = true })
    end
  }
  -- file tree
  use {
    'kyazdani42/nvim-tree.lua',
    config = function()
      require'nvim-tree'.setup {
        renderer = {
          highlight_git = true,
        }
      }
      vim.keymap.set('n', '<Leader>d', '<cmd>NvimTreeFindFile<CR>', { noremap = true, silent = false })
    end
  }

  -- color
  use {
    'EdenEast/nightfox.nvim',
    config = function()
      vim.api.nvim_command('set termguicolors')
      vim.api.nvim_command('syntax enable')

      vim.cmd("colorscheme nightfox")
    end,
  }
  use 'folke/lsp-colors.nvim'

  -- f motion
  use { 'rhysd/clever-f.vim' }

  -- terminal
  use {
    "akinsho/toggleterm.nvim",
    config = function ()
      require("toggleterm").setup{
        open_mapping = [[<c-l>]]
      }
      vim.keymap.set('n', '<C-w>w', ':ToggleTerm direction=float<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<Leader>[', ':ToggleTerm direction=float<CR>', { noremap = true, silent = false })

      -- NOTE: after open terminal, `2<c-l>` will open another terminal
      vim.keymap.set('n', '<Leader>s', ':ToggleTerm size=15 direction=horizontal<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<Leader>v', ':ToggleTerm size=100 direction=vertical<CR>', { noremap = true, silent = false })
    end
  }

  -- surround
  -- add: ysiw(
  -- replace: cs(]
  -- delete: ds(
  use {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup()
    end
  }

  -- jsx
  use { 'neoclide/vim-jsx-improve' }

  -- fast move
  -- https://tyru.hatenablog.com/entry/2020/04/26/110000
  use {
    'tyru/columnskip.vim',
    config = function()
      vim.keymap.set('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
    end
  }

  -- skip definitions
  use { 'mitubaEX/jumpy.vim' }

  -- move line
  use {
    'matze/vim-move',
    config = function()
      vim.g.move_key_modifier = 'C'
    end
  }

  -- edit multiple word
  use { 'mg979/vim-visual-multi' }

  -- grep define
  use {
    'pechorin/any-jump.vim',
    config = function()
      vim.g.any_jump_disable_default_keybindings = '1'
      vim.keymap.set('n', '<Leader>a', ':AnyJump<CR>', { noremap = true, silent = false })
    end
  }

  use { 'AndrewRadev/linediff.vim' }

  -- window
  use {
    't9md/vim-choosewin',
    config = function ()
      vim.keymap.set('n', '-', '<Plug>(choosewin)', { noremap = true, silent = false })
    end
  }

  -- highlight
  use {
    't9md/vim-quickhl',
    config = function()
      vim.keymap.set('n', '<Leader>m', '<Plug>(quickhl-manual-this)', { noremap = false, silent = false })
      vim.keymap.set('x', '<Leader>m', '<Plug>(quickhl-manual-this)', { noremap = false, silent = false })
      vim.keymap.set('n', '<Leader>M', '<Plug>(quickhl-manual-reset)', { noremap = false, silent = false })
      vim.keymap.set('x', '<Leader>M', '<Plug>(quickhl-manual-reset)', { noremap = false, silent = false })
    end
  }

  use {
    'xiyaowong/nvim-cursorword',
    config = function()
      vim.api.nvim_set_hl(0, "CursorWord", { bold = 1, default = 1 })
    end
  }

  -- indent line
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function ()
      require("indent_blankline").setup {
        -- for example, context is off by default, use this to turn it on
        show_current_context = true,
        show_current_context_start = false,
      }
    end
  }

  -- <Leader>r<word obj> replace word
  use { 'kana/vim-operator-user' }
  use {
    'kana/vim-operator-replace',
    config = function()
      vim.keymap.set('v', 'p', '<Plug>(operator-replace)', { noremap = false, silent = true })
      vim.keymap.set('n', '<Leader>r', '<Plug>(operator-replace)', { noremap = false, silent = true })
    end
  }

  -- text obj
  use {
    'bkad/CamelCaseMotion',
    config = function()
      vim.keymap.set('', 'w', '<Plug>CamelCaseMotion_w', { noremap = false, silent = true })
      vim.keymap.set('', 'e', '<Plug>CamelCaseMotion_e', { noremap = false, silent = true })
      vim.keymap.set('o', 'iw', '<Plug>CamelCaseMotion_iw', { noremap = false, silent = true })
      vim.keymap.set('x', 'iw', '<Plug>CamelCaseMotion_iw', { noremap = false, silent = true })
      vim.keymap.set('o', 'ie', '<Plug>CamelCaseMotion_ie', { noremap = false, silent = true })
      vim.keymap.set('x', 'ie', '<Plug>CamelCaseMotion_ie', { noremap = false, silent = true })
    end
  }

  -- auto pairs
  use {
    'windwp/nvim-autopairs',
    config = function ()
      require('nvim-autopairs').setup{}
    end
  }

  -- toggle comment
  -- gcc: toggle comment
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  -- nvim-treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = { "windwp/nvim-ts-autotag" },
    run = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        autotag = {
          enable = true,
        },
        highlight = {
          enable = true,
        },
      }
    end
  }

  -- git
  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
    config = function ()
      local neogit = require('neogit')
      neogit.setup {}
      vim.keymap.set('n', '<C-g>n', ':Neogit<CR>', { noremap = true, silent = false })
    end
  }
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
      }
    end
  }
  use {
    'tyru/open-browser-github.vim',
    requires = { 'tyru/open-browser.vim' },
    config = function()
      vim.keymap.set('n', '<C-g>o', '::OpenGithubFile<CR>', { noremap = true, silent = false })
    end
  }
  use {
    'junegunn/gv.vim',
    requires = { 'tpope/vim-fugitive' },
    config = function ()
      vim.keymap.set('n', '<C-g>l', ":GV!<CR>", { noremap = true, silent = true })
    end
  }

  -- close buffer
  use {
    'Asheq/close-buffers.vim',
    config = function()
      vim.keymap.set('n', '<C-q>', ':Bdelete hidden<CR>', { noremap = true, silent = true })
    end
  }

  -- test
  use {
    'vim-test/vim-test',
    config = function()
      vim.api.nvim_set_var('test#strategy', 'neovim')

      vim.api.nvim_set_var('test#ruby#use_binstubs', '1')

      vim.keymap.set('n', '<Leader>q', ':TestFile<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<Leader>Q', ':TestNearest<CR>', { noremap = true, silent = true })
    end
  }

  -- hop(easymotion)
  use { 'phaazon/hop.nvim',
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5, create_hl_autocmd = false, winblend = 0 }
      vim.keymap.set('n', '<Leader>e', ':HopWord<CR>', { noremap = true, silent = true })
    end
  }

  -- plantuml
  use { 'weirongxu/plantuml-previewer.vim' }

  -- barbar
  use {
    'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
  }

  -- vim-rails
  use {
    'tpope/vim-rails',
    ft = 'ruby',
    requires = {'tpope/vim-bundler', 'tpope/vim-dispatch'},
  }

  use {
    'lukas-reineke/headlines.nvim',
    ft = 'markdown',
    config = function()
      require('headlines').setup()
    end,
  }

  -- scroll
  use {
    'karb94/neoscroll.nvim',
    config = function ()
      require('neoscroll').setup()
      local t = {}
      -- Syntax: t[keys] = {function, {function arguments}}
      t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '50'}}
      t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '50'}}

      require('neoscroll.config').set_mappings(t)
    end
  }

  -- filetype
  use { 'nathom/filetype.nvim' }

  use {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function ()
      require'alpha'.setup(require'alpha.themes.startify'.opts)
    end
  }

  use { 'itchyny/vim-parenmatch', }
  use {
    'rhysd/accelerated-jk',
    config = function()
      vim.keymap.set('n', 'j', '<Plug>(accelerated_jk_gj)', { noremap = false, silent = false })
      vim.keymap.set('n', 'k', '<Plug>(accelerated_jk_gk)', { noremap = false, silent = false })
    end
  }
  use {
    'mhinz/vim-grepper',
    config = function ()
      vim.keymap.set('n', '<C-g>g', ':Grepper -tool git<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<C-g>G', ':Grepper -tool git -cword<CR>', { noremap = true, silent = false })
    end
  }

  use { 'tricktux/pomodoro.vim' }
  use {
    'levouh/tint.nvim',
    config = function ()
      require("tint").setup()
    end
  }

  -- :Snek
  -- :Camel
  use { 'nicwest/vim-camelsnek' }
  use { 'ojroques/vim-oscyank' }
  use { 'brooth/far.vim' }

  -- my util plugins
  use { 'mitubaEX/blame_open.nvim' }
  use {
    'mitubaEX/toggle_rspec_file.nvim',
    config = function()
      vim.keymap.set('n', '<Leader>x', ':ToggleRspecFile<CR>', { noremap = true, silent = true })
    end
  }
  use {
    'mitubaEX/to_github_target_pull_request_from_commit_hash.nvim',
    config = function()
      require('to_github_target_pull_request_from_commit_hash').setup()
    end
  }

end)
