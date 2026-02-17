# Neovim 最小構成

元のdotfiles設定から抽出した、最小限のNeovim設定です。

## 特徴

- **プラグインマネージャー**: lazy.nvim
- **LSP対応**: Mason + nvim-lspconfig
- **GitHub Copilot対応**
- **シンタックスハイライト**: treesitter
- **補完**: nvim-cmp
- **元の設定のキーバインドを維持**

## インストール方法

### 1. このディレクトリを使用する場合

```bash
# 既存のneovim設定をバックアップ (オプション)
mv ~/.config/nvim ~/.config/nvim.backup

# シンボリックリンクを作成
ln -s /Users/natsuki.fukazawa/dotfiles/.config/nvim-minimal ~/.config/nvim
```

### 2. 他のマシンにコピーする場合

```bash
# init.luaを他のマシンにコピー
scp /Users/natsuki.fukazawa/dotfiles/.config/nvim-minimal/init.lua user@remote:~/.config/nvim/
```

## 初回起動

```bash
nvim
```

初回起動時、自動的に以下が実行されます：

1. lazy.nvimのインストール
2. プラグインのインストール
3. LSPサーバーのインストール (lua_ls, tsserver, pyright)

## LSPサーバーの追加

追加のLSPサーバーが必要な場合：

```lua
-- init.lua の ensure_installed に追加
ensure_installed = {
  "lua_ls",
  "tsserver",
  "pyright",
  "rust_analyzer",  -- 追加例
},
```

または、Neovim内で直接インストール：

```vim
:Mason
```

## 主要なキーバインド

### ノーマルモード

- `<Space>`: Leader キー
- `J/K`: 10行移動
- `H/L`: 行頭/行末
- `<C-s>`: 保存
- `U`: Redo
- `Y`: 行末までヤンク
- `jj/jk` (Insert): ESC

### LSP

- `[`: 定義へジャンプ
- `<Space>t`: ホバー
- `<Space>r`: リネーム
- `<Space>ca`: コードアクション
- `<Space>f`: フォーマット
- `]d`: 次の診断
- `[d`: 前の診断

### GitHub Copilot

- `<Tab>`: 補完を受け入れ
- `<C-j>`: 次の候補
- `<C-k>`: 前の候補
- `<C-\>`: 候補を却下

### ウィンドウ/タブ

- `<C-h>/<C-l>`: ウィンドウ移動
- `gh/gl`: タブ移動
- `gn`: 新規タブ
- `ss/sv`: 分割

### 補完 (Insert mode)

- `<C-Space>`: 補完を表示
- `<CR>`: 補完を確定
- `<C-n>/<C-p>`: 次/前の候補

## 含まれるプラグイン

| プラグイン      | 用途                   |
| --------------- | ---------------------- |
| lazy.nvim       | プラグインマネージャー |
| mason.nvim      | LSPサーバー管理        |
| nvim-lspconfig  | LSP設定                |
| nvim-cmp        | 補完エンジン           |
| copilot.vim     | GitHub Copilot         |
| nvim-treesitter | シンタックスハイライト |
| tokyonight.nvim | カラースキーム         |

## カスタマイズ

必要に応じて `init.lua` を編集してください：

- LSPサーバーの追加/削除
- キーマップの変更
- プラグインの追加
- カラースキームの変更

## トラブルシューティング

### LSPが動作しない

```vim
:checkhealth lsp
:Mason
```

### Copilotが動作しない

```vim
:Copilot setup
```

### プラグインを再インストール

```vim
:Lazy clean
:Lazy sync
```
