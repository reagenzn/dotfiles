---
name: agent-browser-debug
description: agent-browser (CLI)を使用したWebアプリケーションのデバッグ手法。ブラウザ自動化、スクリーンショット取得、DOMの検査、ログ収集などのデバッグタスクに使用します。
---

# Agent Browser Debug

このスキルは、agent-browser CLIツールを使用したWebアプリケーションのデバッグ手法を提供します。

## 概要

agent-browserは、高速なブラウザ自動化CLIツールで、AIエージェント向けに設計されています。以下のようなデバッグタスクに使用できます:

- ページの表示確認とスクリーンショット取得
- アクセシビリティツリーとDOM要素の検査（snapshot）
- コンソールログ・エラーの収集
- ネットワークリクエストの監視
- JavaScriptの実行とテスト
- レスポンシブデザインの確認
- 要素の操作とインタラクションテスト

## 基本的な使用方法

### ページを開く

```bash
agent-browser open https://example.com
```

### スクリーンショットを取得

```bash
# 通常のスクリーンショット
agent-browser screenshot

# フルページスクリーンショット
agent-browser screenshot --full

# ファイルに保存
agent-browser screenshot output.png
```

### アクセシビリティツリーを確認（AI向けスナップショット）

```bash
# 全体のスナップショット
agent-browser snapshot

# インタラクティブ要素のみ
agent-browser snapshot -i

# コンパクト表示（空の構造要素を除去）
agent-browser snapshot -c

# 深さを制限
agent-browser snapshot -d 3

# 特定のセレクタにスコープ
agent-browser snapshot -s ".main-content"
```

### コンソールとエラーを確認

```bash
# コンソールログを表示
agent-browser console

# エラーを表示
agent-browser errors

# ログをクリア
agent-browser console --clear
agent-browser errors --clear
```

## デバッグワークフロー

### 1. 視覚的な問題のデバッグ

レイアウト崩れやスタイルの問題を確認する場合:

```bash
# ページを開く
agent-browser open http://localhost:3000

# 通常の表示を確認
agent-browser screenshot

# モバイルビューを確認
agent-browser set viewport 375 667
agent-browser screenshot mobile.png

# タブレットビューを確認
agent-browser set device "iPad Pro"
agent-browser screenshot

# 特定の要素をハイライト
agent-browser highlight "header nav"
agent-browser screenshot
```

### 2. DOM構造とアクセシビリティの確認

```bash
# ページ全体のスナップショット
agent-browser snapshot

# インタラクティブ要素のみ（ボタン、リンク等）
agent-browser snapshot -i

# 特定のセクションのみ確認
agent-browser snapshot -s "#main-content"

# 要素の情報を取得
agent-browser get text "h1"
agent-browser get html ".error-message"
agent-browser get attr "data-testid" "button"
```

### 3. JavaScript エラーのデバッグ

```bash
# コンソールログとエラーを収集
agent-browser console
agent-browser errors

# ページ操作後のエラーを確認
agent-browser click "button.login"
agent-browser wait 1000
agent-browser errors

# JavaScriptを実行
agent-browser eval "document.querySelectorAll('.error').length"
agent-browser eval "console.log(window.location)"
```

### 4. ネットワーク問題のデバッグ

```bash
# ネットワークリクエストを監視
agent-browser network requests

# 特定のパターンをフィルタ
agent-browser network requests --filter "/api/"

# リクエストをモック
agent-browser network route "https://api.example.com/data" --body '{"status":"ok"}'

# ネットワークリクエストをクリア
agent-browser network requests --clear
```

### 5. インタラクション動作のデバッグ

```bash
# フォーム入力のテスト
agent-browser fill "input[name='email']" "test@example.com"
agent-browser fill "input[name='password']" "password123"
agent-browser click "button[type='submit']"
agent-browser wait 2000
agent-browser screenshot after-login.png

# チェックボックス・ラジオボタン
agent-browser check "input[type='checkbox']"
agent-browser is checked "input[type='checkbox']"

# ドロップダウン選択
agent-browser select "select[name='country']" "Japan"

# ホバー効果の確認
agent-browser hover ".menu-item"
agent-browser screenshot hover-state.png

# キー操作
agent-browser press "Tab"
agent-browser press "Enter"
agent-browser press "Control+a"
```

## ベストプラクティス

### セッション管理

複数のブラウザコンテキストを分離して使用:

```bash
# セッションを指定して実行
agent-browser --session dev open http://localhost:3000
agent-browser --session prod open https://example.com

# 現在のセッション確認
agent-browser session

# アクティブなセッション一覧
agent-browser session list
```

### 要素の参照方法

snapshotで取得した@refを使用すると効率的:

```bash
# snapshotで要素を確認
agent-browser snapshot -i

# 出力された@e2などの参照を使って操作
agent-browser click @e2
agent-browser fill @e3 "test@example.com"
agent-browser get text @e1
```

### 要素の検索方法

```bash
# ロールで検索してクリック
agent-browser find role button click --name Submit

# テキストで検索
agent-browser find text "Sign up" click

# ラベルで検索
agent-browser find label "Email" type "test@example.com"

# プレースホルダーで検索
agent-browser find placeholder "Enter your name" type "John"

# testidで検索
agent-browser find testid "login-button" click

# 順序で選択
agent-browser find role button first click
agent-browser find role link last click
agent-browser find role item nth 3 click
```

