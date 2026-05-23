---
name: nvim-test
description: このリポジトリの nvim Lua 設定に対する動作担保テストを追加・実行する skill。新規モジュール、user command、keymap、モジュール公開 API を変更した直後に呼んで、最低限の回帰テストを `tests/` 配下に追加する。`luac -p` / `stylua --check` / `nvim --headless` の 3 段構えで、Lua の test framework は使わない。
---

# nvim-test

`.config/nvim/lua/` 配下の変更に対し、最低限の動作保証テストを追加する。

`tmp_task.md` の各セクションにある「動作確認 (headless)」を、再現可能な
スクリプトとして `tests/` に落とすのがゴール。Lua の unit-test framework
(busted / plenary) は使わず、シェルから `nvim --headless` を叩く形に統一する。

## When to use

- 新規モジュールを `.config/nvim/lua/...` に追加した
- 既存モジュールの公開 API、user command、keymap を変えた
- バグ修正後、回帰しないよう担保したい

逆に **使わない** ケース:

- `doc/`, README, タスクメモのみの変更
- UI 描画 (Telescope picker の見た目、terminal 出力など) — headless で
  ブロックするので登録の有無だけ確認する

## Repo の前提

- 設定本体は `.config/nvim/` 配下。テストでは XDG 系をすべてリポジトリ内に
  向けて (`XDG_CONFIG_HOME` だけでなく `XDG_DATA_HOME` / `XDG_STATE_HOME` /
  `XDG_CACHE_HOME` も) リポジトリ内の `init.lua` をそのままロードさせる。
  こうすると「普段の config を実起動に近い形で読むが、ホスト環境
  (`~/.local/share/nvim` 等) には一切触れない／依存しない」になる。
  `XDG_CONFIG_HOME` だけだと `stdpath("data")` が `$HOME` 側を向き、
  lazy.nvim や shada が repo 外に漏れるので注意 (`run_nv` 参照)。
- lazy.nvim は `defaults = { lazy = true }`。コマンド／キーマップ確認の
  前に `Lazy load <plugin>` で明示的にロードする必要がある。
- **install は別 step**。`init.lua` は起動時に `lazy.nvim` を
  `stdpath("data")/lazy/lazy.nvim` に clone するが、残りのプラグインは
  入らない。テスト前に `bash tests/setup.sh` (中身は `Lazy! sync`) を一度
  走らせて repo-local data に install を済ませる。`run.sh` は install 済み
  前提で、テスト中にネットワーク sync を走らせない。
- この repo では `tmp_task.md` を作業メモとして使う運用がある (タスクごとに
  「動作確認 (headless)」セクションを持つ)。これは repo 固有の慣習なので、
  他リポジトリへ流用するときは読み替える。

## ディレクトリレイアウト

```
tests/
├── setup.sh            # 依存 install (Lazy! sync)。テスト前に 1 回
├── run.sh              # 全テストを順に実行する entrypoint
├── lib.sh              # 共通ヘルパ (run_nv / assert_cmd_exists 等)
├── 00-static.sh        # stylua + luac (リポジトリ全体に 1 回)
└── <feature>.sh        # feature ごとに 1 ファイル
```

`tests/` が無ければ skill 起動時に `lib.sh` / `run.sh` / `setup.sh` を生成
する。雛形は本ファイル末尾の「Templates」を参照。

## Test patterns (使うものを 1〜複数選ぶ)

### 1. 構文 / スタイル

リポジトリ全体に対して 1 回だけ走らせる。`tests/00-static.sh` に集約。

```sh
stylua --check .config/nvim/lua .config/nvim/init.lua
find .config/nvim -name '*.lua' -print0 | xargs -0 -n1 luac -p
```

`stylua --check` は対象を config ツリーに絞る。リポジトリ全体 (`.`) だと
vendored / 生成物の Lua まで巻き込んで、設定と無関係な理由で落ちうる。

`luac -p` は parse-only の安価なチェックだが、システムの `luac` は通常
Lua 5.4、Neovim は LuaJIT (5.1 相当) なので方言差に注意。純粋な parse なら
ほぼ問題ないが、もし valid な LuaJIT 構文を luac が誤検知するなら、
副作用に注意しつつ nvim 側 parse に切り替える:

```sh
find .config/nvim -name '*.lua' -print0 \
  | xargs -0 -I{} nvim --headless --clean -c 'luafile {}' -c qa
```

### 2. モジュールが require できる

```sh
run_nv -c 'lua local ok, m = pcall(require, "plugins.configs.worktree"); \
  if not ok or type(m) ~= "table" then \
    print("require failed: " .. tostring(m)); vim.cmd("cquit") end' \
  -c qa
```

### 3. user command が登録されている

```sh
run_nv -c 'silent! Lazy load git_worktree.nvim' \
  -c 'lua if vim.fn.exists(":GitWorktreeReview") ~= 2 then print("GitWorktreeReview not registered (load failed?)"); vim.cmd("cquit") end' \
  -c qa
```

