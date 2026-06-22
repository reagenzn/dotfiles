# Issue 実装ワークフロー

引数: $ARGUMENTS（Issue番号 例: #338、またはIssue URL）

## 概要

Issue を受け取り、worktree 上で CLAUDE.md 準拠の開発フローを完遂するワークフロー。

---

## 鉄則

- **wt0（メインリポ）で直接実装しない** — 必ず worktree（wt1〜wt5）で作業する
- **rebase 禁止** — develop の取り込みは必ず `git merge` を使う。`git pull --rebase` や `git rebase` は**絶対に使わない**（他PRと重複するコミットがリベースで書き換えられ、毎回コンフリクトする原因になる）
- **ブランチは develop の最新から分岐する** — 古い develop から分岐すると差分が膨らみコンフリクトが増える

---

## フェーズ1: 準備

1. **develop を最新化**（wt0 で実行）

   ```
   cd ~/aix_workspace/aix-aq-ai-datalake-builder-analysis && git pull origin develop
   ```

2. **Issue の内容を取得**
   - `gh issue view <番号>` で Issue のタイトル・本文・ラベルを読む
   - 実装に必要な情報を把握する

3. **空いている worktree を選択**
   - `git worktree list` で一覧を確認
   - `worktree/wtN`（初期ブランチ）のままのものが空き
   - 空きがなければユーザに報告して停止

4. **作業ブランチを作成**（worktree で実行）
   - ブランチ名: `fix/#<番号>-<slug>` または `feat/#<番号>-<slug>`（Issue 内容に応じて）
   - slug は Issue タイトルから英語のケバブケースで生成
   - **⚠️ 必ず `origin/develop` から分岐する**（ローカルの `develop` は古い場合がある）

   ```
   cd ~/aix_workspace/aix-analysis-worktrees/wtN
   git fetch origin develop
   git checkout -b <ブランチ名> origin/develop
   ```

5. **worktree パスを変数として記録し、以降すべての操作で使用**
   - `WT_DIR=~/aix_workspace/aix-analysis-worktrees/wtN` として以降のフェーズで参照
   - ファイル編集・テスト実行・git 操作はすべて絶対パス（`$WT_DIR/...`）で行う
   - セッション切り替えは不要。現在のセッションからそのまま続行する

6. **フェーズ2に直接進む**

---

## フェーズ2: 実装（CLAUDE.md 準拠）

1. **他の worktree の開発サーバーを停止し、作業 worktree でサーバーを起動**
   ```
   # ポート 6073 を使用中のプロセスを停止
   lsof -ti:6073 | xargs kill -9 2>/dev/null
   # worktree でサーバー起動（Turbopack なし）
   cd $WT_DIR/app && nohup npx next dev -p 6073 > /tmp/wtN-next.log 2>&1 &
   ```

   - worktree では `--turbopack` は使用不可（node_modules がシンボリックリンクのため）
   - 起動確認: `tail -5 /tmp/wtN-next.log` で `Ready` が出ること
2. **品質基準スキルを参照** — 該当する観点を確認
3. **TDD ワークフロー**で実装:
   - RED: テストを先に書く
   - GREEN: テストをパスする最小限の実装
   - IMPROVE: リファクタリング
4. テストは `cd $WT_DIR/app && npx vitest run` で実行
5. 実装中は worktree 内のファイルのみ編集する

---

## フェーズ3: 品質チェック

1. **code-reviewer エージェント**でコードレビューを実施
2. **quality-standards スキル**で品質基準を再チェック
3. Critical/High の指摘があれば修正してフェーズ2に戻る
4. 結果をユーザに報告し、**ユーザの承認を待つ**

---

## フェーズ4: PR 作成

ユーザの承認後:

1. **develop の最新を取り込む**（PR 作成前に必須）
   ```
   cd $WT_DIR
   git fetch origin develop
   git merge origin/develop
   ```

   - コンフリクトが発生した場合は手動で解決し、テストを再実行して確認
2. コミット（Conventional Commits 形式）
3. `git push -u origin <ブランチ名>`
4. `gh pr create` で PR 作成
   - `--base develop`
   - タイトル: Conventional Commits 形式
   - body に `Closes #<番号>` を含める
5. PR URL をユーザに報告

---

## フェーズ5: PR レビュー対応

1. PR 上の CI レビュー指摘を `gh api repos/{owner}/{repo}/pulls/<PR番号>/comments` で取得
2. 指摘内容をユーザに報告
3. ユーザの指示に従い修正・コミット・プッシュ
4. 指摘が解消されるまで繰り返す

### コンフリクト対応（develop が進んだ場合）

PR が CONFLICTING になった場合:

```
cd $WT_DIR
git fetch origin develop
git merge origin/develop
# コンフリクトを解決
git add <解決済みファイル>
git commit   # マージコミット
# テスト再実行
cd $WT_DIR/app && npx vitest run
git push
```

**⚠️ `git rebase` は絶対に使わない。** rebase すると既存コミットのハッシュが変わり、他 PR と重複するコミットが毎回コンフリクトを引き起こす。

---

## フェーズ6: クリーンアップ

ユーザから「片付けて」等の指示があったら:

1. worktree を初期ブランチに戻す
   ```
   cd ~/aix_workspace/aix-analysis-worktrees/wtN
   git checkout worktree/wtN
   ```
2. 作業ブランチをローカルから削除
   ```
   git branch -d <ブランチ名>
   ```
3. worktree の初期ブランチをリモートの develop と同期
   ```
   git fetch origin develop
   git pull origin develop
   ```
4. メインリポで develop を最新化
   ```
   cd ~/aix_workspace/aix-aq-ai-datalake-builder-analysis
   git pull origin develop
   ```
---

## 注意事項

- 各フェーズの区切りでユーザに状況を報告する
- フェーズ3の承認とフェーズ6の開始はユーザの明示的な指示を待つ
- Turbopack は worktree で使用不可（`npx next dev -p <port>` を使う）
- `pnpm i` は元リポ（wt0）で実行
- **push が reject された場合**: `git pull --rebase` ではなく `git fetch origin && git merge origin/<ブランチ名>` を使う