### デバッグ効率を上げるコツ

1. **snapshotを活用**: インタラクティブ要素の構造を把握してから操作
2. **セッション分離**: 開発環境と本番環境を別セッションで管理
3. **待機を適切に**: 動的コンテンツには`wait`コマンドを使用
4. **スクリーンショットで確認**: 操作後の状態を必ず視覚的に確認
5. **JSON出力**: スクリプトで使用する場合は`--json`オプションを使用

### 注意事項

- デフォルトはヘッドレスモード。ブラウザを表示したい場合は`--headed`オプションを使用
- 認証が必要なページの場合、`--headers`でHTTPヘッダーを設定可能
- セレクタは CSS セレクタを使用（例: `.class`, `#id`, `[attribute]`）

## 高度な使用例

### タブ管理

```bash
# 新しいタブを開く
agent-browser tab new

# タブ一覧を表示
agent-browser tab list

# 特定のタブに切り替え
agent-browser tab 2

# タブを閉じる
agent-browser tab close
```

### マウス操作

```bash
# マウスを移動
agent-browser mouse move 100 200

# マウスボタンを押す/離す
agent-browser mouse down
agent-browser mouse up

# ホイールスクロール
agent-browser mouse wheel 100
```

### スクロール操作

```bash
# 方向を指定してスクロール
agent-browser scroll down 500
agent-browser scroll up 300

# 要素をビューにスクロール
agent-browser scrollintoview ".footer"
```

### ストレージとCookie管理

```bash
# Cookieの取得・設定・クリア
agent-browser cookies get
agent-browser cookies set
agent-browser cookies clear

# ローカル/セッションストレージ
agent-browser storage local
agent-browser storage session
```

### トレース記録（パフォーマンス分析）

```bash
# トレース開始
agent-browser trace start

# 操作を実行...
agent-browser click "button"

# トレース停止（ファイルに保存）
agent-browser trace stop trace.zip
```

### オフラインモードとネットワーク制御

```bash
# オフラインモードをオン
agent-browser set offline on

# ページをリロード（オフライン状態をテスト）
agent-browser reload

# オフラインモードをオフ
agent-browser set offline off

# 位置情報を設定
agent-browser set geo 35.6762 139.6503

# メディアクエリを設定（ダークモード、reduced-motion）
agent-browser set media dark reduced-motion
```

### 複数コマンドの連続実行例

```bash
# ログインフローの完全テスト
agent-browser open http://localhost:3000/login
agent-browser snapshot -i
agent-browser fill "input[name='email']" "test@example.com"
agent-browser fill "input[name='password']" "password123"
agent-browser screenshot before-submit.png
agent-browser click "button[type='submit']"
agent-browser wait 2000
agent-browser get url
agent-browser screenshot after-login.png
agent-browser errors
```

## トラブルシューティング

### agent-browserが見つからない場合

```bash
# インストール確認
which agent-browser

# npmでインストール
npm install -g agent-browser

# ブラウザバイナリのインストール
agent-browser install

# システム依存関係も含めてインストール（Linux）
agent-browser install --with-deps
```

### 要素が見つからない場合

```bash
# まずsnapshotで構造を確認
agent-browser snapshot -i

# 要素の存在確認
agent-browser is visible "button.login"
agent-browser is enabled "input[name='email']"

# 要素が表示されるまで待機
agent-browser wait "button.submit"
agent-browser wait 3000  # ミリ秒で待機
```

### 要素が操作できない場合

```bash
# 要素をビューにスクロール
agent-browser scrollintoview "button.submit"

# フォーカスしてから操作
agent-browser focus "input[name='email']"
agent-browser type "input[name='email']" "test@example.com"

# ハイライトして確認
agent-browser highlight "button.submit"
agent-browser screenshot
```

### デバッグモード

詳細なログを確認:

```bash
agent-browser --debug open https://example.com
```

### ブラウザウィンドウを表示

ヘッドレスモードでない実行:

```bash
agent-browser --headed open https://example.com
```

### カスタムブラウザ実行パスの指定

```bash
# 環境変数で指定
export AGENT_BROWSER_EXECUTABLE_PATH=/path/to/chrome

# またはオプションで指定
agent-browser --executable-path /path/to/chrome open https://example.com
```

## よくあるデバッグシナリオ

### レスポンシブデザインのテスト

```bash
# デスクトップ
agent-browser set viewport 1920 1080
agent-browser screenshot desktop.png

# タブレット
agent-browser set device "iPad Pro"
agent-browser screenshot tablet.png

# モバイル
agent-browser set device "iPhone 12"
agent-browser screenshot mobile.png
```

### フォームバリデーションのテスト

```bash
# 空フォーム送信
agent-browser click "button[type='submit']"
agent-browser snapshot -s ".error-message"
agent-browser screenshot validation-errors.png

# 正しい入力
agent-browser fill "input[name='email']" "valid@example.com"
agent-browser click "button[type='submit']"
agent-browser errors
```

### SPA（Single Page Application）のデバッグ

```bash
# ページ遷移を確認
agent-browser click "a[href='/dashboard']"
agent-browser wait 1000
agent-browser get url
agent-browser get title

# ネットワークリクエストを監視
agent-browser network requests --filter "/api/"

# 状態変化を確認
agent-browser snapshot -c
```
