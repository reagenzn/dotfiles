# setup

## macの場合

1. clone

2. brewのインストール

```bash
make setup-mac
```

3. fish,fisherのインストール

```bash
make install
```

4. ハードリンクを設定

```bash
make link
```

5. `.git-user`ファイルを作成してgitの設定

```bash
touch ~/.git-user
```

6. 手動でいくつかのアプリケーションをインストール

- obsidian
- alacritty
- vscode
- raycast


7. 設定のエクスポート・インポート

- chromeの拡張機能のエクスポート・インポートをする(同期でも可)
- raycast,vimiumは設定ファイルをエクスポートできるので行う