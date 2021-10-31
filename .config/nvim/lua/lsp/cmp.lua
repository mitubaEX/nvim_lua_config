vim.api.nvim_command('set completeopt=menuone,noselect')

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require'cmp'
cmp.setup({
  formatting = {
    format = require('lspkind').cmp_format({
      with_text = true,
      menu = {
        nvim_lsp = '[LSP]',
        buffer = '[Buf]',
        luasnip = '[LSnip]',
        nvim_lua = '[Lua]',
      },
    }),
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  documentation = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "vsnip" },
    { name = "luasnip" },
    { name = "cmp_tabnine" },
    { name = "nvim_lua" },
    { name = "buffer" },
    { name = "calc" },
    { name = "emoji" },
    { name = "treesitter" },
    { name = "crates" },
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
})
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

cmp.setup.cmdline(':', {
  sources = {
    { name = 'cmdline' }
  }
})

cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

local tabnine = require('cmp_tabnine.config')
tabnine:setup({
        max_lines = 1000;
        max_num_results = 20;
        sort = true;
	run_on_every_keystroke = true;
	snippet_placeholder = '..';
})
