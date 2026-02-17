#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../.config/git/gtr-templates"

# テンプレートモード
if [ "$1" = "--template" ] && [ -n "$2" ]; then
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: gitリポジトリ内で実行してください"
    exit 1
  fi
  REPO_ROOT=$(git rev-parse --show-toplevel)
  CONFIG_FILE="$REPO_ROOT/.gtrconfig"
  TEMPLATE_FILE="$TEMPLATE_DIR/$2.gtrconfig"
  if [ -f "$TEMPLATE_FILE" ]; then
    cp "$TEMPLATE_FILE" "$CONFIG_FILE"
    echo "テンプレート '$2' を適用しました: $CONFIG_FILE"
    echo ""
    cat "$CONFIG_FILE"
    exit 0
  else
    echo "Error: テンプレート '$2' が見つかりません。利用可能なテンプレート:"
    ls "$TEMPLATE_DIR" 2>/dev/null | sed 's/\.gtrconfig$//'
    exit 1
  fi
fi

echo "=== gwt (git-gtr) リポジトリ設定ウィザード ==="
echo ""

# gitリポジトリチェック
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: gitリポジトリ内で実行してください"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
CONFIG_FILE="$REPO_ROOT/.gtrconfig"

if [ -f "$CONFIG_FILE" ]; then
  echo "Warning: .gtrconfig が既に存在します: $CONFIG_FILE"
  read -p "上書きしますか？ (y/N): " overwrite
  if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
    echo "中止しました。"
    exit 0
  fi
fi

# テンプレート一覧表示
echo "利用可能なテンプレート:"
if [ -d "$TEMPLATE_DIR" ]; then
  templates=$(ls "$TEMPLATE_DIR" 2>/dev/null | sed 's/\.gtrconfig$//')
  i=1
  for t in $templates; do
    echo "   $i) $t"
    i=$((i + 1))
  done
fi
echo "   0) カスタム設定"
echo ""
read -p "テンプレートを選択するか、0でカスタム設定 [0]: " template_choice

if [ -n "$template_choice" ] && [ "$template_choice" != "0" ]; then
  selected=$(ls "$TEMPLATE_DIR" 2>/dev/null | sed 's/\.gtrconfig$//' | sed -n "${template_choice}p")
  if [ -n "$selected" ]; then
    cp "$TEMPLATE_DIR/${selected}.gtrconfig" "$CONFIG_FILE"
    echo ""
    echo "テンプレート '$selected' を適用しました。"
    echo ""
    cat "$CONFIG_FILE"
    exit 0
  fi
fi

# カスタム設定
echo ""
echo "1. エディタを選択してください:"
echo "   1) vs-code (default)"
echo "   2) cursor"
echo "   3) zed"
read -p "   選択 [1]: " editor_choice
case "$editor_choice" in
  2) EDITOR_DEFAULT="cursor" ;;
  3) EDITOR_DEFAULT="zed" ;;
  *) EDITOR_DEFAULT="vs-code" ;;
esac

echo ""
echo "2. AIツールを選択してください:"
echo "   1) claude (default)"
echo "   2) aider"
read -p "   選択 [1]: " ai_choice
case "$ai_choice" in
  2) AI_DEFAULT="aider" ;;
  *) AI_DEFAULT="claude" ;;
esac

echo ""
echo "3. worktreeにコピーするファイルパターン (カンマ区切り, 空欄でスキップ):"
echo "   例: **/.env.example, **/.env.local"
read -p "   パターン: " copy_include

echo ""
echo "4. コピーから除外するファイルパターン (カンマ区切り, 空欄でスキップ):"
read -p "   パターン: " copy_exclude

echo ""
echo "5. worktreeにコピーするディレクトリ (カンマ区切り, 空欄でスキップ):"
echo "   例: node_modules, .venv"
read -p "   ディレクトリ: " copy_dirs

echo ""
echo "6. worktree作成後に実行するコマンド (空欄でスキップ):"
echo "   例: npm install, pnpm install, pip install -r requirements.txt"
read -p "   コマンド: " post_create

echo ""
echo "7. worktree削除前に実行するコマンド (空欄でスキップ):"
read -p "   コマンド: " pre_remove

# .gtrconfig 生成
cat > "$CONFIG_FILE" << EOF
[gtr "editor"]
  default = $EDITOR_DEFAULT

[gtr "ai"]
  default = $AI_DEFAULT
EOF

# copyセクション
if [ -n "$copy_include" ] || [ -n "$copy_exclude" ] || [ -n "$copy_dirs" ]; then
  echo "" >> "$CONFIG_FILE"
  echo '[gtr "copy"]' >> "$CONFIG_FILE"
  if [ -n "$copy_include" ]; then
    IFS=',' read -ra PATTERNS <<< "$copy_include"
    for pattern in "${PATTERNS[@]}"; do
      pattern=$(echo "$pattern" | xargs)
      echo "  include = $pattern" >> "$CONFIG_FILE"
    done
  fi
  if [ -n "$copy_exclude" ]; then
    IFS=',' read -ra PATTERNS <<< "$copy_exclude"
    for pattern in "${PATTERNS[@]}"; do
      pattern=$(echo "$pattern" | xargs)
      echo "  exclude = $pattern" >> "$CONFIG_FILE"
    done
  fi
  if [ -n "$copy_dirs" ]; then
    IFS=',' read -ra DIRS <<< "$copy_dirs"
    for dir in "${DIRS[@]}"; do
      dir=$(echo "$dir" | xargs)
      echo "  includeDirs = $dir" >> "$CONFIG_FILE"
    done
  fi
fi

# hookセクション
if [ -n "$post_create" ] || [ -n "$pre_remove" ]; then
  echo "" >> "$CONFIG_FILE"
  echo '[gtr "hook"]' >> "$CONFIG_FILE"
  if [ -n "$post_create" ]; then
    echo "  postCreate = $post_create" >> "$CONFIG_FILE"
  fi
  if [ -n "$pre_remove" ]; then
    echo "  preRemove = $pre_remove" >> "$CONFIG_FILE"
  fi
fi

echo ""
echo "=== .gtrconfig を作成しました: $CONFIG_FILE ==="
echo ""
cat "$CONFIG_FILE"
echo ""
echo "Tip: .gtrconfig を .gitignore に追加するか、チームで共有するかを検討してください。"
