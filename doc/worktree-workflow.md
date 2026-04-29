# nvim x git worktree workflow

`mitubaEX/git_worktree.nvim` をベースに、worktree を多用するための運用メモ。

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
| `<leader>gwt`  | タスク文を渡して claude にブランチ名を決めさせ作業開始 |
| `<leader>gwT`  | `<leader>gwt` の default branch 起点版     |
| `<leader>gwX`  | 現在以外の worktree を一括削除（確認あり） |

Telescope picker（`<leader>gws`）では `<C-d>` で削除も可能。

実体は
[`lua/plugins/configs/worktree.lua`](../.config/nvim/lua/plugins/configs/worktree.lua)
と `lua/plugins/git.lua` の `keys = {...}` 定義。

## ディレクトリレイアウト

worktree は一律 `<repo_root>/.worktrees/<branch_safe_name>/` に作られる
（`/` は `_` に置換）。元リポを汚さないので `.gitignore` に
`.worktrees/` を入れておくと安全。

## `.worktreeinclude`: 新 worktree にコピーするファイルを宣言

`git_worktree.nvim` は worktree 作成時、リポジトリルートにある
`.worktreeinclude` を読み、そこに書かれたパスを新 worktree にコピーする
（`:GitWorktreeReview` のレビュー用 worktree でも同じ）。`.envrc` を
暗黙にコピーしていた旧挙動は廃止されているので、必要なものは明示する。

- 1 行 1 パス、リポジトリルート相対
- `#` 始まりと空行は無視
- ファイルもディレクトリも OK
- 既存ファイルは上書きしない（target に同名があればスキップ）
- 絶対パスや `..` を含むパスは安全のため拒否

例:

```
# direnv / ローカル環境
.envrc
.envrc.local
.env.development

# エディタ / ツール状態
.vscode
.idea/runConfigurations

# ローカル用スクリプト
scripts/dev-secrets.sh
```

`.worktreeinclude` 自体は git 管理に入れて共有してよい（中身は単なるパス
リスト）。コピーされる `.envrc` などは個人ごとなので `.gitignore` 側で
ignore するのが普通。

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
- `<leader>gwt` — ブランチ名の代わりに「やりたいこと」を入力。`claude -p`
  を裏で叩いて kebab-case のブランチ名候補を1つもらい、その候補（編集可）
  で確定すると worktree が作られ、claude にそのタスク文がそのまま初期
  prompt として渡される。`<leader>gwT` は default branch 起点版。

### セッション継続

- claude のセッションは cwd 単位で永続化されるので、nvim を閉じて開き直しても
  `<leader>cC`（`-c`）で続きから再開できる。
- 横断で過去セッションを探したいときは `<leader>cr` の picker。

## 典型フロー

1. main worktree で作業中、別 issue が割り込み: `<leader>gwa`
   → ブランチ名入力。worktree が作られ、その cwd で claude が起動。
   リポジトリルートに `.worktreeinclude` があれば、そこに列挙したファイルが
   新 worktree にコピーされる。
2. 元の作業に戻る: `<leader>gws` で worktree 切替 → `<leader>cc` で
   そのブランチの claude セッションへ。
3. PR レビュー: `<leader>gwR` → PR 番号入力。fork からの PR でも
   remote を自動追加し、`--from-pr` で対応セッションを開く。
4. 終わった worktree は `<leader>gwd` または `<leader>gwX` で一括掃除。

## トレードオフ

- **claude を auto-open するか**: `<leader>gwa/A/R` は明示的に「+ claude」した
  ときだけ起動。素の `<leader>gwc` は claude を開かないので、ターミナル
  ペインを汚したくない用途と分けられる。
