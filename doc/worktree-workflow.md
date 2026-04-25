# nvim x git worktree workflow

`mitubaEX/git_worktree.nvim` をベースに、Rails / Node / React / Go のリポで
worktree を多用するための運用メモ。

## キーマップ

すべて normal mode、prefix は `<leader>gw`。

| key            | 動作                                       |
| -------------- | ------------------------------------------ |
| `<leader>gwc`  | 新規 worktree 作成（現 HEAD 起点）         |
| `<leader>gwC`  | 新規 worktree 作成（default branch 起点）  |
| `<leader>gws`  | Telescope で worktree 切替                 |
| `<leader>gwd`  | branch 名指定で worktree 削除              |
| `<leader>gwl`  | 一覧表示                                   |
| `<leader>gw.`  | 現在の worktree を表示                     |
| `<leader>gwr`  | GitHub PR 番号からレビュー用 worktree 作成 |
| `<leader>gwa`  | 新規 worktree 作成 + claude を起動         |
| `<leader>gwA`  | default branch 起点で作成 + claude         |
| `<leader>gwR`  | PR レビュー用 worktree + `claude --from-pr`|
| `<leader>gwX`  | 現在以外の worktree を一括削除（確認あり） |

Telescope picker（`<leader>gws`）では `<C-d>` で削除も可能。

実体は
[`lua/plugins/configs/worktree.lua`](../.config/nvim/lua/plugins/configs/worktree.lua)
と `lua/plugins/git.lua` の `keys = {...}` 定義。

## ディレクトリレイアウト

worktree は一律 `<repo_root>/.worktrees/<branch_safe_name>/` に作られる
（`/` は `_` に置換）。元リポを汚さないので `.gitignore` に
`.worktrees/` を入れておくと安全。

## 言語別レシピ

このリポの [`doc/worktree-profiles/`](./worktree-profiles/) に雛形あり。
プロジェクト側にコピーして使う。

### 共通: `.envrc` で worktree ごとに port / DB を分ける

`git_worktree.nvim` は worktree 作成時に元リポの `.envrc` を新 worktree に
コピーするので、`direnv` 前提でブランチ名から決定的に値を導出する書き方が
便利:

```sh
WT_BRANCH=$(git rev-parse --abbrev-ref HEAD | tr '/' '_')
WT_HASH=$(printf '%s' "$WT_BRANCH" | cksum | cut -d' ' -f1)
export PORT=$((3000 + WT_HASH % 1000))
```

これで dev サーバを複数 worktree で同時起動してもポート衝突しない。

post-create のセットアップ（依存解決・DB 準備）は、各プロジェクトに既にある
`bin/setup` / `Makefile` / `package.json` の script をそのまま使うのが簡単。
worktree 作成時にこう繋げる:

```
:GitWorktreeCreate feature/foo --command "!bin/setup"
:GitWorktreeCreate feature/foo --command "!pnpm install"
:GitWorktreeCreate feature/foo --command "!make setup"
```

### Rails

雛形: [`rails.envrc`](./worktree-profiles/rails.envrc)

要点:

- **DB は worktree ごとに分離**（`myapp_<branch>`）。マイグレーションを
  並行ブランチで触っても壊れない。
- **bundle path はグローバル共有**（`bundle config set --global path
  ~/.bundle`）。worktree ごとに `vendor/bundle` を持たない。
- post-create は `bin/setup` を `--command "!bin/setup"` で呼ぶ。

### Node / React

雛形: [`node.envrc`](./worktree-profiles/node.envrc)

要点:

- **pnpm のグローバル store を使う**（`pnpm config set store-dir
  ~/.pnpm-store`）と、worktree ごとに `pnpm install` しても実体はハードリンク。
- Vite/Next の `PORT` を `.envrc` で分離。Next.js を複数 worktree で
  同時起動するなら `NEXT_BUILD_DIR` も分けると `.next/` の取り合いが消える。
- `.env.local` が必要なら `cp .env.example .env.local` を `--command` で
  ワンショット実行。

### Go

