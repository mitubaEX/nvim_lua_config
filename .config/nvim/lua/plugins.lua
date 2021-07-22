-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- language syntax
  use {
    'sheerun/vim-polyglot',
    config = function()
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_conceal = 0
    end
  }

  -- lsp plugins
  use { 'neovim/nvim-lspconfig' }
  use { 'onsails/lspkind-nvim' }
  use { 'hrsh7th/nvim-compe' }
  use { 'glepnir/lspsaga.nvim' }
  use { 'folke/lua-dev.nvim' }
  use {
    'folke/lsp-trouble.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>xx', '<cmd>LspTroubleToggle<CR>', { noremap = true, silent = false })
    end
  }

  -- snippets
  use { 'rafamadriz/friendly-snippets' }
  use { 'hrsh7th/vim-vsnip' }
  use { 'hrsh7th/vim-vsnip-integ' }

  -- status line
  use {
    'hoob3rt/lualine.nvim',
    requires = { {'kyazdani42/nvim-web-devicons'}, {'ryanoasis/vim-devicons'} },
    -- your statusline
    config = function()
      require('lualine').setup{
        options = {
          theme = 'iceberg_dark',
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

                client_table = {}
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
            }, {'diagnostics', sources = {'nvim_lsp'}, icon = '🚦:'}, {
              function ()
                return vim.b.vista_nearest_method_or_function
              end,
              icon = 'ƒ:'
          }},
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location'  },
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
    -- some optional icons
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- Finder
--   use {
--     'nvim-telescope/telescope.nvim',
--     requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
--     config = function()
--       local actions = require('telescope.actions')
--       require('telescope').setup{
--         defaults = {
--           -- please install fzy
--           file_sorter = require'telescope.sorters'.get_fzy_sorter,
--           generic_sorter = require'telescope.sorters'.get_fzy_sorter,
--           mappings = {
--             i = {
--       	      ["<c-p>"] = actions.preview_scrolling_up,
--       	      ["<c-n>"] = actions.preview_scrolling_down,
--
--       	      ["<C-j>"] = actions.move_selection_next,
--       	      ["<C-k>"] = actions.move_selection_previous,
--             },
--             n = {
--       	      ["<esc>"] = actions.close,
--             },
--           },
--         },
--         pickers = {
--           -- Your special builtin config goes in here
--           buffers = {
--             sort_lastused = true,
--           },
--         },
--       }
--
--       -- vim.api.nvim_set_keymap('n', '<Leader>t', '<cmd>Telescope git_files<CR>', { noremap = true, silent = false })
--       vim.api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = false })
--       -- vim.api.nvim_set_keymap('n', ';', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false })
--       vim.api.nvim_set_keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = false })
--     end,
--   }
  use { 'ibhagwan/fzf-lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional for icons
    'vijaymarupudi/nvim-fzf' },
    config = function()
      require'fzf-lua'.setup {
         grep = { rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case -g '!{.git,node_modules}/*'" }
      }
      vim.api.nvim_set_keymap('n', '<Leader>t', '<cmd>lua require("fzf-lua").files()<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', ';', '<cmd>lua require("fzf-lua").buffers()<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>g', '<cmd>lua require("fzf-lua").grep_cword()<CR>', { noremap = true, silent = false })
    end
  }
  -- file tree
  use {
    'kyazdani42/nvim-tree.lua',
    config = function()
      vim.api.nvim_command([[
        let g:nvim_tree_ignore = [ '.git', 'node_modules', '.cache' ] "empty by default
        let g:nvim_tree_gitignore = 1 "0 by default
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
  use {
    'navarasu/onedark.nvim',
    config = function()
      vim.api.nvim_command('set termguicolors')
      vim.api.nvim_command('syntax enable')

      vim.g.onedark_style = 'deep'

      vim.api.nvim_command('colorscheme onedark')
    end,
  }

  -- f motion
  use { 'rhysd/clever-f.vim' }

  -- terminal
  use {
    'voldikss/vim-floaterm',
    config = function()
      vim.g.floaterm_gitcommit = 'floaterm'
      vim.g.floaterm_wintitle = 0
      vim.g.floaterm_autoclose = 1
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8

      vim.api.nvim_set_keymap('n', '<Leader>[', ':FloatermToggle<CR>', { noremap = true, silent = false })
    end,
  }

  -- yank highlight
  use { 'machakann/vim-highlightedyank' }

  -- jk accelerated
  use {
    'rhysd/accelerated-jk',
    config = function()
      vim.api.nvim_set_keymap('n', 'j', '<Plug>(accelerated_jk_gj)', { noremap = false, silent = false })
      vim.api.nvim_set_keymap('n', 'k', '<Plug>(accelerated_jk_gk)', { noremap = false, silent = false })
    end
  }

  -- surround
  -- add: ysiw(
  -- replace: cs(]
  -- delete: ds(
  use { 'tpope/vim-surround' }
  use { 'tpope/vim-repeat' }

  -- html tag
  use { 'AndrewRadev/tagalong.vim' }
  use { 'alvan/vim-closetag' }

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
  use { 'Yggdroot/indentLine' }

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
  use { 'jiangmiao/auto-pairs' }

  -- toggle comment
  -- gcc: toggle comment
  use {
    'terrortylor/nvim-comment',
    config = function()
      require('nvim_comment').setup()
    end
  }

  -- wilder
  use {
    'gelguy/wilder.nvim',
    config = function()
      vim.api.nvim_command([[
        call wilder#enable_cmdline_enter()
        set wildcharm=<Tab>
        cmap <expr> <Tab> wilder#in_context() ? wilder#next() : "\<Tab>"
        cmap <expr> <S-Tab> wilder#in_context() ? wilder#previous() : "\<S-Tab>"
        call wilder#set_option('modes', ['/', '?', ':'])
      ]])
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
        indent = {
          enable = true
        },
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
    'lambdalisue/gina.vim',
    config = function()
      vim.api.nvim_set_keymap('n', '<C-g>g', ':Gina grep<CR>', { noremap = true, silent = false })
      -- vim.api.nvim_set_keymap('n', '<C-g>o', ':Gina browse :%<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<C-g>b', ':Gina blame<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<C-g>l', ':Gina log %<CR>', { noremap = true, silent = false })
    end
  }
  use {
    'tpope/vim-fugitive',
    requires = { 'tpope/vim-rhubarb' },
  }
  -- use {
  --   'pwntester/octo.nvim',
  --   requires = { 'nvim-telescope/telescope.nvim' },
  --   config = function()
  --     require("octo").setup()
  --   end
  -- }

  -- line move
  -- use {
  --   'nacro90/numb.nvim',
  --   config = function()
  --     require('numb').setup()
  --   end
  -- }

  -- close buffer
  use {
    'Asheq/close-buffers.vim',
    config = function()
      vim.api.nvim_set_keymap('n', '<C-q>', ':Bdelete this<CR>', { noremap = true, silent = true })
    end
  }

  -- test
  use {
    'vim-test/vim-test',
    config = function()
      -- vim.api.nvim_set_var('test#ruby#rspec#options', [[{
      --     'nearest': '--backtrace',
      --     'file':    '--format documentation',
      --     'suite':   '--tag ~slow',
      --   }]])
      vim.api.nvim_set_var('test#strategy', 'neovim')

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

  -- my util plugins
  use { 'mitubaEX/blame_open.nvim' }
  use {
    'mitubaEX/toggle_rspec_file.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>x', ':ToggleRspecFile<CR>', { noremap = true, silent = true })
    end
  }

end)
