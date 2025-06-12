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
