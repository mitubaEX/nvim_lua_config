# nvim_lua_config
my lua config

## Requirements

- Neovim >= 0.5

## Installation

### Setup configuration

```
sh setup.sh
```
## Uninstallation

```
sh remove.sh
```

### Pre-commit

Copy the provided hook script to enable automatic Stylua checks when committing:

```
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## AI workflow

- `<leader>aa`: open an AI agent terminal in the project root
- `<leader>ar`: focus the existing AI agent terminal
- `<leader>at`: open a project shell at the bottom

The default AI agent command is `codex`. Override it with:

```sh
export AI_AGENT_CMD="your-agent-command"
```
