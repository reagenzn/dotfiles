# gh-attach

GitHubのPR/Issueに画像をCLIからアップロードするgh拡張機能。

## インストール

```bash
gh extension install atani/gh-attach
```

## 使い方

```bash
# 基本（--release推奨: ブラウザ不要、gh認証のみ）
gh attach --issue <PR番号> --image ./screenshot.png --release

# コメント本文に画像を埋め込む
gh attach --issue <PR番号> --image ./screenshot.png --body "結果: <!-- gh-attach:IMAGE -->" --release

# 複数画像
gh attach --issue <PR番号> --image ./img1.png --image ./img2.png --release
```

## モード

- **releaseモード** (`--release`): GitHub Releases APIを使用。ブラウザ不要でgh認証のみ。リポジトリにリリースタグが作成される
- **browserモード** (デフォルト): playwright-cli必要
- **directモード** (自動検出): user-attachments URLを生成

## オプション

- `--repo <owner/repo>`: 対象リポジトリ指定（省略時は現在のリポジトリ）
- `--width <px>`: 画像幅（デフォルト800px）
- `--body <text>`: コメント本文
- `--body-file <path>`: 本文をファイルから読み込み