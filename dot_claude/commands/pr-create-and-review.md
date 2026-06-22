# PR 作成 & レビュー & 修正ワークフロー

引数: $ARGUMENTS（PR の概要説明。例: 「ユーザー一覧画面にページネーション追加」。空の場合はコミット履歴から自動判定）

## 概要

PR の作成からレビュー、レビュー指摘の精査・修正までを一貫して行うワークフロー。
`/pr-review-toolkit:review-pr` を活用し、品質を担保した上で PR を仕上げる。

---

## Step 1: 現状把握

以下を並列で実行し、PR 作成に必要な情報を収集する。

```bash
git status
git diff --name-only HEAD~1...HEAD   # 直近のコミットの変更ファイル
git log --oneline -10                # 直近のコミット履歴
git branch --show-current            # 現在のブランチ
gh pr view --json state 2>/dev/null  # 既存 PR の有無
```

確認事項:
- **ブランチ**: main/master でないこと（main 上なら警告して中断）
- **リモート追跡**: リモートにプッシュ済みか
- **既存 PR**: すでに PR が存在するか（存在する場合は更新フローへ）
- **変更内容**: コミット履歴と diff から PR の内容を把握

---

## Step 2: PR 作成

### 2a. PR 情報の整理

$ARGUMENTS とコミット履歴・diff の内容から以下を決定する:

- **タイトル**: 70 文字以内。変更の本質を端的に表現
- **サマリー**: 変更内容を 1〜3 つの箇条書きで要約
- **テストプラン**: テスト方法をチェックリスト形式で記載

### 2b. ユーザー確認

AskUserQuestion で PR の内容を確認する:

- PR タイトルとサマリーを表示
- ベースブランチの確認（デフォルト: main）
- draft にするか確認
- **そのまま作成** / **修正して作成** / **キャンセル** を選択

### 2c. PR 作成実行

```bash
# リモートにプッシュ（未プッシュの場合）
git push -u origin <current-branch>

# PR 作成
gh pr create --title "<タイトル>" --body "$(cat <<'EOF'
## Summary
- <変更内容1>
- <変更内容2>

## Test plan
- [ ] <テスト項目1>
- [ ] <テスト項目2>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" [--draft]
```

PR URL を記録し、ユーザーに報告する。

---

## Step 3: レビュー実行

PR 作成後、`/codex:review` Skill ツールで実行する。

レビュー完了後、結果を以下の形式で整理する:

```markdown
# レビュー結果サマリー

## 🔴 Critical（修正必須）: X 件
- [エージェント名] 指摘内容 (file:line)

## 🟡 Important（修正推奨）: X 件
- [エージェント名] 指摘内容 (file:line)

## 🔵 Suggestion（検討）: X 件
- [エージェント名] 指摘内容 (file:line)

## ✅ Strengths
- 良い点
```

---

## Step 4: 指摘の精査

レビュー結果をユーザーに提示し、AskUserQuestion で各指摘への対応方針を確認する。

提示フォーマット:

```
以下のレビュー指摘がありました。対応方針を教えてください。

🔴 Critical（修正必須）:
  1. [指摘内容] → 修正する / スキップする理由を記載
  2. ...

🟡 Important（修正推奨）:
  3. [指摘内容] → 修正する / スキップ
  4. ...

🔵 Suggestion（検討）:
  5. [指摘内容] → 修正する / スキップ
  6. ...

対応方針を番号で指定してください。
例: 「1,2,3 を修正、4 はスキップ（理由: 既存仕様）、5,6 も修正」
または「全て修正」「Critical のみ修正」など
```

---

## Step 5: 修正実施

ユーザーが承認した指摘に対して修正を実施する。

### 修正の進め方

1. Critical → Important → Suggestion の優先順で修正
2. 各修正は以下の手順:
   - 対象ファイルを Read で確認
   - Edit で修正を適用
   - 修正内容を簡潔に報告
3. 全修正完了後、変更をコミット:

```bash
git add <修正したファイル>
git commit -m "$(cat <<'EOF'
fix: address PR review feedback

- <修正内容1>
- <修正内容2>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
git push
```

---

## Step 6: 再レビュー（修正があった場合）

修正をプッシュした後、AskUserQuestion で再レビューの要否を確認する。

- **再レビューする** → Step 3 に戻り、修正箇所を中心に再レビュー
- **スキップして完了** → Step 7 へ

再レビューでは、前回の Critical/Important 指摘が解消されているかを重点的に確認する。

---

## Step 7: 完了報告

```markdown
# PR 完了レポート

- **PR URL**: <URL>
- **ステータス**: レビュー済み・修正完了
- **レビューラウンド**: X 回
- **修正した指摘**: X 件
- **スキップした指摘**: X 件（理由付き）

## 次のアクション
- レビュワーにレビュー依頼を送る
- CI の結果を確認する
```

---

## 既存 PR がある場合のフロー

Step 1 で既存 PR が検出された場合:

1. Step 2 をスキップ
2. 既存 PR の情報を `gh pr view` で取得
3. Step 3 からレビューフローを開始
4. 修正後は既存 PR にプッシュ

---

## 注意事項

- main/master ブランチ上では実行しない。警告して中断する
- force push は行わない
- レビュー指摘の修正は必ずユーザーの承認を得てから実施する
- 修正コミットは新規コミットとして作成する（amend しない）
- 機密情報（.env 等）が含まれていないか確認する
