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

- 設定本体は `.config/nvim/` 配下。テストでは
  `XDG_CONFIG_HOME="$PWD/.config"` を渡して、リポジトリ内の `init.lua` を
  そのままロードさせる。
- lazy.nvim は `defaults = { lazy = true }`。コマンド／キーマップ確認の
  前に `Lazy load <plugin>` で明示的にロードする必要がある。
- `init.lua` は起動時に `lazy.nvim` を `stdpath("data")/lazy/lazy.nvim` に
  clone しようとする。CI 等で未 clone なら `nvim --headless` を一度走らせて
  install を済ませてから本テストに入る。

## ディレクトリレイアウト

```
tests/
├── run.sh              # 全テストを順に実行する entrypoint
├── lib.sh              # 共通ヘルパ (run_nv / assert_cmd_exists 等)
└── <feature>.sh        # feature ごとに 1 ファイル
```

`tests/` が無ければ skill 起動時に `lib.sh` と `run.sh` を生成する。雛形は
本ファイル末尾の「Templates」を参照。

## Test patterns (使うものを 1〜複数選ぶ)

### 1. 構文 / スタイル

リポジトリ全体に対して 1 回だけ走らせる。`tests/00-static.sh` に集約。

```sh
stylua --check .
find .config/nvim -name '*.lua' -print0 | xargs -0 -n1 luac -p
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
run_nv -c 'Lazy load git_worktree.nvim' \
  -c 'lua if vim.fn.exists(":GitWorktreeReview") ~= 2 then vim.cmd("cquit") end' \
  -c qa
```

`exists(":Cmd")` の戻り値は **2** が「コマンド登録済み」。`!= 2` で fail。

### 4. keymap が登録されている

```sh
run_nv -c 'Lazy load git_worktree.nvim' \
  -c 'lua if vim.fn.maparg("<leader>gws", "n") == "" then vim.cmd("cquit") end' \
  -c qa
```

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

## How to apply (skill 起動時の手順)

1. **変更面の特定**: 直近のコミット / 作業ツリーから、触ったモジュール、
   公開した関数、追加した user command / keymap を列挙する。
2. **`tests/` の存在確認**: 無ければ `Templates` の `lib.sh` と `run.sh` を
   生成し、`tests/00-static.sh` (stylua + luac) も入れる。
3. **feature ファイル追加**: `tests/<feature>.sh` を作るか既存に追記。
   2〜6 のパターンから「その変更で壊れたら気付けるもの」を選ぶ。
   壊れていたはずの過去バグ (例: `<leader>gw` prefix 衝突) を再現する
   assertion を 1 行入れると価値が高い。
4. **ローカル実行**: `bash tests/run.sh` が exit 0 で抜けることを確認。
5. **`tmp_task.md` への反映**: 該当セクションの「動作確認」を、
   `bash tests/<feature>.sh` を貼る形に置き換える。

## Don't

- Lua の test framework (busted, plenary.test_harness) を入れない。
  `nvim --headless` のシェル一発で完結させる。
- ネットワーク・`gh auth`・実 telescope picker など対話的・外部依存に
  踏み込まない。`fetch_prs_by_branch` のような外部呼び出しは
  「`shell_error != 0` で空テーブルを返す退化パス」だけ assert する。
- `Lazy install` をテスト中に走らせない。CI で必要なら別 step で先に
  `nvim --headless -c "Lazy! sync" -c qa` を済ませる。
- 失敗時のメッセージを省略しない。`print("expected X got Y")` を入れ、
  `cquit` で exit code を立てる。

---

## Templates

### `tests/lib.sh`

```sh
#!/usr/bin/env bash
# Common helpers for nvim headless tests.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_nv() {
  XDG_CONFIG_HOME="$REPO_ROOT/.config" \
    nvim --headless --clean -u "$REPO_ROOT/.config/nvim/init.lua" "$@"
}
export -f run_nv
export REPO_ROOT
```

`--clean` で `$HOME/.config/nvim` の symlink ではなく、`-u` で指定した
リポジトリ内 init.lua を直接読ませる。`XDG_CONFIG_HOME` は lazy.nvim の
`stdpath("config")` を repo 側に向ける役割。

### `tests/run.sh`

```sh
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
for t in tests/[0-9]*-*.sh tests/[a-z]*.sh; do
  [ -f "$t" ] || continue
  [ "$t" = "tests/lib.sh" ] && continue
  printf '== %s ==\n' "$t"
  if ! bash "$t"; then
    echo "FAIL: $t"
    fail=1
  fi
done
exit "$fail"
```

### `tests/00-static.sh`

```sh
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

stylua --check .
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