`exists(":Cmd")` の戻り値は **2** が「コマンド登録済み」。`!= 2` で fail。
`Lazy load` が失敗した場合も後続の exists で落ちるので、メッセージに
「load failed?」と添えて原因を追いやすくする。`lib.sh` の
`assert_cmd_exists GitWorktreeReview` を使えば 1 行で書ける (ただし
`Lazy load` は別途呼ぶ)。

### 4. keymap が登録されている

```sh
run_nv -c 'silent! Lazy load git_worktree.nvim' \
  -c 'lua if vim.fn.maparg("<leader>gws", "n") == "" then print("missing keymap: n <leader>gws"); vim.cmd("cquit") end' \
  -c qa
```

単純な存在チェックなら `lib.sh` の `assert_keymap_exists n '<leader>gws'`
で済む。ただし `<lhs>` に quote / backslash が混じると shell quoting が
壊れやすいので、複雑なものは上の直書きのほうが安全。

prefix 衝突を疑うときは `verbose nmap <leader>gw` を `:redir` で拾って
内容を assert する。`<leader>gw` 単独が **無い** ことを確認するパターンも
書ける (`editor.lua` の事例)。

### 5. モジュールの公開 API が function である

```sh
run_nv -c 'lua local m = require("plugins.configs.worktree"); \
  for _, name in ipairs({"switch", "switch_to", "create_with_claude"}) do \
    if type(m[name]) ~= "function" then \
      print("missing: " .. name); vim.cmd("cquit") end end' \
  -c qa
```

### 6. 純粋関数の振る舞い

`format_pr_label` のような副作用の無い関数は、入出力のテーブルを書いて
`assert(actual == expected)` で十分。

```sh
run_nv -c 'lua \
  local m = require("plugins.configs.worktree"); \
  local cases = { \
    { nil, "" }, \
    { { number = 42, state = "OPEN", isDraft = false }, "#42" }, \
    { { number = 7,  state = "OPEN", isDraft = true  }, "#7(D)" }, \
    { { number = 25, state = "MERGED", isDraft = false }, "#25(M)" }, \
  }; \
  for _, c in ipairs(cases) do \
    local got = m.format_pr_label(c[1]); \
    if got ~= c[2] then \
      print("expected " .. c[2] .. " got " .. tostring(got)); vim.cmd("cquit") end end' \
  -c qa
```

純粋関数は M テーブルに公開されていない場合があるので、必要なら
`lua/plugins/configs/<mod>.lua` 側で `M._test = { format_pr_label = ... }` の
ように underscore 接頭の test seam を露出させる。

### 7. tabline / statusline のレンダリング確認

見た目そのものは追わないが、「ordinal が出る」程度の文字列なら
`nvim_eval_statusline` で拾って assert できる。

```sh
run_nv -c 'lua vim.o.columns = 200' \
  -c 'lua require("lazy").load({ plugins = { "bufferline.nvim" } })' \
  -c 'lua vim.schedule(function()
        local r = vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true }).str
        if not r:find("1.", 1, true) then print("no ordinal, got: "..r); vim.cmd("cquit") end
        vim.cmd("qa")
      end)'
```

**幅の罠**: headless はデフォルト 80 桁。要素が増えると bufferline /
lualine 等が truncate し、`1.` が `1` に縮むなどして literal 比較が
誤検知する。レンダリングを assert する前に `vim.o.columns` を広げる
(実ターミナルが tab bar に与える幅に寄せる)。プラグインのレイアウトは
`columns` 基準で組まれるので、`nvim_eval_statusline` の `maxwidth` だけ
広げても遅い。

## How to apply (skill 起動時の手順)

1. **変更面の特定**: 直近のコミット / 作業ツリーから、触ったモジュール、
   公開した関数、追加した user command / keymap を列挙する。
2. **`tests/` の存在確認**: 無ければ `Templates` の `lib.sh` / `run.sh` /
   `setup.sh` を生成し、`tests/00-static.sh` (stylua + luac) も入れる。
   `.gitignore` に repo-local XDG dir (`.local/` `.cache/`) を足す。
3. **依存 install**: repo-local data が空なら一度だけ `bash tests/setup.sh`
   (`Lazy! sync`) を走らせてプラグインを入れる。以後は install 済み前提。
4. **feature ファイル追加**: `tests/<feature>.sh` を作るか既存に追記。
   2〜6 のパターンから「その変更で壊れたら気付けるもの」を選ぶ。
   壊れていたはずの過去バグ (例: `<leader>gw` prefix 衝突) を再現する
   assertion を 1 行入れると価値が高い。
5. **ローカル実行**: `bash tests/run.sh` が exit 0 で抜けることを確認。
6. **`tmp_task.md` への反映**: 該当セクションの「動作確認」を、
   `bash tests/<feature>.sh` を貼る形に置き換える。

## Don't

