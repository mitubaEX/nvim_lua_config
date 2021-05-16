-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- language syntax
  use { 'sheerun/vim-polyglot' }

  -- lsp plugins
  use { 'neovim/nvim-lspconfig' }
  use { 'onsails/lspkind-nvim' }
  use { 'hrsh7th/nvim-compe' }
  use { 'glepnir/lspsaga.nvim' }

  -- snippets
  use { 'rafamadriz/friendly-snippets' }
  use { 'hrsh7th/vim-vsnip' }
  use { 'hrsh7th/vim-vsnip-integ' }

  -- status line
  use {
    'glepnir/galaxyline.nvim',
    branch = 'main',
    requires = { {'kyazdani42/nvim-web-devicons'}, {'ryanoasis/vim-devicons'} },
    -- your statusline
    config = function()
      local gl = require('galaxyline')
      local colors = {
        bg = '#3B3837',
        fg = '#bbc2cf',
        yellow = '#ECBE7B',
        cyan = '#008080',
        darkblue = '#081633',
        green = '#98be65',
        orange = '#FF8800',
        violet = '#a9a1e1',
        magenta = '#c678dd',
        blue = '#51afef';
        red = '#ec5f67';
      }
      local condition = require('galaxyline.condition')
      local gls = gl.section
      gl.short_line_list = {'NvimTree','vista','dbui','packer'}

      gls.left = {
        {
          ViMode = {
            provider = function()
              -- auto change color according the vim mode
              local mode_color = {n = colors.red, i = colors.green,v=colors.blue,
                [''] = colors.blue,V=colors.blue,
                c = colors.magenta,no = colors.red,s = colors.orange,
                S=colors.orange,[''] = colors.orange,
                ic = colors.yellow,R = colors.violet,Rv = colors.violet,
                cv = colors.red,ce=colors.red, r = colors.cyan,
                rm = colors.cyan, ['r?'] = colors.cyan,
              ['!']  = colors.red,t = colors.red}
              vim.api.nvim_command('hi GalaxyViMode guifg='..mode_color[vim.fn.mode()])
              return '  '
            end,
            highlight = {colors.red,colors.bg,'bold'},
          },
        },
        {
          GitIcon = {
            provider = function() return '  ' end,
            condition = condition.check_git_workspace,
            separator_highlight = {'NONE',colors.bg},
            highlight = {colors.violet,colors.bg,'bold'},
          }
        },

        {
          GitBranch = {
            provider = 'GitBranch',
            separator = ' ',
            separator_highlight = {'NONE',colors.bg},
            condition = condition.check_git_workspace,
            highlight = {colors.violet,colors.bg,'bold'},
          }
        },
        {
          FileIcon = {
            provider = 'FileIcon',
            condition = condition.buffer_not_empty,
            highlight = {require('galaxyline.provider_fileinfo').get_file_icon_color,colors.bg},
          },
        },
        {
          FileName = {
            provider = 'FileName',
            condition = condition.buffer_not_empty,
            highlight = {colors.magenta,colors.bg,'bold'}
          }
        },
        {
          DiagnosticError = {
            provider = 'DiagnosticError',
            icon = '  ',
            highlight = {colors.red,colors.bg}
          }
        },
        {
          DiagnosticWarn = {
            provider = 'DiagnosticWarn',
            icon = '  ',
            highlight = {colors.yellow,colors.bg},
          }
        },
        {
          DiagnosticHint = {
            provider = 'DiagnosticHint',
            icon = '  ',
            highlight = {colors.cyan,colors.bg},
          }
        },
        {
          DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            icon = '  ',
            highlight = {colors.blue,colors.bg},
          }
        },
      }
      gls.mid = {
        {
          ShowLspClient = {
            provider = 'GetLspClient',
            condition = function ()
              local tbl = {['dashboard'] = true,['']=true}
              if tbl[vim.bo.filetype] then
                return false
              end
              return true
            end,
            icon = ' LSP:',
            highlight = {colors.fg,colors.bg,'bold'}
          }
        },
        {
          BufferType = {
            provider = 'FileTypeName',
            icon = '|ft:',
            highlight = {colors.blue,colors.bg,'bold'}
          }
        }
      }

      gls.right = {
        {
          FileEncode = {
            provider = 'FileEncode',
            condition = condition.hide_in_width,
            separator = ' ',
            separator_highlight = {'NONE',colors.bg},
            highlight = {colors.green,colors.bg,'bold'}
          }
        },
        {
          FileFormat = {
            provider = 'FileFormat',
            condition = condition.hide_in_width,
            separator = ' ',
            separator_highlight = {'NONE',colors.bg},
            highlight = {colors.green,colors.bg,'bold'}
          }
        },
        {
          DiffAdd = {
            provider = 'DiffAdd',
            condition = condition.hide_in_width,
            separator = ' ',
            separator_highlight = {'NONE',colors.bg},
            icon = '  ',
            highlight = {colors.green,colors.bg},
          }
        },
        {
          DiffModified = {
            provider = 'DiffModified',
            condition = condition.hide_in_width,
            icon = ' 柳',
            highlight = {colors.orange,colors.bg},
          }
        },
        {
          DiffRemove = {
            provider = 'DiffRemove',
            condition = condition.hide_in_width,
            icon = '  ',
            highlight = {colors.red,colors.bg},
          }
        },
        {
          LineInfo = {
            provider = 'LineColumn',
            separator_highlight = {'NONE',colors.bg},
            separator = ' ',
            highlight = {colors.fg,colors.bg},
          },
        },
        {
          PerCent = {
            provider = 'LinePercent',
            separator = ' ',
            separator_highlight = {'NONE',colors.bg},
            highlight = {colors.fg,colors.bg,'bold'},
          }
        },
        {
          ScrollBar = {
            provider = 'ScrollBar',
            highlight = {colors.fg,colors.bg,'bold'},
          }
        },
      }

      gls.short_line_right[1] = {
        BufferIcon = {
          provider= 'BufferIcon',
          highlight = {colors.fg,colors.bg}
        }
      }
    end,
    -- some optional icons
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- Finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup{
        defaults = {
          mappings = {
            i = {
      	      ["<c-p>"] = actions.preview_scrolling_up,
      	      ["<c-n>"] = actions.preview_scrolling_down,

      	      ["<C-j>"] = actions.move_selection_next,
      	      ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
      	      ["<esc>"] = actions.close,
            },
          },
        }
      }

      vim.api.nvim_set_keymap('n', '<Leader>t', '<cmd>Telescope git_files<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', ';', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = false })
    end,
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
    'morhetz/gruvbox',
    config = function()
      vim.api.nvim_command('set termguicolors')
      vim.api.nvim_command('syntax enable')

      vim.api.nvim_command('colorscheme gruvbox')
    end,
  }

  -- f motion
  use { 'rhysd/clever-f.vim' }

  -- terminal
  use {
    'voldikss/vim-floaterm',
    config = function()
      vim.api.nvim_set_var('floaterm_gitcommit', 'floaterm')
      vim.api.nvim_set_var('floaterm_wintitle', 0)
      vim.api.nvim_set_var('floaterm_autoclose', 1)
      vim.api.nvim_set_var('floaterm_width', 0.8)
      vim.api.nvim_set_var('floaterm_height', 0.8)

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
  use {
    'romgrk/nvim-treesitter-context',
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
      vim.api.nvim_set_keymap('n', '<C-g>o', ':Gina browse :%<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<C-g>b', ':Gina blame<CR>', { noremap = true, silent = false })
    end
  }

  -- my util plugins
  use { 'mitubaEX/blame_open.nvim' }
  use { 'mitubaEX/toggle_rspec_file.nvim' }

end)
