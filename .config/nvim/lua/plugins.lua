-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- lsp plugins
  use { 'neovim/nvim-lspconfig' }
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "f3fora/cmp-spell",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    }
  }
 	use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}
  use { 'folke/lua-dev.nvim' }
  use {
    'folke/lsp-trouble.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>xx', '<cmd>TroubleToggle<CR>', { noremap = true, silent = false })
    end
  }
  use {'stevearc/dressing.nvim'}
  -- use { 'simrat39/symbols-outline.nvim' }
  use {
    'github/copilot.vim',
    config = function ()
      vim.cmd('imap <silent><script><expr> <C-e> copilot#Accept("<CR>")')
      vim.cmd('let g:copilot_no_tab_map = v:true')
    end
  }
  use {
    'mhartington/formatter.nvim',
    config = function ()
      require('formatter').setup({
          filetype = {
            javascript = {
              -- eslint
              function()
                return {
                  exe = "eslint_d",
                  args = {"--stdin", "--fix-to-stdout"},
                  stdin = true
                }
              end
            },
            javascriptreact = {
              -- eslint
              function()
                return {
                  exe = "eslint_d",
                  args = {"--stdin", "--fix-to-stdout"},
                  stdin = true
                }
              end
            },
            typescriptreact = {
              -- eslint
              function()
                return {
                  exe = "eslint_d",
                  args = {"--stdin", "--stdin-filename"},
                  stdin = true
                }
              end
            },
            ruby = {
              -- rubocop
              function()
                return {
                  exe = "rubocop", -- might prepend `bundle exec `
                  args = { '--auto-correct', '--stdin', '%:p', '2>/dev/null', '|', "awk 'f; /^====================$/{f=1}'"},
                  stdin = true,
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

  -- snippets
  use {
    'L3MON4D3/LuaSnip',
    config = function ()
      -- require("luasnip").config.set_config {
      --   history = true,
      -- }
      require("luasnip.loaders.from_vscode").load {}
    end
  }

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { {'kyazdani42/nvim-web-devicons'}, {'ryanoasis/vim-devicons'} },
    -- your statusline
    config = function()
      require('lualine').setup{
        options = {
          theme = 'nightfox',
          icons_enabled = true,
        },
        sections = {
          lualine_a = { {'mode', upper = true} },
          lualine_b = { {'branch', icon = ''} },
          lualine_c = {
            {'filename', file_status = true, path = 1, separator = ''},
            { 'diff', separator = '', icon = '✏️ :' }, {
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
          lualine_z = { 'location', { function ()
            return vim.api.nvim_exec([[echo pomo#status_bar()]], true);
          end}  },
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
            prompt_title = '📦 Search Git Files 📦',
            mappings = mappings,
            sort_mru = true,
            preview_title = false,
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

      vim.api.nvim_set_keymap('n', '<Leader>t', '<cmd>Telescope git_files<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', ';', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>g', '<cmd>Telescope grep_string<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>y', ":lua require'telescope.builtin'.registers{}<CR>", { noremap = true, silent = true })
      -- vim.api.nvim_set_keymap('n', '<C-g>l', ":lua require'telescope.builtin'.git_bcommits{}<CR>", { noremap = true, silent = true })
    end
  }
  -- file tree
  use {
    'kyazdani42/nvim-tree.lua',
    config = function()
      require'nvim-tree'.setup {}
      vim.api.nvim_command([[
        let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
        let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
        let g:nvim_tree_lsp_diagnostics = 1 "0 by default, will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
        let g:nvim_tree_show_icons = {
          \ 'git': 1,
          \ 'folders': 1,
          \ 'files': 1,
          \ }
      ]])
      vim.api.nvim_set_keymap('n', '<Leader>d', '<cmd>NvimTreeFindFile<CR>', { noremap = true, silent = false })
    end
  }

  -- color
--   use {
--     'navarasu/onedark.nvim',
--     config = function()
--       vim.api.nvim_command('set termguicolors')
--       vim.api.nvim_command('syntax enable')
--
--       vim.g.onedark_style = 'deep'
--
--       vim.api.nvim_command('colorscheme onedark')
--     end,
--   }
--   use {
--     'folke/tokyonight.nvim',
--     config = function()
--       vim.api.nvim_command('set termguicolors')
--       vim.api.nvim_command('syntax enable')
--
--       vim.g.tokyonight_style = 'night'
--
--       vim.api.nvim_command('colorscheme tokyonight')
--     end,
--   }
  -- use {
  --   'marko-cerovac/material.nvim',
  --   config = function()
  --     vim.api.nvim_command('set termguicolors')
  --     vim.api.nvim_command('syntax enable')
  --
  --     vim.g.material_style = "deep ocean"
  --     vim.api.nvim_command('colorscheme material')
  --   end,
  -- }
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
      vim.api.nvim_set_keymap('n', '<Leader>[', ':ToggleTerm direction=float<CR>', { noremap = true, silent = false })
    end
  }

  -- surround
  -- add: ysiw(
  -- replace: cs(]
  -- delete: ds(
  use { 'tpope/vim-surround' }
  use { 'tpope/vim-repeat' }

  -- jsx
  use {
    'windwp/nvim-ts-autotag',
    ft = {'javascriptreact', 'typescriptreact'},
    config = function ()
      require('nvim-ts-autotag').setup()
    end
  }
  use { 'neoclide/vim-jsx-improve' }

  -- fast move
  -- https://tyru.hatenablog.com/entry/2020/04/26/110000
  use {
    'tyru/columnskip.vim',
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>j', '<Plug>(columnskip:nonblank:next)', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>k', '<Plug>(columnskip:nonblank:prev)', { noremap = false, silent = true })
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
      vim.api.nvim_set_keymap('n', '<Leader>a', ':AnyJump<CR>', { noremap = true, silent = false })
    end
  }

  use { 'AndrewRadev/linediff.vim' }

  -- highlight
  use {
    't9md/vim-quickhl',
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>m', '<Plug>(quickhl-manual-this)', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('x', '<Leader>m', '<Plug>(quickhl-manual-this)', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>M', '<Plug>(quickhl-manual-reset)', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('x', '<Leader>M', '<Plug>(quickhl-manual-reset)', { noremap = false, silent = false })
    end
  }

  use { 'itchyny/vim-cursorword' }

  -- indent line
--   use {
--     'lukas-reineke/indent-blankline.nvim',
--     config = function ()
--       vim.opt.termguicolors = true
--       vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]]
--       vim.cmd [[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]]
--
--       require("indent_blankline").setup {
--         char = "",
--         char_highlight_list = {
--           "IndentBlanklineIndent1",
--           "IndentBlanklineIndent2",
--         },
--         space_char_highlight_list = {
--           "IndentBlanklineIndent1",
--           "IndentBlanklineIndent2",
--         },
--         show_trailing_blankline_indent = false,
--       }
--     end
--   }

  -- <Leader>r<word obj> replace word
  use { 'kana/vim-operator-user' }
  use {
    'kana/vim-operator-replace',
    config = function()
      vim.api.nvim_set_keymap('v', 'p', '<Plug>(operator-replace)', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>r', '<Plug>(operator-replace)', { noremap = false, silent = true })
    end
  }

  -- text obj
  use {
    'bkad/CamelCaseMotion',
    config = function()
      vim.api.nvim_set_keymap('', 'w', '<Plug>CamelCaseMotion_w', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('', 'e', '<Plug>CamelCaseMotion_e', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('o', 'iw', '<Plug>CamelCaseMotion_iw', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('x', 'iw', '<Plug>CamelCaseMotion_iw', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('o', 'ie', '<Plug>CamelCaseMotion_ie', { noremap = false, silent = true })
      vim.api.nvim_set_keymap('x', 'ie', '<Plug>CamelCaseMotion_ie', { noremap = false, silent = true })
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
    config = function()
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
        -- indent = {
        --   enable = true
        -- },
      }
    end
  }

  -- git
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
    'sindrets/diffview.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      vim.api.nvim_set_keymap('n', '<C-g>d', ':DiffviewOpen<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<C-g>D', ':DiffviewClose<CR>', { noremap = true, silent = false })
    end
  }
  use {
    'tyru/open-browser-github.vim',
    requires = { 'tyru/open-browser.vim' },
    config = function()
      vim.api.nvim_set_keymap('n', '<C-g>o', '::OpenGithubFile<CR>', { noremap = true, silent = false })
    end
  }
  use {
    'junegunn/gv.vim',
    requires = { 'tpope/vim-fugitive' },
    config = function ()
      vim.api.nvim_set_keymap('n', '<C-g>l', ":GV!<CR>", { noremap = true, silent = true })
    end
  }

  -- close buffer
  use {
    'Asheq/close-buffers.vim',
    config = function()
      -- vim.api.nvim_set_keymap('n', '<C-q>', ':Bdelete this<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<C-q>', ':Bdelete hidden<CR>', { noremap = true, silent = true })
    end
  }

  -- test
  use {
    'vim-test/vim-test',
    config = function()
      vim.api.nvim_set_var('test#strategy', 'neovim')

      vim.api.nvim_set_var('test#ruby#use_binstubs', '1')

      vim.api.nvim_set_keymap('n', '<Leader>q', ':TestFile<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<Leader>Q', ':TestNearest<CR>', { noremap = true, silent = true })
    end
  }

  -- hop(easymotion)
  use { 'phaazon/hop.nvim',
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5, create_hl_autocmd = false, winblend = 0 }
      vim.api.nvim_set_keymap('n', '<Leader>e', ':HopWord<CR>', { noremap = true, silent = true })
    end
  }

  -- plantuml
  use { 'weirongxu/plantuml-previewer.vim' }

  -- barbar
  use {
    'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
    config = function()
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }

      -- Move to previous/next
      map('n', 'gp', ':BufferPrevious<CR>', opts)
      map('n', 'gn', ':BufferNext<CR>', opts)
      -- Goto buffer in position...
      map('n', '<A-1>', ':BufferGoto 1<CR>', opts)
      map('n', '<A-2>', ':BufferGoto 2<CR>', opts)
      map('n', '<A-3>', ':BufferGoto 3<CR>', opts)
      map('n', '<A-4>', ':BufferGoto 4<CR>', opts)
      map('n', '<A-5>', ':BufferGoto 5<CR>', opts)
      map('n', '<A-6>', ':BufferGoto 6<CR>', opts)
      map('n', '<A-7>', ':BufferGoto 7<CR>', opts)
      map('n', '<A-8>', ':BufferGoto 8<CR>', opts)
      map('n', '<A-9>', ':BufferGoto 9<CR>', opts)
      map('n', '<A-0>', ':BufferLast<CR>', opts)
    end
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
  use {
    'nathom/filetype.nvim',
    -- config = function()
    --   vim.g.did_load_filetypes = 1
    -- end
  }

  use {
    'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function ()
      require'alpha'.setup(require'alpha.themes.startify'.opts)
    end
  }

  use {
    'itchyny/vim-parenmatch',
    -- config = function ()
    --   vim.g.loaded_matchparen = 1
    -- end
  }
  use {
    'rhysd/accelerated-jk',
    config = function()
      vim.api.nvim_set_keymap('n', 'j', '<Plug>(accelerated_jk_gj)', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n', 'k', '<Plug>(accelerated_jk_gk)', { noremap = false, silent = false })
    end
  }
  use {
    'mhinz/vim-grepper',
    config = function ()
      vim.api.nvim_set_keymap('n', '<C-g>g', ':Grepper -tool git<CR>', { noremap = true, silent = false })
    end
  }

  use { 'tricktux/pomodoro.vim' }

  -- :Snek
  -- :Camel
  use { 'nicwest/vim-camelsnek' }

  -- use { 'dstein64/nvim-scrollview' }

  -- my util plugins
  use { 'mitubaEX/blame_open.nvim' }
  use {
    'mitubaEX/toggle_rspec_file.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>x', ':ToggleRspecFile<CR>', { noremap = true, silent = true })
    end
  }

end)
