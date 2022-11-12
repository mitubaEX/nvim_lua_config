mkdir -p $HOME/.config/nvim

ln -sf $(pwd)/.config/nvim/init.lua $HOME/.config/nvim/init.lua

# lua
mkdir -p $HOME/.config/nvim/lua/lsp
mkdir -p $HOME/.config/nvim/lua/plugins/configs
find .config -type f | xargs -I% ln -sf $(pwd)/% $HOME/%
