#!/bin/bash

set -e

# worktree-port-setup.sh
# worktreeごとにランダムポートを割り当て、
# COMPOSE_PROJECT_NAME を設定してDockerコンテナ名の衝突を防止し、
# サブディレクトリの env ファイル内の localhost URL 参照も書き換える。
#
# gwt hook環境変数:
#   $WORKTREE_PATH - worktreeのパス
#   $BRANCH        - ブランチ名
#   $REPO_ROOT     - リポジトリルートのパス

WORKTREE="${WORKTREE_PATH:-${1:-.}}"
BRANCH_NAME="${BRANCH:-$(cd "$WORKTREE" && git branch --show-current 2>/dev/null || echo 'unknown')}"

ENV_FILE="$WORKTREE/.env"
ENV_EXAMPLE="$WORKTREE/.env.example"

# .envが無ければ.env.exampleからコピー
if [ ! -f "$ENV_FILE" ] && [ -f "$ENV_EXAMPLE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "[worktree-port-setup] .env ファイルが見つかりません。スキップします。"
  exit 0
fi

sanitize_branch() {
  echo "$1" | sed 's|/|-|g; s|[^a-zA-Z0-9-]||g' | tr '[:upper:]' '[:lower:]'
}

generate_free_port() {
  local port
  local max_attempts=20
  local attempt=0
  while [ $attempt -lt $max_attempts ]; do
    if command -v shuf > /dev/null 2>&1; then
      port=$(shuf -i 10000-60000 -n 1)
    else
      port=$(( (RANDOM % 50000) + 10000 ))
    fi
    if ! lsof -iTCP:"$port" -sTCP:LISTEN > /dev/null 2>&1; then
      echo "$port"
      return 0
    fi
    attempt=$((attempt + 1))
  done
  echo "$port"
}

REPO_NAME=$(basename "${REPO_ROOT:-$(cd "$WORKTREE" && git rev-parse --show-toplevel 2>/dev/null || basename "$PWD")}")
SANITIZED_BRANCH=$(sanitize_branch "$BRANCH_NAME")

echo ""
echo "=== worktree-port-setup ==="
echo "Branch: $BRANCH_NAME"
echo "Worktree: $WORKTREE"
echo ""

# --- Step 1: COMPOSE_PROJECT_NAME ---
COMPOSE_PROJECT="${REPO_NAME}-${SANITIZED_BRANCH}"
if grep -q "^COMPOSE_PROJECT_NAME=" "$ENV_FILE" 2>/dev/null; then
  sed -i '' "s|^COMPOSE_PROJECT_NAME=.*|COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT}|" "$ENV_FILE"
else
  echo "COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT}" >> "$ENV_FILE"
fi
echo "COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT}"

# --- Step 2: ポート変数をランダム化し、旧→新のマッピングを保存 ---
PORT_LINES=$(grep -E '^[A-Z_]*PORT=' "$ENV_FILE" || true)

# 連想配列: old_port -> new_port
declare -a OLD_PORTS
declare -a NEW_PORTS
idx=0

if [ -z "$PORT_LINES" ]; then
  echo ""
  echo "[info] ポート変数が見つかりませんでした。"
else
  echo ""
  while IFS= read -r line; do
    var=$(echo "$line" | cut -d= -f1)
    old_port=$(echo "$line" | cut -d= -f2)
    new_port=$(generate_free_port)
    sed -i '' "s|^${var}=.*|${var}=${new_port}|" "$ENV_FILE"
    OLD_PORTS[$idx]="$old_port"
    NEW_PORTS[$idx]="$new_port"
    echo "${var}=${new_port}  (was: ${old_port})"
    idx=$((idx + 1))
  done <<< "$PORT_LINES"
fi

# --- Step 3: サブディレクトリ env ファイルの localhost URL を書き換え ---
if [ $idx -gt 0 ]; then
  echo ""
  echo "--- サブディレクトリ env ファイルの URL 書き換え ---"

  ENV_FILES=$(find "$WORKTREE" -maxdepth 3 \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/cdk.out/*" \
    -not -path "$ENV_FILE" \
    \( -name ".env*" \) \
    -type f 2>/dev/null || true)

  for env_file in $ENV_FILES; do
    changed=false
    i=0
    while [ $i -lt $idx ]; do
      old_port="${OLD_PORTS[$i]}"
      new_port="${NEW_PORTS[$i]}"
      if grep -q "localhost:${old_port}" "$env_file" 2>/dev/null; then
        sed -i '' "s|localhost:${old_port}|localhost:${new_port}|g" "$env_file"
        changed=true
      fi
      i=$((i + 1))
    done
    if [ "$changed" = true ]; then
      rel_path="${env_file#$WORKTREE/}"
      echo "  updated: $rel_path"
    fi
  done
fi

echo ""
echo "=== 完了 ==="
