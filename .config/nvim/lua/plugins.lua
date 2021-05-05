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

      vim.api.nvim_set_keymap('n', '<Leader>t', '<cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', ';', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false })
      vim.api.nvim_set_keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = false })
    end,
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

end)
