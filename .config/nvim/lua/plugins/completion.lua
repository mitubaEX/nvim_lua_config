return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		-- A versioned tag pulls the prebuilt Rust fuzzy matcher from the release
		-- instead of requiring a local `cargo build`.
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			-- Keep the muscle memory from the old nvim-cmp setup: <C-j>/<C-k>
			-- cycle items and <CR> confirms. Everything else (<C-n>/<C-p>,
			-- <C-b>/<C-f> doc scroll, <C-Space> show, <C-e> hide) comes from
			-- blink's "default" preset, so we only override what differs.
			keymap = {
				preset = "default",
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = true },
				menu = {
					draw = {
						-- Mirror the old [LSP]/[Path]/[Buffer] menu labels via the
						-- provider `name`s set below.
						columns = {
							{ "kind_icon", "label", gap = 1 },
							{ "source_name" },
						},
					},
				},
			},
			-- blink's default source list is already { lsp, path, snippets,
			-- buffer }, so we leave sources.default untouched and only relabel
			-- the providers ([LSP]/[Path]/…) and widen the buffer source.
			sources = {
				providers = {
					lsp = { name = "[LSP]" },
					path = { name = "[Path]" },
					snippets = { name = "[Snippet]" },
					buffer = {
						name = "[Buffer]",
						-- The old config completed across every loaded buffer, not
						-- just the visible ones; keep that wider reach.
						opts = {
							get_bufnrs = function()
								return vim.tbl_filter(function(bufnr)
									return vim.api.nvim_buf_is_loaded(bufnr)
								end, vim.api.nvim_list_bufs())
							end,
						},
					},
				},
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
}