雛形: [`go.envrc`](./worktree-profiles/go.envrc)

要点:

- module cache (`$GOMODCACHE`) と build cache はもともと content-addressable
  なので worktree 横断で勝手に共有される。**post-create は基本不要**。
- `PORT` だけ `.envrc` で分けておけばよい。

## Claude (`:terminal`) 連携

`:terminal claude` を **worktree（cwd）ごとに 1 セッション**保持する小モジュールが
[`lua/plugins/configs/claude_term.lua`](../.config/nvim/lua/plugins/configs/claude_term.lua)
にある。worktree を切り替えると cwd が変わるので、各ブランチに 1 つずつ
独立した claude セッションが紐づく。

### キーマップ（prefix `<leader>c`）

| key            | 動作                                            |
| -------------- | ----------------------------------------------- |
| `<leader>cc`   | claude ターミナルを toggle（隠す/出す）         |
| `<leader>co`   | 強制 open（fresh session）                       |
| `<leader>cC`   | `claude -c`（cwd の直前セッションを continue）  |
| `<leader>cr`   | `claude -r`（resume picker）                    |
| `<leader>cx`   | このセッションを kill                           |
| `<leader>cs`   | (visual) 選択範囲を現在の claude に send        |

### user commands

`:Claude [prompt]`, `:ClaudeContinue`, `:ClaudeResume [id]`,
`:ClaudeFromPR <num>`, `:ClaudeToggle`, `:ClaudeKill`, `:ClaudeSend <text>`。

worktree 作成時の `--command` 経由でも呼べる:

```
:GitWorktreeCreate feature/x --command "Claude \"summarize TODO.md\""
```

### worktree との合わせ技

- `<leader>gwa` — 新規 worktree 作成と同時に claude を起動（branch 名が
  そのまま `claude -n <branch>` の display name になる）
- `<leader>gwA` — default branch 起点版
- `<leader>gwR` — PR レビュー: 当該 PR の worktree を作り、その上で
  `claude --from-pr <num>` を起動。Claude が PR にひも付いた既存セッションを
  あれば再開、なければ新規作成する

### セッション継続

- claude のセッションは cwd 単位で永続化されるので、nvim を閉じて開き直しても
  `<leader>cC`（`-c`）で続きから再開できる。
- 横断で過去セッションを探したいときは `<leader>cr` の picker。

## 典型フロー

1. main worktree で作業中、別 issue が割り込み: `<leader>gwa`
   → ブランチ名入力。worktree が作られ、その cwd で claude が起動。
   `.envrc` も自動コピーされるので `direnv allow` で port/DB 分離。
2. 依存もまとめてセットアップしたいときは
   `:GitWorktreeCreate xxx --command "!bin/setup"` のようにプロジェクトの
   既存スクリプトを直接呼ぶ。そこから `<leader>cc` で claude を立ち上げる。
3. 元の作業に戻る: `<leader>gws` で worktree 切替 → `<leader>cc` で
   そのブランチの claude セッションへ。
4. PR レビュー: `<leader>gwR` → PR 番号入力。fork からの PR でも
   remote を自動追加し、`--from-pr` で対応セッションを開く。
5. 終わった worktree は `<leader>gwd` または `<leader>gwX` で一括掃除。

## トレードオフ

- **依存共有 vs. 独立**: pnpm store / 共通 bundle path はディスクと時間を
  大幅に節約するが、ネイティブ拡張の ABI ズレが起きると複数 worktree が
  同時に壊れる。怪しくなったら該当言語だけ独立配置に戻す。
- **post-create 自動実行 vs. 明示**: Rails の `bin/setup` は数十秒かかる。
  作成キーを `<leader>gwc`（軽い）と「init 付き」を別キーにする運用も可。
  現状は明示的に `--command` を渡す前提。
- **claude を auto-open するか**: `<leader>gwa/A/R` は明示的に「+ claude」した
  ときだけ起動。素の `<leader>gwc` は claude を開かないので、ターミナル
  ペインを汚したくない用途と分けられる。
