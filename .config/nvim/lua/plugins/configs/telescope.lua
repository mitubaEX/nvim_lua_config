return function()
  local actions = require('telescope.actions')
  local mappings = {
    i = {
      ["<c-p>"] = actions.cycle_history_prev,
      ["<c-n>"] = actions.cycle_history_next,

      ["<c-u>"] = actions.preview_scrolling_up,
      ["<c-d>"] = actions.preview_scrolling_down,

      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,

      -- ["<CR>"] = actions.select_vertical,
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
        -- ignore rbi
        file_ignore_patterns = { "%.rbi" },
      },
      grep_string = {
        mappings = mappings,
        file_ignore_patterns = { "%.rbi" },
      },
      live_grep = {
        additional_args = function()
          return {"--hidden"}
        end,
        file_ignore_patterns = { "%.rbi" },
      },
      registers = {
        mappings = mappings,
        -- theme="ivy",
      },
      git_bcommits = {
        mappings = mappings,
        theme="ivy",
      },
    },
  }

  vim.keymap.set('n', '<Leader>t', '<cmd>Telescope git_files<CR>', { noremap = true, silent = false })
  vim.keymap.set('n', ';', '<cmd>Telescope buffers<CR>', { noremap = true, silent = false })
  vim.keymap.set('n', '<Leader>g', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = false })
  vim.keymap.set('n', '<Leader>y', ":lua require'telescope.builtin'.registers{}<CR>", { noremap = true, silent = true })

  local before = require('before')
  vim.keymap.set('n', '<leader>oe', function()
    before.show_edits(require('telescope.themes').get_dropdown())
  end, {})
end
