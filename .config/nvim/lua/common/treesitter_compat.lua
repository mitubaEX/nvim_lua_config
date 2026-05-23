-- nvim-treesitter master が archive されたまま放置されているため、
-- Neovim 0.10+ で導入された TSMatch の新形式（capture id → TSNode[]）に
-- 追従しておらず、`vim.treesitter.get_node_text(match[id], ...)` の中で
-- `node:range()` を nil 値に対して呼び出してクラッシュする。
-- vim-matchup の treesitter 統合が CursorMoved ごとに injection を再解析するので、
-- markdown 等の `downcase!` / `set-lang-from-*!` directive を踏むと
-- 連続して E5108 が出る。原因 directive を新形式対応版で `force = true` 再登録する。

local M = {}

local html_script_type_languages = {
	["importmap"] = "json",
	["module"] = "javascript",
	["application/ecmascript"] = "javascript",
	["text/ecmascript"] = "javascript",
}

local non_filetype_match_injection_language_aliases = {
	ex = "elixir",
	pl = "perl",
	sh = "bash",
	uxn = "uxntal",
	ts = "typescript",
}

local function get_parser_from_markdown_info_string(alias)
	local m = vim.filetype.match({ filename = "a." .. alias })
	return m or non_filetype_match_injection_language_aliases[alias] or alias
end

-- 旧 nvim-treesitter は単一 TSNode を期待、新 Neovim は TSNode[] を渡す。
-- 両方を受け入れて末尾のノードを返す（quantified capture の最終マッチ相当）。
local function pick_node(value)
	if value == nil then
		return nil
	end
	if type(value) == "table" then
		return value[#value]
	end
	return value
end

function M.apply()
	local ok, query = pcall(require, "vim.treesitter.query")
	if not ok then
		return
	end
	local opts = { force = true, all = false }

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local id = pred[2]
		local node = pick_node(match[id])
		if not node then
			return
		end
		local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
		if not metadata[id] then
			metadata[id] = {}
		end
		metadata[id].text = string.lower(text)
	end, opts)

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local node = pick_node(match[pred[2]])
		if not node then
			return
		end
		local alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = get_parser_from_markdown_info_string(alias)
	end, opts)

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local node = pick_node(match[pred[2]])
		if not node then
			return
		end
		local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[type_attr_value]
		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(type_attr_value, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, opts)
end

-- テスト用フック: TSMatch を渡すと内部の pick_node ヘルパで取り出した
-- TSNode 相当の値を返す。実 directive は side-effect 経由なので
-- ユニットテストから検証しづらく、ここから抽象関数を export する。
M._pick_node = pick_node

return M
