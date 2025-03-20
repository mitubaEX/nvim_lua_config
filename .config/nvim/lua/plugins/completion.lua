return {
  {
		"saghen/blink.cmp",
    version = '*',
    event = { "InsertEnter", "CmdLineEnter" },
		dependencies = {
      'rafamadriz/friendly-snippets',
      "fang2hou/blink-copilot",
      'Kaiser-Yang/blink-cmp-avante',
		},
    opts = {
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot', 'avante' },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
          avante = {
            name = "avante",
            module = "blink-cmp-avante",
            score_offset = 100,
            async = true,
          },
        }
      },
      fuzzy = { implementation = "lua" },
    }
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
}
