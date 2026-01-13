---
name: Shell Rule
description: Defines rules for shell operations and command execution.
---

# Shell Rule

このスキルは、シェル操作とコマンド実行のルールを定義します。

## 使用シェル

**zsh**を使用しています。

## コマンド実行のガイドライン

### 長いコマンドの扱い

300文字を超えるコマンド（例: `gh pr create`など）は、実行時に表示に時間がかかるため、ターミナルでの直接実行が難しい場合があります。

このような場合は、以下の方法を検討してください:

- コマンドを複数のステップに分割する
- スクリプトファイルを作成して実行する
- エディタで引数を事前に準備してから実行する

### 一時ファイルの作成

一時ファイルを作成する場合は、**現在開いているフォルダの直下**に作成してください。

```bash
# 良い例: カレントディレクトリに一時ファイルを作成
./tmp_script.sh
./temp_data.json

# 避ける: システムの/tmpや他のディレクトリ
/tmp/script.sh
~/tmp/data.json
```

## ベストプラクティス

### スクリプト作成時

- シバン（shebang）に `#!/bin/zsh` または `#!/bin/bash` を明記
- エラーハンドリングを適切に実装（`set -e` など）
- 変数は `${変数名}` の形式で参照
- パスは可能な限り絶対パスまたは `realpath` を使用

### コマンド実行時

- 長いコマンドはバックスラッシュ `\` で改行
- パイプライン `|` を活用してコマンドを分割
- エイリアスやシェル関数を活用

## 例

### 例1: 一時スクリプトファイルの作成と実行

```bash
# カレントディレクトリに一時スクリプトを作成
cat > ./tmp_deploy.sh << 'EOF'
#!/bin/zsh
set -e

echo "Starting deployment..."
git push origin main
echo "Deployment completed"
EOF

# 実行権限を付与して実行
chmod +x ./tmp_deploy.sh
./tmp_deploy.sh

# 完了後に削除
rm ./tmp_deploy.sh
```

### 例2: 長いコマンドを分割

```bash
# 悪い例: 300文字を超える長いコマンド
gh pr create --title "feat: add new feature" --body "This is a very long description..."

# 良い例: 引数をファイルに保存してから実行
echo "This is a very long description that includes multiple points..." > ./tmp_pr_body.txt
gh pr create --title "feat: add new feature" --body-file ./tmp_pr_body.txt
rm ./tmp_pr_body.txt
```

### 例3: zshの機能を活用

```bash
# 配列の使用
files=(file1.txt file2.txt file3.txt)
for file in $files; do
  echo "Processing $file"
done

# グロブパターン
ls **/*.js  # 再帰的にすべての.jsファイルを表示
```
