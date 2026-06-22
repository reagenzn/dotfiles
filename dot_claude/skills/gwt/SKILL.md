---
name: gwt
description: Git worktree操作をgwt（git gtr）経由で実行する。トリガー: "worktree", "ワークツリー", "並行作業", "ブランチ作業", "worktree作成", "worktree削除", "gwt設定", "gwt setup" 使用場面: (1) worktreeの作成・削除・一覧、(2) worktreeでのエディタ・AI起動、(3) worktreeでのコマンド実行、(4) マージ済みworktreeの整理、(5) リポジトリのgwt設定(.gtrconfig)生成、(6) Docker環境のworktree分離設定
---

# gwt (git-worktree-runner)

Git worktree操作を安全かつ効率的に管理するスキル。

## 重要なルール（必ず守ること）

1. **`git worktree` コマンドを直接使用しないこと。** すべてのworktree操作は `git gtr` 経由で実行する。
2. worktree作成は `git gtr new` を使用し、`git worktree add` を実行しない。
3. worktree削除は `git gtr rm` を使用し、`git worktree remove` を実行しない。
4. worktree一覧は `git gtr list` を使用し、`git worktree list` を実行しない。
5. worktreeのパス取得は `git gtr go <branch>` を使用する。
6. worktree内でのコマンド実行は `git gtr run <branch> "<cmd>"` を使用する。
7. リポジトリに `.gtrconfig` が存在しない場合、設定の初期化を提案する。

## コマンド一覧

| コマンド | 説明 | 使用例 |
| --- | --- | --- |
| `git gtr new <branch>` | 新しいworktreeを作成 | `git gtr new feature/login` |
| `git gtr editor <branch>` | worktreeをエディタで開く | `git gtr editor feature/login` |
| `git gtr ai <branch>` | worktreeでAIツールを起動 | `git gtr ai feature/login` |
| `git gtr go <branch>` | worktreeのパスを表示 | `git gtr go feature/login` |
| `git gtr run <branch> <cmd>` | worktree内でコマンド実行 | `git gtr run feature/login "npm test"` |
| `git gtr list` | worktree一覧を表示 | `git gtr list` |
| `git gtr rm <branch>` | worktreeを削除 | `git gtr rm feature/login` |
| `git gtr clean --merged` | マージ済みworktreeを一括削除 | `git gtr clean --merged` |
| `git gtr config` | 設定を管理 | `git gtr config` |

## Git エイリアス

| エイリアス | コマンド |
| --- | --- |
| `git wn <branch>` | `git gtr new` |
| `git we <branch>` | `git gtr editor` |
| `git wa <branch>` | `git gtr ai` |
| `git wg <branch>` | `git gtr go` |
| `git wr <branch> <cmd>` | `git gtr run` |
| `git wl` | `git gtr list` |
| `git wrm <branch>` | `git gtr rm` |
| `git wc` | `git gtr clean --merged` |

## worktree作成時のポートセットアップ

**重要: `git gtr new` を実行すると、`.gtrconfig` の `postCreate` hookにより `claude -p` が自動起動してこのセクションの処理を実行する。そのため、対話的セッションで `git gtr new` を実行した場合、ポートセットアップを手動で行う必要はない。hookが自動で処理する。**

以下は `postCreate` hookから `claude -p` で呼び出された場合の処理手順。
planモードに入らず、ユーザーへの確認なしで、すべてのステップを即座に実行すること。

### Step 1: ポート分離スクリプトの実行

カレントディレクトリ（= worktreeのルート）を引数にしてスクリプトを実行する:

```bash
~/.claude/skills/gwt/worktree-port-setup.sh .
```

このスクリプトは以下を**すべて自動処理**する:
- root `.env` 内のすべての `*_PORT=` 変数にランダムポート（10000-60000）を割り当て
- `COMPOSE_PROJECT_NAME` をブランチ名ベースで自動設定（コンテナ名衝突を防止）
- 使用中ポートを `lsof` でチェックし空きポートのみ割り当て
- **サブディレクトリの env ファイル（app/.env.development, front/.env.local 等）内の `localhost:旧ポート` を `localhost:新ポート` に自動書き換え**

### Step 2: docker-compose.yml のポート変数化チェック

