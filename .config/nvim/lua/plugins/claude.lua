return {
	{
		"mitubaEX/claude_workflow.nvim",
		-- Loaded on first :Claude* command. Keymaps in lua/config/claude.lua and
		-- the worktree+claude flow in plugins/configs/worktree.lua both go through
		-- `require("claude_workflow")`, which lazy.nvim's require-hook also picks
		-- up — so no explicit `keys = {...}` block needed.
		cmd = {
			"Claude",
			"ClaudeContinue",
			"ClaudeResume",
			"ClaudeFromPR",
			"ClaudeToggle",
			"ClaudeKill",
			"ClaudeSend",
		},
		config = function()
			require("claude_workflow").setup()
		end,
	},
}
