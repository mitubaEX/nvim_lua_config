return function()
	require("fidget").setup({})

	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	vim.diagnostic.config({
		severity_sort = true,
		virtual_text = {
			spacing = 2,
			source = "if_many",
		},
		float = {
			border = "single",
			source = "if_many",
		},
		signs = true,
		underline = true,
		update_in_insert = false,
	})

	-- 全サーバー共通の設定
	vim.lsp.config("*", {
		capabilities = capabilities,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufopts = { noremap = true, silent = true, buffer = args.buf }
			local client = vim.lsp.get_client_by_id(args.data.client_id)

			vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
			vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
			vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
			vim.keymap.set("n", "<Leader>cr", vim.lsp.buf.rename, bufopts)
			vim.keymap.set("n", "<Leader>cl", vim.diagnostic.open_float, bufopts)
			vim.keymap.set("n", "<Leader>cs", "<cmd>Telescope lsp_document_symbols<CR>", bufopts)
			vim.keymap.set("n", "<Leader>cS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", bufopts)

			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)

			if client and client:supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
			end
		end,
	})

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "single",
	})

	-- サーバー固有の設定（カスタマイズが必要なもののみ）
	vim.lsp.config("ts_ls", {
		settings = { documentFormatting = false },
	})
	vim.lsp.config("gopls", {
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
			},
		},
	})
	vim.lsp.config("denols", {
		root_markers = { "deno.json", "deno.jsonc" },
	})
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				},
				telemetry = {
					enable = false,
				},
			},
		},
	})

	vim.lsp.config("ruby_lsp", {
		root_markers = { "Gemfile", ".git" },
	})

	vim.lsp.config("eslint", {
		settings = {
			workingDirectory = { mode = "auto" },
		},
	})

	-- Mason 管理外のサーバー（手動で設定・有効化が必要）
	vim.lsp.config("sorbet", {
		cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
		filetypes = { "ruby", "rakefile", "rspec" },
		root_markers = { "sorbet", ".git" },
	})
	vim.lsp.config("flow", {
		cmd = { "flow", "lsp" },
		filetypes = { "javascript", "javascriptreact", "javascript.jsx" },
		root_markers = { ".flowconfig", ".git" },
	})
	vim.lsp.config("hls", {
		cmd = { "haskell-language-server-wrapper", "--lsp" },
		filetypes = { "haskell", "lhaskell" },
		root_markers = { "*.cabal", "stack.yaml", "cabal.project", "package.yaml", ".git" },
	})

	vim.lsp.enable("sorbet")
	vim.lsp.enable("flow")
	vim.lsp.enable("hls")
	vim.lsp.enable("ruby_lsp")
end
