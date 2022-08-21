local obsidian_dir = "~/Library/Mobile\\ Documents/iCloud\\~md\\~obsidian/Documents/my-vault"

local function open_daily_note()
  local today = os.date("%Y-%m-%d")
  local daily_note_path = obsidian_dir .. '/' .. today .. '.md'
  vim.cmd('e ' .. daily_note_path)
end
vim.api.nvim_create_user_command(
  'OpenDailyNote',
  open_daily_note,
  {}
)
