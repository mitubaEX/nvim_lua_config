local plugins =  {
  {
    "neovim/nvim-lspconfig",
    'j-hui/fidget.nvim',
    'ray-x/lsp_signature.nvim',
    'folke/lsp-trouble.nvim',
    { 'jose-elias-alvarez/null-ls.nvim', dependencies = { 'yuezk/vim-js' } },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-emoji",
        "onsails/lspkind-nvim",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/vim-vsnip",
        "rafamadriz/friendly-snippets",
        'mitubaEX/cmp-account-items',
      }
    },
    {
      'windwp/nvim-autopairs',
      config = function ()
        require('nvim-autopairs').setup{}
      end
    },

    { 'nvim-lualine/lualine.nvim', dependencies = { 'kyazdani42/nvim-web-devicons', 'ryanoasis/vim-devicons' } },

    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      priority = 1000,
      dependencies = { "windwp/nvim-ts-autotag" },
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
    },
    {
      'EdenEast/nightfox.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd("colorscheme nightfox")
      end
    },

    { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

    'kyazdani42/nvim-tree.lua',

    'mhartington/formatter.nvim',
    {
      "akinsho/toggleterm.nvim",
      config = function ()
        require("toggleterm").setup{ open_mapping = [[<c-l>]] }
        vim.keymap.set('n', '<C-w>w', ':ToggleTerm direction=float<CR>', { noremap = true, silent = false })
        vim.keymap.set('n', '<Leader>s', ':ToggleTerm size=15 direction=horizontal<CR>', { noremap = true, silent = false })
      end
    },

    'neoclide/vim-jsx-improve',
    'greymd/oscyank.vim',
    'AndrewRadev/linediff.vim',
    {
      'lukas-reineke/indent-blankline.nvim',
      config = function ()
        require("indent_blankline").setup {
          -- for example, context is off by default, use this to turn it on
          show_current_context = true,
          show_current_context_start = false,
        }
      end
    },

    {
      'lewis6991/gitsigns.nvim',
      requires = {
        'nvim-lua/plenary.nvim'
      },
      config = function()
        require('gitsigns').setup {
          current_line_blame = true,
        }
      end
    },
    {
      'junegunn/gv.vim',
      requires = { 'tpope/vim-fugitive' },
      config = function ()
        vim.keymap.set('n', '<C-g>l', ":GV!<CR>", { noremap = true, silent = true })
      end
    },
    {
      'vim-test/vim-test',
      config = function()
        vim.api.nvim_set_var('test#strategy', 'neovim')

        vim.api.nvim_set_var('test#ruby#use_binstubs', '1')

        vim.keymap.set('n', '<Leader>q', ':TestFile<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<Leader>Q', ':TestNearest<CR>', { noremap = true, silent = true })
      end
    },

    {
      'lukas-reineke/headlines.nvim',
      ft = 'markdown',
      config = function()
        require('headlines').setup()
      end,
    },

    {
      'goolord/alpha-nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.opts)
      end
    },

    'itchyny/vim-parenmatch',

    {
      'levouh/tint.nvim',
      config = function ()
        require("tint").setup({})
      end
    },


    'mitubaEX/blame_open.nvim',
    {
      'mitubaEX/toggle_rspec_file.nvim',
      config = function()
        vim.keymap.set('n', '<Leader>x', ':ToggleRspecFile<CR>', { noremap = true, silent = true })
      end
    },
    {
      'mitubaEX/to_github_target_pull_request_from_commit_hash.nvim',
      config = function()
        require('to_github_target_pull_request_from_commit_hash').setup()
      end
    },
  }
}

function TableConcat(t1,t2)
   for i=1,#t2 do
      t1[#t1+1] = t2[i]
   end
   return t1
end

return TableConcat(plugins, require('plugins.editor'))
