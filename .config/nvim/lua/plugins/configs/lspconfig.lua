return function()
	require("fidget").setup({})

	local lspconfig = require("lspconfig")

	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	local on_attach = function(_, buffer)
		local bufopts = { noremap = true, silent = true, buffer = buffer }

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "gl", vim.lsp.buf.references, bufopts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
		vim.keymap.set("n", "gr", vim.lsp.buf.rename, bufopts)
		vim.keymap.set("n", "ga", vim.lsp.buf.code_action, bufopts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
		-- vim.keymap.set('n', '<space>f', ":lua vim.lsp.buf.format { async = true }<CR>", bufopts)

		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "single",
		})
	end

	-- lspconfig
	lspconfig.ts_ls.setup({
		filetypes = { "typescript", "typescript.tsx", "typescriptreact" },
		settings = { documentFormatting = false },
		on_attach = on_attach,
		capabilities = capabilities,
	})
	-- lspconfig.solargraph.setup{
	--   cmd = { 'solargraph', 'stdio' },
	--   filetypes = {"ruby", "rakefile", "rspec"},
	--   on_attach = on_attach,
	--   capabilities = capabilities
	-- }
	-- lspconfig.ruby_ls.setup{
	--   cmd = { 'ruby-lsp' },
	--   filetypes = {"ruby", "rakefile", "rspec"},
	--   capabilities = capabilities,
	--   on_attach = on_attach,
	-- }
	lspconfig.sorbet.setup({
		cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
		filetypes = { "ruby", "rakefile", "rspec" },
		on_attach = on_attach,
		capabilities = capabilities,
	})
	lspconfig.flow.setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
	lspconfig.yamlls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
	lspconfig.rust_analyzer.setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
	lspconfig.pyright.setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
	lspconfig.gopls.setup({
		on_attach = on_attach,
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
			},
		},
		capabilities = capabilities,
	})
	lspconfig.denols.setup({
		on_attach = on_attach,
		root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
	})
	lspconfig.lua_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = vim.api.nvim_get_runtime_file("", true),
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		},
	})
	-- lspconfig.syntax_tree.setup({
	-- 	on_attach = on_attach,
	-- 	capabilities = capabilities,
	-- })
	lspconfig.hls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end