`docker-compose.yml` または `compose.yml` が存在する場合のみ実行する。
ポートがハードコードされている場合は、`.env` 変数参照に自動修正する:

```yaml
# NG: ハードコード
ports:
  - "3000:3000"

# OK: .env変数参照
ports:
  - "${APP_PORT:-3000}:3000"
```

修正手順:
1. `docker-compose.yml` の各サービスの `ports:` を解析
2. ホスト側ポートに対応する `*_PORT` 変数名を推測（サービス名ベース）
3. `.env.example` にデフォルト値付きで変数を追加
4. `docker-compose.yml` のポートを `${変数名:-デフォルト値}:内部ポート` 形式に書き換え
5. hardcoded な `container_name` がある場合は削除（COMPOSE_PROJECT_NAMEで自動プレフィックスされる）

### Step 3: フロント・バックエンドのポート確認

worktree内のサブディレクトリ env ファイルも確認し、ポートの整合性を保つ:

- **バックエンド**: `app/.env.development` 等の `BACKEND_URL`, `LOCALSTACK_ENDPOINT`, `DYNAMODB_ENDPOINT` 等の `localhost:ポート` がStep 1で書き換え済みか確認。未対応なら修正。
- **フロントエンド**: `front/.env.local` 等の `VITE_MASTRA_API_URL` 等の `localhost:ポート` がStep 1で書き換え済みか確認。Viteのポート衝突は自動回避されるため優先度低。
- **Mastraバックエンドのポート変更**: `mastra dev` 実行時に `PORT` 環境変数で制御可能。root `.env` の `MASTRA_PORT` の値を使い、`PORT=<MASTRA_PORT> npm run mastra:dev` で起動するようユーザーに案内する。

### 重要な注意点

- **ホスト側ポートのみ変更する。** docker-compose.yml内のサービス間通信は内部ネットワーク（サービス名:内部ポート）を使用するため、コンテナ内部ポートは変更不要。
- `.env.example` は**コピー元のテンプレート**なのでポートのデフォルト値を維持する。変更するのは `.env` と実際の env ファイルのみ。

## .gtrconfig 自動生成

「gwt設定して」「gwt setup」等のリクエストを受けた場合:

1. プロジェクトのファイルを分析して種別を判定する:
   - `package.json` → Node.js (npm/pnpm/yarn を判別)
   - `requirements.txt` / `pyproject.toml` → Python
   - `go.mod` → Go
   - `docker-compose.yml` / `compose.yml` → Docker利用あり
2. 判定結果に基づいて `.gtrconfig` を生成する
3. テンプレート利用の場合: `git winitt <template>` を実行（node, python, pnpm）
4. カスタム設定の場合: `git winit` でインタラクティブウィザードを実行

### テンプレート一覧

| テンプレート | postCreate | copyパターン |
| --- | --- | --- |
| node | `npm install` | `.env.example`, `.env.local` |
| python | `pip install -r requirements.txt` | `.env.example` |
| pnpm | `pnpm install` | `.env.example`, `.env.local` |

## 設定の優先順位

1. ローカル `.git/config` (git config --local)
2. リポジトリルートの `.gtrconfig`
3. グローバル `~/.gitconfig`

## 設定オプション

| 設定キー | 説明 | 値の例 |
| --- | --- | --- |
| `gtr.editor.default` | デフォルトエディタ | vs-code, cursor, zed |
| `gtr.ai.default` | デフォルトAIツール | claude, aider |
| `gtr.copy.include` | コピーするファイルパターン | **/.env.example |
| `gtr.copy.exclude` | 除外するファイルパターン | **/dist/** |
| `gtr.copy.includeDirs` | コピーするディレクトリ | node_modules |
| `gtr.hook.postCreate` | 作成後フック | npm install |
| `gtr.hook.preRemove` | 削除前フック | npm run clean |

## 使用例

### 新しいworktreeを作成

```bash
git gtr new feature/user-auth
git gtr editor feature/user-auth
```

### worktree内でテスト実行

```bash
git gtr run feature/user-auth "npm test"
```

### マージ済みworktreeの整理

```bash
git gtr list
git gtr clean --merged
```

### リポジトリのgwt設定を初期化

```bash
# テンプレートから
git winitt node

# インタラクティブ
git winit
```