- Lua の test framework (busted, plenary.test_harness) を入れない。
  `nvim --headless` のシェル一発で完結させる。
- ネットワーク・`gh auth`・実 telescope picker など対話的・外部依存に
  踏み込まない。`fetch_prs_by_branch` のような外部呼び出しは
  「`shell_error != 0` で空テーブルを返す退化パス」だけ assert する。
- `Lazy install` をテスト中に走らせない。install は `tests/setup.sh`
  (`Lazy! sync`) に分離し、CI でも本テストの前段で 1 回だけ実行する。
  `run.sh` 自体はネットワークに触れない。
- 失敗時のメッセージを省略しない。`print("expected X got Y")` を入れ、
  `cquit` で exit code を立てる。

---

## Templates

### `tests/lib.sh`

```sh
#!/usr/bin/env bash
# Common helpers for nvim headless tests.
#
# run_nv runs the repo's own init.lua but pins every XDG dir inside the repo,
# so tests read the real config without touching/depending on the host's
# ~/.local/share/nvim. Plugins must be installed first via tests/setup.sh.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_nv() {
  XDG_CONFIG_HOME="$REPO_ROOT/.config" \
  XDG_DATA_HOME="$REPO_ROOT/.local/share" \
  XDG_STATE_HOME="$REPO_ROOT/.local/state" \
  XDG_CACHE_HOME="$REPO_ROOT/.cache" \
    nvim --headless -u "$REPO_ROOT/.config/nvim/init.lua" "$@"
}

# assert_cmd_exists <Command>          # no leading ':'
# assert_keymap_exists <mode> <lhs>
# For richer checks (desc/callback/prefix collisions) use inline `-c 'lua ...'`;
# shell quoting here breaks once <lhs> has quotes/backslashes.
assert_cmd_exists() {
  local cmd="$1"
  run_nv -c "lua if vim.fn.exists(':$cmd') ~= 2 then print('missing command: $cmd'); vim.cmd('cquit') end" -c qa
}
assert_keymap_exists() {
  local mode="$1" lhs="$2"
  run_nv -c "lua if vim.fn.maparg('$lhs', '$mode') == '' then print('missing keymap: $mode $lhs'); vim.cmd('cquit') end" -c qa
}

export -f run_nv assert_cmd_exists assert_keymap_exists
export REPO_ROOT
```

`-u` で指定したリポジトリ内 init.lua を直接読み、XDG 系を repo 配下に
閉じることで「実起動に近いが host を汚さない／host に依存しない」を作る。
`--clean` は付けない (runtimepath / plugin 読み込みが普段と乖離するため)。
完全にホストから隔離したいだけなら `--clean` 路線もあるが、設定リポジトリ
の回帰テストとしては実起動に寄せる方を採る。

### `tests/setup.sh`

```sh
#!/usr/bin/env bash
# One-time/CI prep: install plugins into the repo-local data dir so run.sh can
# load them without depending on ~/.local/share/nvim. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."
source "$(dirname "$0")/lib.sh"

run_nv -c 'Lazy! sync' -c qa
```

### `tests/run.sh`

```sh
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
for t in tests/[0-9]*-*.sh tests/[a-z]*.sh; do
  [ -f "$t" ] || continue
  [ "$t" = "tests/lib.sh" ] && continue
  [ "$t" = "tests/run.sh" ] && continue
  [ "$t" = "tests/setup.sh" ] && continue
  printf '== %s ==\n' "$t"
  if ! bash "$t"; then
    echo "FAIL: $t"
    fail=1
  fi
done
exit "$fail"
```

glob は `[0-9]*-*.sh` (連番) と `[a-z]*.sh` (feature) を拾い、`lib.sh` /
`run.sh` / `setup.sh` だけ除外する。運用を単純化したいなら feature も
`NN-name.sh` に寄せて `for t in tests/[0-9][0-9]-*.sh` の 1 glob にしてもよい。

### `tests/00-static.sh`

```sh
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

stylua --check .config/nvim/lua .config/nvim/init.lua
find .config/nvim -name '*.lua' -print0 | xargs -0 -n1 luac -p
```

### `tests/<feature>.sh` の雛形

```sh
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# 1. require できる
run_nv -c 'lua local ok, m = pcall(require, "plugins.configs.<feature>"); \
  if not ok or type(m) ~= "table" then \
    print("require failed: " .. tostring(m)); vim.cmd("cquit") end' \
  -c qa

# 2. 公開 API
run_nv -c 'lua local m = require("plugins.configs.<feature>"); \
  for _, n in ipairs({"<fn1>", "<fn2>"}) do \
    if type(m[n]) ~= "function" then \
      print("missing: " .. n); vim.cmd("cquit") end end' \
  -c qa

# 3. user command / keymap (必要なら)
# run_nv -c 'Lazy load <plugin>.nvim' \
#   -c 'lua if vim.fn.exists(":<Cmd>") ~= 2 then vim.cmd("cquit") end' \
#   -c qa
```
