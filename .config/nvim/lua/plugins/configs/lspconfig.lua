return function()
	require("fidget").setup({})

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

	-- Using the new vim.lsp.config API (Neovim 0.11+)
	vim.lsp.config.ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "typescript", "typescript.tsx", "typescriptreact" },
		root_markers = { "tsconfig.json", "package.json", ".git" },
		settings = { documentFormatting = false },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	-- vim.lsp.config.solargraph = {
	--   cmd = { 'solargraph', 'stdio' },
	--   filetypes = {"ruby", "rakefile", "rspec"},
	--   root_markers = { "Gemfile", ".git" },
	--   on_attach = on_attach,
	--   capabilities = capabilities
	-- }
	-- vim.lsp.config.ruby_ls = {
	--   cmd = { 'ruby-lsp' },
	--   filetypes = {"ruby", "rakefile", "rspec"},
	--   root_markers = { "Gemfile", ".git" },
	--   capabilities = capabilities,
	--   on_attach = on_attach,
	-- }
	vim.lsp.config.sorbet = {
		cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
		filetypes = { "ruby", "rakefile", "rspec" },
		root_markers = { "sorbet", ".git" },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	vim.lsp.config.flow = {
		cmd = { "flow", "lsp" },
		filetypes = { "javascript", "javascriptreact", "javascript.jsx" },
		root_markers = { ".flowconfig", ".git" },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	vim.lsp.config.yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
		root_markers = { ".git" },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	vim.lsp.config.rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", "rust-project.json", ".git" },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	vim.lsp.config.pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt", ".git" },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	vim.lsp.config.gopls = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_markers = { "go.mod", "go.work", ".git" },
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
	}
	vim.lsp.config.denols = {
		cmd = { "deno", "lsp" },
		filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
		root_markers = { "deno.json", "deno.jsonc" },
		on_attach = on_attach,
		capabilities = capabilities,
	}
	vim.lsp.config.lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", ".git" },
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
	}
	-- vim.lsp.config.syntax_tree = {
	-- 	cmd = { "stree", "lsp" },
	-- 	filetypes = { "ruby" },
	-- 	root_markers = { ".streerc", ".git" },
	-- 	on_attach = on_attach,
	-- 	capabilities = capabilities,
	-- }
	vim.lsp.config.hls = {
		cmd = { "haskell-language-server-wrapper", "--lsp" },
		filetypes = { "haskell", "lhaskell" },
		root_markers = { "*.cabal", "stack.yaml", "cabal.project", "package.yaml", ".git" },
		on_attach = on_attach,
		capabilities = capabilities,
	}

	-- Enable all configured LSP servers
	vim.lsp.enable("ts_ls")
	vim.lsp.enable("sorbet")
	vim.lsp.enable("flow")
	vim.lsp.enable("yamlls")
	vim.lsp.enable("rust_analyzer")
	vim.lsp.enable("pyright")
	vim.lsp.enable("gopls")
	vim.lsp.enable("denols")
	vim.lsp.enable("lua_ls")
	vim.lsp.enable("hls")
end
