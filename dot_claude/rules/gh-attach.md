# GitHub issue/PR への画像添付

GitHub は user-attachments への**公式アップロード API を持たない**（`github.com/upload/policies/assets` は user_session cookie 必須・PAT 不可）。CLI トークンだけでは上げられないため、ログイン済みブラウザの D&D を再現するのが確実。

## 推奨: playwright-cli の D&D（user-attachments・リリースタグ不要）

web UI のドラッグ＆ドロップと同じく `github.com/user-attachments/assets/<uuid>` に上がり、対象リポを汚さず（リリースタグ不要）プライベートリポ内に保持される。

セットアップ: `npm i -g @playwright/cli`（`playwright-cli`。MCP の CLI ラッパー）。GitHub にログイン済みのブラウザプロファイルで操作する（認証はブラウザセッション。`playwright-cli open <url>` で一度開く）。

各 issue/PR ごとに:
1. `playwright-cli goto <issue-url>`
2. コメント textarea の出現を待つ（`eval "() => !!document.querySelector('textarea[placeholder*=\"Markdown\"]')"` が `true`）
3. `playwright-cli drop 'textarea[placeholder*="Markdown"]' --path=<画像の絶対パス>` ← **--path は絶対パス必須**（daemon の cwd 依存で相対は ENOENT）
4. 7〜9 秒待つ → GitHub が user-attachments に自動アップロードし、textarea に `<img src="https://github.com/user-attachments/assets/<uuid>">` が挿入される
5. textarea 値から `https://github.com/user-attachments/assets/[a-f0-9-]+` を抽出 → `gh issue edit <n> --body "$(gh issue view <n> --json body -q .body)\n\n<img src=URL>"` で本文に埋め込み（コメント送信は不要）
6. **textarea をクリアする**（最重要の落とし穴）。未送信内容が残ると次の `goto` で `beforeunload` ダイアログが出てナビゲーションがブロックされ、以降の操作が modal state で全失敗する。React 制御なので value 直書きは無効 → nativeInputValueSetter + input イベントで消す:
   `eval "() => { const ta=document.querySelector('textarea[placeholder*=\"Markdown\"]'); const s=Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype,'value').set; s.call(ta,''); ta.dispatchEvent(new Event('input',{bubbles:true})); }"`

補足: playwright-cli の eval 戻り値は `### Result` 行の次行に出る（`sed -n '/^### Result$/{n;p;q;}'`）。JSON は `JSON.stringify` で1行化して取る。

## gh-attach（atani/gh-attach）— 非推奨

かつて使っていた gh 拡張だが、現状は実用に難があり推奨しない:

- **direct / browser モードは動かない**: GitHub の新 issue UI が `file-attachment` Web Component を廃止したため、`document.querySelector('file-attachment')` が null になり policy 取得に失敗する（最新 v0.7.4 でも未対応）。
- **macOS の bash 3.2 で即死**: 空配列 `${pw_open_extra[@]}` が `set -u` 下で unbound variable エラー。
- CLI のみで動くのは `--release` モードだけだが、**リポジトリにリリースタグ（`gh-attach-assets`）が作成される副作用**がある。タグを作りたくない場合は使えない。最終手段。

## 避けるべき代替

- **GitShot**: ブラウザ不要だが、実体は別パブリックリポ（`<user>/gitshot-images`）の release asset か外部ホスト（catbox 等）。**社内・非公開の画像が公開／外部流出する**ため、社内 issue 用途では使わない。
