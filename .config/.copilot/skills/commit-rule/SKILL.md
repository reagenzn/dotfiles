---
name: Commit Rule
description: Defines rules for creating commit messages.
---

# Commit Rule

このスキルは、コミットメッセージの作成ルールを定義します。

## Conventional Commits

Conventional Commitsの形式を採用します。

### フォーマット

```
<type>(<scope>): <subject>

<body>
```

### Type

- **feat**: 新機能の追加
- **fix**: バグ修正
- **docs**: ドキュメントのみの変更
- **style**: コードの意味に影響を与えない変更（空白、フォーマット、セミコロンの欠落など）
- **refactor**: バグ修正や機能追加ではないコードの変更
- **perf**: パフォーマンスを向上させるコード変更
- **test**: 不足しているテストの追加や既存のテストの修正
- **chore**: ビルドプロセスやドキュメント生成などの補助ツールやライブラリの変更

### Scope

変更の範囲を示す（オプション）。例: `config`, `scripts`, `fish`, `zsh`, `python` など

### Subject

- 変更の簡潔な説明
- 命令形、現在形で記述（"add" であって "added" や "adds" ではない）
- 最初の文字は小文字
- 末尾にピリオドを付けない

### Body

- 変更の詳細な説明
- **必須**: 2〜4個の主な修正点をリスト形式で記載
- なぜ変更が必要だったかを説明

## 例

### 例1: 新機能の追加

```
feat(fish): add new alias for git commands

- Add `gst` alias for `git status`
- Add `gco` alias for `git checkout`
- Add `gp` alias for `git push`
```

### 例2: バグ修正

```
fix(setup): resolve installation script error

- Fix path resolution issue in setup-python.sh
- Add error handling for missing dependencies
```

### 例3: ドキュメント更新

```
docs(readme): update installation instructions

- Add prerequisites section
- Update macOS setup steps
- Add troubleshooting guide
```

### 例4: リファクタリング

```
refactor(scripts): improve code organization

- Split setup script into smaller modules
- Extract common functions to shared utilities
- Improve error messages for better debugging
- Update variable naming for consistency
```
