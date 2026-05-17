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
各行はこの並びで表示される: `<状態> <branch> <PR ラベル> <path>`。`<状態>` は
`*`（現 cwd）/ `T`（既にタブで開いている）/ ` `（その他）。`<PR ラベル>` は
`gh pr list` の結果から、open は `#25`、draft は `#25(D)`、merged は `#25(M)`、
PR 無し / closed は空欄。`gh` 未インストール・未認証時は全行で空欄になる。

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

### claude を「自走モード」で立ち上げる

`<leader>gwa / gwA / gwt / gwT` は worktree+claude を開くとき、`worktree.lua`
内に埋め込んだ汎用の自走指示を `claude --append-system-prompt` に流す。
リポジトリごとに設定ファイルを置く必要はなく、claude 側で
`package.json` / `Makefile` / `Procfile` / `docker-compose.yml` / `README` /
`.envrc` / `CLAUDE.md` を見て起動方法とテストコマンドを **その場で調査** し、
実装 → サーバー起動 → 動作確認 → `gh pr create --fill` までを 1 セッションで
完結させる、という指示が入っている。

実体は `lua/plugins/configs/worktree.lua` の `DEFAULT_WORKFLOW_PROMPT`。
中身を変えたい / 黙らせたい場合:

```lua
-- 上書き
vim.g.claude_worktree_prompt = [[
  あなたのプロジェクト固有の指示をここに...
]]

-- 自走モード自体を無効化（手動でやりたい）
vim.g.claude_worktree_prompt = false
```

`<leader>gwR` (PR レビュー経路) には自走指示は **渡さない**。`claude --from-pr`
が既存セッションを拾うので、レビューの文脈を二重に上書きしないため。

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
3. 動作確認: `<leader>ss`（または `:ServerStart <cmd>`）で cwd 専用の
   server :terminal を立てる。各 worktree タブで独立に動くので、複数
   ブランチを並列でローカル検証できる。port 衝突は `.envrc` や
   ブランチ依存の起動スクリプト側で吸収する前提。
4. 問題なければ PR を作る: `<leader>gpc`（または `<leader>gpC` で
   claude にレビュー依頼まで一筆書き）。URL は `+` register に入る。
5. PR レビュー: 他人 PR は `<leader>gwR` → PR 番号。fork PR も
   remote 自動追加で `--from-pr` で開ける。
6. 終わった worktree は `<leader>gwd` または `<leader>gwX` で一括掃除。

## PR step (`<leader>gp*`)

`gh` CLI を叩く軽い wrapper。worktree タブで作業を済ませた後、その cwd で
そのまま PR を作って claude にレビューを依頼するまでを 1〜2 キーで通せる。

| key            | 動作                                       |
| -------------- | ------------------------------------------ |
| `<leader>gpc`  | push + `gh pr create --fill`                |
| `<leader>gpC`  | push + create + 同タブ claude にレビュー依頼 |
| `<leader>gpd`  | `--draft` で作成                            |
| `<leader>gpv`  | 現ブランチの PR を browser で開く           |
| `<leader>gps`  | `gh pr status`                              |
| `<leader>gpr`  | 既存 PR を claude にレビュー依頼             |

user commands も同じ動線: `:PRCreate[!]` / `:PRCreateReview[!]` /
`:PRView` / `:PRStatus` / `:PRReview`。`!` は `--draft` 相当。

実体は
[`lua/plugins/configs/pr.lua`](../.config/nvim/lua/plugins/configs/pr.lua)、
配線は [`lua/common/pr.lua`](../.config/nvim/lua/common/pr.lua)。

### 仕様メモ

- 既に open PR があるブランチで `:PRCreate` を叩くと、既存 PR を再利用して
  `on_success` に流す（`<leader>gpC` 経路でレビュー依頼だけ走らせ直したい
  ケースで便利）。
- `gh` 未インストール / 未認証は早期 `vim.notify(... ERROR)` で抜ける
  ので、ワークフロー全体は壊れない。
- レビュー prompt は `M.review_prompt(n)` に切り出してあるので、
  好みで書き換えると `<leader>gpr` / `<leader>gpC` の口調が変わる。

## トレードオフ

- **claude を auto-open するか**: `<leader>gwa/A/R` は明示的に「+ claude」した
  ときだけ起動。素の `<leader>gwc` は claude を開かないので、ターミナル
  ペインを汚したくない用途と分けられる。
- **PR 作成と claude レビューを分けるか合体するか**: `<leader>gpc` と
  `<leader>gpC` の両方を用意。「自分で見直してから出す」場合は
  `gpc` → 自分で diff 確認 → `gpr`、流して投げる場合は `gpC` で一発。
