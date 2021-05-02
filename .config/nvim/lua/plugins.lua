-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

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
    end,
  }

  -- color
  use {
    'morhetz/gruvbox' ,
    config = function()
      vim.api.nvim_command('set termguicolors')
      vim.api.nvim_command('syntax enable')

      vim.api.nvim_command('colorscheme gruvbox')
    end,
  }
end)
