---
name: session-summary
description: |
  現在のセッション（会話）のサマリーを生成し、.config/.claude/skills/ 配下にMarkdownファイルとして出力するスキル。
  ユーザーが「セッションサマリー」「会話まとめ」「サマリー出力」「session summary」「今日の作業まとめ」
  「このセッションの記録」「作業ログ」などと言ったときに使用する。
  セッション中に行った作業内容、変更したファイル、意思決定、残課題などを構造化して記録する。
---

# Session Summary Skill

現在のセッション（会話）の内容をサマリーとしてMarkdownファイルに出力する。

## 出力先

`.config/.claude/skills/session-summary/summaries/` ディレクトリに以下の命名規則で出力する：

```
summaries/YYYY-MM-DD_HH-MM_{topic}.md
```

- `YYYY-MM-DD_HH-MM` は現在の日時
- `{topic}` はセッションの主要トピックを英語のkebab-caseで簡潔に表現（例: `add-auth-feature`, `fix-api-bug`）

## 出力フォーマット

以下のテンプレートに従って出力する：

```markdown
# Session Summary: {タイトル}

- **Date**: YYYY-MM-DD HH:MM
- **Duration**: 概算のセッション時間（わかる場合）
- **Project**: プロジェクト名（作業ディレクトリから推定）

## Overview
このセッションで何を達成したかの1-3行の概要。

## Tasks Completed
- [ ] or [x] で完了/未完了を示すタスクリスト
- 各タスクは具体的に記述

## Key Changes
変更したファイルとその内容の要約。

| File | Change Type | Description |
|------|-------------|-------------|
| path/to/file | added/modified/deleted | 変更内容の簡潔な説明 |

## Decisions Made
セッション中に行った重要な意思決定とその理由。
- **Decision**: 何を決めたか → **Reason**: なぜそう決めたか

## Issues & Blockers
遭遇した問題や未解決の課題。
- 問題の説明と現在のステータス

## Next Steps
次のセッションで取り組むべきタスクや残作業。
- 具体的なアクションアイテム

## Notes
その他の補足情報やメモ。
```

## 手順

1. **ディレクトリ確認**: `summaries/` ディレクトリが存在しない場合は作成する
2. **セッション分析**: 会話履歴全体を振り返り、以下を特定する：
   - 実行したタスクとその結果
   - 変更したファイル（git diff や会話から特定）
   - 重要な意思決定
   - 遭遇した問題
3. **git状態の確認**: `git status` と `git diff --stat` を実行して、実際の変更内容を把握する
4. **サマリー生成**: テンプレートに従ってMarkdownを生成する
5. **ファイル出力**: 命名規則に従ってファイルを書き出す
6. **ユーザーに報告**: 出力したファイルパスと概要を報告する

## 注意事項

- セッション中の具体的なコード内容やシークレット情報は含めない
- 簡潔かつ実用的な記述を心がける
- 日本語で出力する（タイトルのtopic部分のみ英語）
- 過去のサマリーは上書きせず、常に新規ファイルとして作成する
