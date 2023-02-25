return  function()
  vim.api.nvim_command('set completeopt=menuone,noselect')

  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp = require'cmp'

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'cmdline' }
    }
  })

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup({
    formatting = {
      format = require('lspkind').cmp_format({
        with_text = true,
        menu = {
          nvim_lsp = '[LSP]',
          buffer = '[Buf]',
          nvim_lua = '[Lua]',
        },
      }),
    },
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
      documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "path" },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = "cmp_tabnine" },
      { name = "nvim_lua" },
      {
        name = "buffer",
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end
        }
      },
      { name = "calc" },
      { name = "emoji" },
      { name = "treesitter" },
      { name = "crates" },

      -- My custom sources.
      { name = 'account_items' },
    },
    mapping = {
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<C-n>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<C-p>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
  })
  cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

  -- vsnip
  -- Jump forward or backward
  vim.api.nvim_command([[
    imap <expr> <C-b>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-b>'
    smap <expr> <C-b>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-b>'
  ]])
  -- If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
  vim.api.nvim_command([[
    let g:vsnip_filetypes = {}
    let g:vsnip_filetypes.javascriptreact = ['javascript']
    let g:vsnip_filetypes.typescriptreact = ['typescript']
  ]])
end
