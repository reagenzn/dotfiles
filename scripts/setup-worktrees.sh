#!/bin/bash

set -e

# === Worktree セットアップスクリプト ===
# 指定したローカルgitリポジトリに対して5つのworktree (wt1〜wt5) を作成する
#
# 使い方:
#   setup-worktrees <リポジトリパス> [ベースブランチ]
#
# 例:
#   setup-worktrees ~/aix_workspace/aix-aq-ai-datalake-builder-analysis
#   setup-worktrees ~/aix_workspace/aix-aq-ai-datalake-builder-analysis develop

REPO_PATH="$1"
BASE_BRANCH="${2:-main}"
WORKTREE_COUNT=5

if [ -z "$REPO_PATH" ]; then
  echo "Usage: setup-worktrees <リポジトリパス> [ベースブランチ(default: main)]"
  echo ""
  echo "例:"
  echo "  setup-worktrees ~/projects/my-app"
  echo "  setup-worktrees ~/projects/my-app develop"
  exit 1
fi

# 絶対パスに変換
REPO_PATH=$(cd "$REPO_PATH" 2>/dev/null && pwd)
if [ ! -d "$REPO_PATH/.git" ]; then
  echo "Error: $REPO_PATH はgitリポジトリではありません"
  exit 1
fi

REPO_NAME=$(basename "$REPO_PATH")
REPO_PARENT=$(dirname "$REPO_PATH")
WORKTREES_DIR="$REPO_PARENT/${REPO_NAME}-worktrees"

echo "=== Worktree セットアップ ==="
echo "リポジトリ: $REPO_PATH"
echo "ベースブランチ: $BASE_BRANCH"
echo "Worktree格納先: $WORKTREES_DIR"
echo ""

# ベースブランチを最新化
echo ">>> ベースブランチ ($BASE_BRANCH) を最新化..."
cd "$REPO_PATH"
git fetch origin "$BASE_BRANCH"
git checkout "$BASE_BRANCH" 2>/dev/null || true
git pull origin "$BASE_BRANCH"

# worktrees ディレクトリ作成
mkdir -p "$WORKTREES_DIR"

# コピー対象の env ファイルを収集
ENV_FILES=()
for envfile in .env .env.development .env.local; do
  if [ -f "$REPO_PATH/$envfile" ]; then
    ENV_FILES+=("$envfile")
  fi
done

# サブディレクトリ内の env ファイルも検索（1階層のみ）
for dir in "$REPO_PATH"/*/; do
  [ -d "$dir" ] || continue
  dirname=$(basename "$dir")
  # node_modules, .git 等は除外
  [[ "$dirname" == node_modules || "$dirname" == .git || "$dirname" == dist || "$dirname" == .next ]] && continue
  for envfile in .env .env.development .env.local; do
    if [ -f "$dir/$envfile" ]; then
      ENV_FILES+=("$dirname/$envfile")
    fi
  done
done

if [ ${#ENV_FILES[@]} -gt 0 ]; then
  echo ">>> ハードリンク対象の環境変数ファイル:"
  for f in "${ENV_FILES[@]}"; do
    echo "    - $f"
  done
  echo ""
fi

# wt1〜wt5 を作成
for i in $(seq 1 $WORKTREE_COUNT); do
  WT_NAME="wt${i}"
  WT_PATH="$WORKTREES_DIR/$WT_NAME"
  WT_BRANCH="worktree/$WT_NAME"

  echo ">>> [$WT_NAME] 作成中..."

  if [ -d "$WT_PATH" ]; then
    echo "    スキップ: $WT_PATH は既に存在します"
    continue
  fi

  # worktree 用のブランチを作成（既存なら再利用）
  cd "$REPO_PATH"
  if git show-ref --verify --quiet "refs/heads/$WT_BRANCH"; then
    echo "    ブランチ $WT_BRANCH は既に存在します（再利用）"
  else
    git branch "$WT_BRANCH" "origin/$BASE_BRANCH"
  fi

  # worktree を追加
  git worktree add "$WT_PATH" "$WT_BRANCH"

  # env ファイルをハードリンク
  for envfile in "${ENV_FILES[@]}"; do
    src="$REPO_PATH/$envfile"
    dest="$WT_PATH/$envfile"
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir"
    ln "$src" "$dest"
    echo "    リンク: $envfile"
  done

  # npm ci を実行（package.json があるディレクトリで）
  if [ -f "$WT_PATH/package.json" ]; then
    echo "    npm ci 実行中 (root)..."
    (cd "$WT_PATH" && npm ci --loglevel=warn)
  fi
  # サブディレクトリの package.json もチェック（monorepo対応）
  for pkg in "$WT_PATH"/*/package.json; do
    [ -f "$pkg" ] || continue
    pkg_dir=$(dirname "$pkg")
    pkg_name=$(basename "$pkg_dir")
    # root の node_modules は除外
    [[ "$pkg_name" == node_modules ]] && continue
    echo "    npm ci 実行中 ($pkg_name)..."
    (cd "$pkg_dir" && npm ci --loglevel=warn)
  done

  echo "    完了: $WT_PATH"
  echo ""
done

echo "=== セットアップ完了 ==="
echo ""
echo "Worktree 一覧:"
cd "$REPO_PATH"
git worktree list
echo ""
echo "使い方:"
echo "  cd $WORKTREES_DIR/wt1"
echo "  git checkout -b feat/#123-my-feature origin/$BASE_BRANCH"
