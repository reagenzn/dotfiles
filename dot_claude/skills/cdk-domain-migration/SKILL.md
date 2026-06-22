---
name: cdk-domain-migration
description: |
  CDKで管理されたインフラのルートドメインを変更するスキル。
  ユーザーが「ドメイン変更」「ドメイン移行」「DOMAIN_NAME変更」「証明書の差し替え」「ACMドメイン変更」
  「Some exports have changed」「UPDATE_ROLLBACK_FAILED」「Custom::CrossRegionExportWriter エラー」
  「証明書が in use で削除できない」などと言ったときに使用する。
  CDK v2の`crossRegionReferences: true`構成における value change 安全弁の回避手順を含む。
  dev/staging/prd 全環境で同一の V2リネーム方式のみを採用 (destroy/recreate等の代替手段は使わない)。
  dev=`dev_aq_aix_AA`, prd=`prd_aq_aix_AA` プロファイル前提。DNS委任設定はdev/prd完了済み。
---

# CDK Domain Migration

CDKプロジェクトのルートドメインを `aq-aix.com` から `aix.aq-dx.jp` へ変更するためのガイド。

**重要**: 本スキルは **V2リネーム方式のみ** を採用する。destroy/recreate 等の代替手段は**使わない**。dev/staging/prd を問わず同一のフローを適用する。

---

## AWSプロファイル (最初に確認)

コマンド例で登場する `<profile>` は環境に応じて以下を指す。AWS CLI 実行時に必ず付与する:

| 環境 | プロファイル名 |
|---|---|
| dev | `dev_aq_aix_AA` |
| prd | `prd_aq_aix_AA` |

認証切れ (`ExpiredToken` 等) の場合は `aws sso login --profile <profile>` で再認証。詳細は `aws-auth-local` スキル参照。

---

## エントリーポイント判別 (最初に実施)

ユーザーの現在の作業状態によって手順開始位置が変わる。以下を順に確認する。

### 質問1: ドメイン文字列の一括置換を既に行ったか？

```bash
# 旧ドメインがコード内にまだ残っているか確認
grep -rn "aq-aix.com" --include="*.ts" --include=".env*" --include="*.json" .
```

- 旧ドメインが多数ヒット → **No (未置換)** → 質問2をスキップし、「Step 0: プロジェクト構成の判別」へ進む
- 旧ドメインがヒットしない or 僅か → **Yes (置換済)** → 質問2へ

**注意**: `.env.development` 等 secret を含む `.env.*` は `.gitignore` 対象のことが多く、`git stash` で退避されない。tracked な `.env.*.example` と実 `.env.*` で値が乖離している可能性があるため、**実ファイルの `DOMAIN_NAME` / `SUBDOMAIN` を必ず直接確認**する:

```bash
grep -E "^(DOMAIN_NAME|SUBDOMAIN)=" .env.development 2>/dev/null || true
```

### 質問2: 置換後に `cdk deploy` を実行したか？

- **No (置換のみ済、未デプロイ)**
  - 置換はそのまま維持でOK。「Step 0」へ進み、Phase 1 で CertStack 内の旧 cert 部分をハードコードで旧ドメインに固定する方式で対応
  - revert は不要

- **Yes (デプロイ実行済)** → 質問3へ

### 質問3: 現在のCertStackのステータスは？

```bash
aws cloudformation describe-stacks \
  --region us-east-1 --profile <profile> \
  --stack-name <CertStack> \
  --query 'Stacks[0].StackStatus' --output text
```

- **`UPDATE_ROLLBACK_FAILED`**
  - 先にトラブルシューティング項「`UPDATE_ROLLBACK_FAILED`」で復旧
  - 復旧後、「Step 0」へ進み Phase 1 で CertStack ハードコード方式を適用 (revert 不要)

- **`UPDATE_ROLLBACK_COMPLETE`** (writerのエラーでロールバック成功済)
  - 既にCertStackは旧状態に戻っている → 「Step 0」から通常フロー (revert 不要、Phase 1 でハードコード)

- **`UPDATE_COMPLETE` or `CREATE_COMPLETE`**
  - デプロイは成功している。ドメイン変更は本当に反映されているか再確認 (検証セクション)
  - 反映済ならスキル不要。未反映なら状況詳細を再把握

### 前提: コード置換とハードコード方針

本スキルは **props 追加を避け、旧 cert の domainName を Phase 1 で CertStack 内に直接ハードコード** する方針を採る。`newHostedZoneDomainName` 等の新規 prop は**導入しない** (参考: odoo プロジェクトの構成)。

- 分岐A (`DnsValidatedCertificate`) では一括置換OK (作業手順内に明記)
- 分岐B (`crossRegionReferences`) では、Phase 1 の CertStack で**旧 cert の domainName をコード内にハードコード**で `aq-aix.com` 系列の値を直接記述する。これにより:
  - `.env.development` 等は Phase 1 の時点で**新ドメイン (`aix.aq-dx.jp`) で確定**してOK
  - bin/mastra.ts 等の prop 渡しは既存シグネチャのまま (props 追加不要)
  - 一時的なハードコードは Phase 3 で旧cert ごと削除するので長期残存しない

ユーザーが既に一括置換してしまった場合でも、Phase 1 の CertStack にハードコードを入れれば進められる。**revert は不要**。

#### .env 系ファイルの扱い

`.env.development` は Phase 1 時点で**新ドメインでOK**。CertStack 内の旧 cert はハードコードで旧ドメインを保持するため、`.env` 変更の影響を受けない。

#### cdk.context.json の罠

一括置換で `cdk.context.json` の HostedZone lookup キャッシュが「キー名 (domainName) だけ新ドメイン、Id は旧 HostedZone の値のまま」の破損状態になることがある。そのままデプロイすると存在しない HostedZone を参照して Route53 操作が失敗する。

- 対処: `cdk.context.json` を手動修正するか、`pnpm cdk context --clear` → `pnpm cdk synth` で再 lookup させる
- 再 lookup 後、新ドメインの HostedZone Id が **Pre-check で確認した値と一致**するか必ず照合

---

## Step 0: プロジェクト構成の判別

最初に `crossRegionReferences` と `DnsValidatedCertificate` の使用状況を確認する:

```bash
cd <infra directory>
grep -rn "crossRegionReferences" --include="*.ts"
grep -rn "DnsValidatedCertificate" --include="*.ts"
```

結果に基づく分岐:

| 検出結果 | 対応分岐 |
|---|---|
| `crossRegionReferences: true` のみ | **分岐B** (独立CertStack + export/import構成) |
| `DnsValidatedCertificate` のみ | **分岐A** (同スタック内Custom Resource構成) |
| 両方 / どちらもなし | 個別判断 (CloudFront不使用ならドメイン変更は単純、HostedZone.fromLookup の再導出のみ) |

---

## Pre-check (全分岐共通)

**1. 新ドメインのHostedZoneがAWS上に存在するか**

```bash
aws route53 list-hosted-zones-by-name --dns-name aix.aq-dx.jp --profile <profile>
```

> **NS委任確認はスキップ**: 本プロジェクトでは dev/prd いずれの環境も親ゾーンへのNS委任設定は既に完了済み。別ドメインへの新規移行時のみ改めて要確認。

**2. 現在のACM cert 状況把握**

```bash
aws acm list-certificates --region us-east-1 --profile <profile> \
  --query 'CertificateSummaryList[?contains(DomainName, `<サービス名>`)].[CertificateArn,DomainName,Status]' \
  --output table
```

**3. DOMAIN_NAME / SUBDOMAIN 粒度の確認**

`.env` の `DOMAIN_NAME` と `SUBDOMAIN` の組み合わせ方は複数パターンあり、`HostedZone.fromLookup` に渡す domainName の値が変わる:

- パターンX: `DOMAIN_NAME=<parent>` + `SUBDOMAIN=<sub>.<leaf>` (例: `aq-aix.com` + `odoo.dev` → fqdn `odoo.dev.aq-aix.com`)
- パターンY: `DOMAIN_NAME=<parent>.<sub>` + `SUBDOMAIN=<leaf>` (例: `dev.aq-aix.com` + `odoo` → fqdn `odoo.dev.aq-aix.com`)

同じ fqdn でも **fromLookup に渡す domainName が異なる**ため、AWS 上の HostedZone がどの粒度で存在するかを確認:

```bash
aws route53 list-hosted-zones-by-name --dns-name aix.aq-dx.jp --profile <profile>
```

V2 用 `newHostedZoneDomainName` も**実 HostedZone と同じ粒度**で指定しないと lookup 失敗し synth が止まる。

**4. config 構造の確認 (multi-env プロジェクト向け)**

リポジトリが dev / prd で config ファイルを分けている場合、deploy 対象 env の config を特定する:

- `bin/<app>.ts` / `bin/config.ts` が **手動切替** (コメントアウト式) で 1 つの config を import していることが多い。対象 env の config に切替える必要あり
- ファイル命名は `config/ecs.ts` (dev), `config/ecs-prd.ts` / `config/ecs.internal.prd.ts` / `config/lambda-prd.ts` のように **`-prd`** や **`.prd.ts`** サフィックスが prd 用、無印が dev 用のパターンが一般的
- **ブランチ戦略は 2 パターン**:
  - (a) `develop` ブランチ単一で dev / prd 両方の config を同時に進める (一般的)
  - (b) `environment/internal-prd` 等 env 別ブランチを並行運用 (例外的、PR も env 毎に複数必要)
- Phase 0-3 を進める際は **対象 env の config ファイルのみ編集**。他 env の config は誤って変更しないこと
- 他 env 分の同内容変更を PR に先取りで入れる場合は、config の該当箇所だけ flag を `false` 等に保持したまま commit し、実 deploy は別タイミングで進める

**5. フロントエンドアセットのビルド方式確認 (FrontendStack を含む構成)**

FrontendStack の asset bundling が Docker ベースのままだと、Phase 2 デプロイで `npm ci && npm run front:build` が Docker コンテナ内で走り、Docker Desktop のクラッシュ・ディスク逼迫・所要時間長大化のリスクがある (過去に Phase 2 実行中に Docker クラッシュ + `/private/tmp` ENOSPC でデプロイ停止した実例あり)。

確認コマンド:

```bash
grep -n "DockerImage.fromRegistry\|bundlingImage()\|tryBundle" \
  <infra>/lib/constructs/frontend-static-assets-construct.ts \
  <infra>/lib/front/static-assets.ts 2>/dev/null
```

`tryBundle` (local bundling) が未実装なら、Phase 1 着手前に **aix-ai-agent-template の `e025edd1927a0f5404a9aece998ef37d7615ba73` 相当のローカルビルド化パッチ**を入れる。対応手順は「トラブルシューティング > 症状: FrontendStack の Docker bundling で詰まる」を参照。

Pre-checkで HostedZone が見つからない等の不整合があれば**中断して原因調査**。

---

## 分岐A: `DnsValidatedCertificate` 使用構成

cert作成がスタック内のCustom Resourceで完結し、スタック間の export/import を介さないため **in-place置換可能**。

### 手順

1. ドメイン文字列の一括置換
   - コード全般 (`.ts`, `.tsx` 等)
   - **注意**: VSCodeの一括置換は`.env*`を含めないので別途手動で
     ```bash
     grep -rn "aq-aix.com" --include=".env*" .
     ```
2. `cdk.context.json` のクリア + 再synth
   ```bash
   pnpm cdk context --clear
   pnpm cdk synth
   ```
3. デプロイ
   ```bash
   pnpm cdk deploy --all
   ```
4. 検証 (後述「検証」セクション参照)

`DnsValidatedCertificate` はCDK v2後期で `@deprecated`。将来的に `crossRegionReferences` への移行を検討すると、今回のような問題を考慮する必要が出てくる。

---

## 分岐B: `crossRegionReferences` 構成

CertStack (us-east-1) が証明書を作成し、FrontendStack/BackendStack等のconsumer (app region) がそのARNをimportする構成。

### 問題の本質を理解する

CDKの `Custom::CrossRegionExportWriter` Lambda は以下の安全弁を持つ:

```javascript
// writer Lambda (index.js) の Update ハンドラ
function C(oldExports, newExports) {
  return Object.keys(oldExports)
    .filter(k => newExports.hasOwnProperty(k) && oldExports[k] !== newExports[k]);
}
if (changed.length > 0) throw new Error("Some exports have changed!");
```

**重要な事実**:

- このチェックは **CFnの `OldResourceProperties.WriterProps.exports` と `ResourceProperties.WriterProps.exports` の比較**
- **SSM パラメータの現在値やタグは一切参照しない**
- 「同じ export キーで値が違う場合に throw」というCFn標準仕様 (`Export cannot be updated as it is in use`) の cross-region 版

したがって:

- SSM strong-ref タグを `remove-tags-from-resource` で削除しても **このエラーは解消しない** (別エラー `Exports cannot be updated: ... is in use by stack(s)` にのみ効く)
- SSMパラメータの値を書き換えても効果なし
- **回避策は export キーを変える = cert の logical ID を V2 にリネームする以外ない**

### 手順: 3-phase V2 rename

#### Phase 1: CertStack に V2 cert を **追加** (旧cert はそのまま残す)

**目的**: 旧certの export キーに触れず、新しい V2 export を追加する。writer の `changed check` を迂回。

**操作**:

1. `lib/stacks/certificates-stack.ts` に V2 cert リソースを追加。**新規 prop は導入せず**、旧 cert の domainName を**コード内にハードコード**する (`.env` 変更の影響を切り離すため):

   ```typescript
   export class CertificatesStack extends cdk.Stack {
     public readonly backendCloudFrontCertArn?: string;      // 旧 (Phase 3で削除)
     public readonly frontendCloudFrontCertArn?: string;     // 旧 (Phase 3で削除)
     public readonly backendCloudFrontCertArnV2?: string;    // 追加
     public readonly frontendCloudFrontCertArnV2?: string;   // 追加

     constructor(scope: Construct, id: string, props: CertificatesStackProps) {
       super(scope, id, { ...props, crossRegionReferences: true });

       // 新HostedZone: props経由 (.env の DOMAIN_NAME は新ドメインでOK)
       const hostedZone = route53.HostedZone.fromLookup(this, "HostedZone", {
         domainName: props.hostedZoneDomainName,  // 新: aix.aq-dx.jp
       });

       // 旧cert: domainName を一時的にハードコード (Phase 3 で全部削除する前提)
       // TODO: Phase 3 で旧cert ごと削除
       if (props.createCloudFrontBackendCert) {
         const legacyHostedZone = route53.HostedZone.fromLookup(this, "HostedZoneLegacy", {
           domainName: "aq-aix.com",  // ← ハードコード (既存デプロイ済cert の HostedZone)
         });
         const backend = new AcmConstruct(this, "BackendCloudFrontCert", {
           systemName: props.systemName,
           environment: props.environment,
           awsConfig: { account: this.account, region: this.region },
           settings: {
             label: "backend",
             domainName: "api.agent-template.dev.aq-aix.com",  // ← ハードコード (既存deploy済domainと完全一致)
             hostedZoneId: legacyHostedZone.hostedZoneId,
             exportRootDomain: true,
           },
           importSystemName: props.importSystemName,
         });
         this.backendCloudFrontCertArn = backend.certificateArn;
       }

       // V2 cert: 新ドメイン (props経由、.env の DOMAIN_NAME から)
       if (props.createCloudFrontBackendCertV2) {
         const backendDomainNew = `${props.backendSubdomain}.${props.hostedZoneDomainName}`;
         const backendV2 = new AcmConstruct(this, "BackendCloudFrontCertV2", {
           systemName: props.systemName,
           environment: props.environment,
           awsConfig: { account: this.account, region: this.region },
           settings: {
             label: "backend-v2",
             domainName: backendDomainNew,
             hostedZoneId: hostedZone.hostedZoneId,
             exportRootDomain: false,
           },
           importSystemName: props.importSystemName,
         });
         this.backendCloudFrontCertArnV2 = backendV2.certificateArn;
       }
       // Frontend も同様 (FrontendCloudFrontCert は旧domainをハードコード、FrontendCloudFrontCertV2 は新)
     }
   }
   ```

   **ハードコード箇所の確認ポイント**:
   - 既存デプロイ済み cert の domainName 文字列と**完全一致**させる (1文字でもズレると cert 物理置換 → ARN変更 → writer `changed` check throw)
   - 実値確認: `aws acm describe-certificate --certificate-arn <既存ARN> --region us-east-1 --profile <profile> --query 'Certificate.DomainName'`

2. CertStack をデプロイ
   ```bash
   pnpm cdk deploy <CertificatesStack> --profile <profile>
   ```

**writerの挙動**:
- `oldExports` = {旧backendパス: 旧backend ARN, 旧frontendパス: 旧frontend ARN}
- `newExports` = {旧backendパス: 旧backend ARN, 旧frontendパス: 旧frontend ARN, 新V2backendパス: V2backend ARN, 新V2frontendパス: V2frontend ARN}
- `changed check` = 共通キーで値違うもの → **なし (旧はそのまま)** → PASS
- `added check (throwIfInUse)` = 新V2パス → タグなし → PASS → SSM V2パラメータ作成

**結果**:
- ACMに新ドメインのV2 cert が ISSUED で作成
- SSMに新V2 export パラメータが作成
- 旧cert/旧SSMは無傷

#### Phase 2: consumer (Frontend/Backend) を V2 ARN参照に切替 + デプロイ

**目的**: CloudFront distribution の viewer certificate を V2 cert に切替。旧cert への参照を解除する。

**最重要警告**:
- Phase 2 デプロイでは **consumer stack 名を明示指定 + `--exclusively`** を必ず付ける
  ```bash
  # 正: --exclusively 必須
  pnpm cdk deploy <BackendStack> --exclusively

  # 誤: 依存スタック(CertStack)が自動で巻き込まれて詰む
  pnpm cdk deploy <BackendStack>
  pnpm cdk deploy --all
  ```
- 理由 (2 段階):
  1. **依存スタックの自動巻き込み**: CDK v2 は `--exclusively` なしだと指定スタックの**依存スタック (CertStack 等) も自動デプロイ**する。スタック名を明示指定していても依存が入ってしまう
  2. **CertStack の diff**: Phase 2 で `.env` を新ドメインに切替えた時点で、CertStack 内の**既存 cert (旧 logical ID)** の domainName プロパティも再計算されて diff に出る。CertStack を巻き込むと writer の `removed` チェック (旧パスに consumer の strong-ref タグがまだ残っている) で `Exports cannot be updated: ... is in use by stack(s) ...` が throw される
- CertStack の未デプロイ差分は Phase 3 まで**意図的に放置**する (デプロイ前に `cdk diff <CertStack>` で差分が出ても驚かないこと)
- 巻き込んで UPDATE_ROLLBACK_FAILED に陥った場合はトラブルシューティング「`UPDATE_ROLLBACK_FAILED`」の `continue-update-rollback --resources-to-skip <ExportsWriter>` で復旧

**CloudFront Origin が共有 ALB の場合、追加の罠あり**: トラブルシューティングの「罠: CloudFront は shared ALB の non-default cert に SNI マッチしない」を必ず事前確認。Phase 2 デプロイが正常完了しても viewer アクセスで 502 になる別レイヤの問題。

**操作**:

1. `bin/<app>.ts` (例: `bin/mastra.ts`) で consumer stack に渡す cert ARN を V2 版に切替:
   ```typescript
   const frontendCertificate = CertificatesStackInstance.frontendCloudFrontCertArnV2;  // 旧: frontendCloudFrontCertArn
   const backendCertificate = CertificatesStackInstance.backendCloudFrontCertArnV2;    // 旧: backendCloudFrontCertArn
   ```

2. ドメイン名関連の環境変数・設定もこのタイミングで新ドメインへ切替:
   - `.env.development` の `DOMAIN_NAME`, `FRONTEND_URL`, `BACKEND_URL`
   - 必要に応じて `cdk.context.json` の新HostedZoneIDを追加 (Pre-checkで確認済みのもの)

3. consumer stack をデプロイ
   ```bash
   pnpm cdk deploy <FrontendStack> <BackendStack>
   ```

**reader/readerの挙動**:
- reader Custom Resource は「読む SSM パスが変わった」と認識
- 旧パスから strong-ref タグ削除、V2パスに新規 strong-ref タグ付与
- consumer stack の CloudFront distribution が V2 cert ARN を viewer certificate として参照

**結果**:
- CloudFrontドメインへのアクセスは新ドメインで動作 (cert一致)
- 旧certは **どこからも参照されない** 状態 (旧strong-refタグ除去済み)

#### Phase 3: CertStack から旧cert リソースを削除 + デプロイ

**目的**: 旧cert リソースを CDK テンプレートから削除し、ACMからも削除する。

**操作**:

1. `lib/stacks/certificates-stack.ts` から旧cert の resource 定義を削除:
   ```typescript
   // 削除: BackendCloudFrontCert, FrontendCloudFrontCert (V2ではない方)
   // 残す: BackendCloudFrontCertV2, FrontendCloudFrontCertV2
   ```
   プロパティ `backendCloudFrontCertArn`, `frontendCloudFrontCertArn` も削除可能。consumer からは V2 版のみ参照されている。

2. CertStack デプロイ
   ```bash
   pnpm cdk deploy <CertificatesStack>
   ```

**writerの挙動**:
- `oldExports` = {旧パス, V2パス}
- `newExports` = {V2パス}
- `removed check (throwIfInUse)` = 旧パス → **strong-refタグ除去済み (Phase 2で)** → PASS → SSM旧パラメータ削除
- `changed` = なし → PASS

**CFnの挙動**:
- 旧cert リソース: template から削除 → `DELETE` 試行
- 旧certはCloudFront distributionから参照解除済み (Phase 2で切替済) → ACM API削除成功

**結果**:
- ACMから旧cert 2本削除
- SSM旧exportパラメータ削除
- CertStack には V2 cert のみ残る

#### Phase 4: 仕上げ (optional)

- 不要になった `props.oldHostedZoneDomainName` 等の引数や `createCloudFrontBackendCert` 系フラグをコードから整理
- V2 サフィックスを元の名前に戻したい場合は、同じ手順を逆方向で行う (現在のV2 → 新しいV3追加 → 旧V2削除)。**通常はそのままV2 で運用継続**してOK

---

## トラブルシューティング

### 症状: `UPDATE_FAILED` with `Some exports have changed!`

**原因**: cert logical ID を変えずに domainName だけ変更したケース。writer の安全弁にヒット。

**対処**:
1. まず CFn の状態を確認:
   ```bash
   aws cloudformation describe-stacks --region us-east-1 \
     --stack-name <CertStack> --profile <profile> \
     --query 'Stacks[0].StackStatus'
   ```
2. 既に `UPDATE_ROLLBACK_FAILED` になっている場合は次の項「症状: UPDATE_ROLLBACK_FAILED」で先に復旧
3. 分岐B B-2 の Phase 1-3 手順を頭から実施

### 症状: `UPDATE_ROLLBACK_FAILED` (writerがロールバック時にも失敗)

**原因**: writer の `OldResourceProperties` が前回失敗時の NEW 値を保持しており、ロールバック対象との比較でも value 差分を検出してしまう。

**対処**: writerリソースをスキップしてロールバック完了させる:

```bash
aws cloudformation continue-update-rollback \
  --region <region> \
  --profile <profile> \
  --stack-name <CertStack> \
  --resources-to-skip <ExportsWriter-LogicalId>
```

ロジカルIDはスタックイベントから取得:
```bash
aws cloudformation describe-stack-events --region <region> \
  --stack-name <CertStack> --profile <profile> \
  --query 'StackEvents[?contains(LogicalResourceId, `ExportsWriter`)].LogicalResourceId' \
  --output text | head -1
```

スキップ後、CFnは該当リソースを「UPDATE_COMPLETE with new config」として記録する点に注意 (次回update時の `OldResourceProperties` がその値になる)。次のdeploy挙動は必ず分岐B B-2 手順に則って行うこと。

### 症状: ACM cert が削除できない (`Certificate ... is in use by ...`)

**原因**: CloudFront distribution 等がまだその cert を viewer certificate として参照中。

**対処**:
- consumer stack のデプロイを先に完了させ、distribution の cert を新しいものに切替えてから CertStack の cert 削除を試みる
- 強制削除は不可。参照解除のみが解。CloudFront distribution の disable → delete にも数時間かかる (ブルーグリーンが必要な場合は要計画)

### 症状: FrontendStack の Docker bundling で詰まる / Docker クラッシュ / ディスク逼迫

**原因**: FrontendStack の asset bundling が Docker (`node:22-alpine`) コンテナ内で `npm ci && npm run front:build` を実行する方式のままになっている。Phase 2 デプロイ時に以下が発生しやすい:

- `npm ci` が Docker VM 内で node_modules (数GB) を展開し、Docker Desktop が OOM やファイルシステム逼迫でクラッシュ
- ホスト側の `/private/tmp` や docker-desktop image が肥大化して `ENOSPC: no space left on device` でデプロイが abort
- bundling に毎回 2〜5分かかり、cache 効かない (asset hash がソースツリー全体の fingerprint のため、どこか一箇所変えると再ビルド)

**対処**: `aix-ai-agent-template` の `e025edd1927a0f5404a9aece998ef37d7615ba73` と同等の **ローカルビルド優先 + Docker fallback** パッチを入れる。

変更対象ファイル (リポジトリにある分だけ適用):

- `lib/front/frontend-build.ts`
- `lib/constructs/frontend-build-construct.ts`
- `lib/front/static-assets.ts`
- `lib/constructs/frontend-static-assets-construct.ts`

実装内容:

1. **`frontend-build.ts` / `frontend-build-construct.ts` に `createLocalBuildCommand(outputDir: string): string` を追加**
   - `NODE_ENV=development npm ci` (または pnpm / yarn) → `env KEY=VAL ... npm run front:build` → `cp -r <buildOutputPath>/. outputDir/` を `&&` で連結した単一コマンド文字列を返す
   - `NODE_ENV=development` は devDependencies を確実に入れるため必須 (production だと tsc が入らずビルド失敗)
   - `buildEnvironment` を `env KEY='value'` 形式で inline に渡す (unresolved CDK token は既存の placeholder 置換経由でそのまま文字列として埋め込まれる)

2. **`static-assets.ts` / `frontend-static-assets-construct.ts` の `createAsset()` を改修**
   - `hashFrontendSource(frontendPath: string): string` メソッドを追加 (node_modules / dist / .turbo を除外して sha256 ハッシュを計算)
   - Asset の `path` をソースツリーではなく `<rootPath>/node_modules/.cache/cdk-frontend/` (マーカーディレクトリ) に変更し、その中に `frontend.hash` ファイルを書き出す
   - Asset に `assetHashType: cdk.AssetHashType.CUSTOM, assetHash: frontHash` を指定し、front/ 配下の変更のみで再ビルドが走るようにする
   - `bundling.local.tryBundle(outputDir)` を追加: `execSync(frontendBuild.createLocalBuildCommand(outputDir), { cwd: frontendBuild.rootPath, stdio: "inherit" })` を呼び、成功なら `true`、失敗なら `console.error` してから `false` を返す (false で既存 Docker bundling に fallback)

参考 diff:

```bash
cd /path/to/aix-ai-agent-template
git show e025edd1927a0f5404a9aece998ef37d7615ba73 -- \
  packages/infra/lib/constructs/frontend-build-construct.ts \
  packages/infra/lib/constructs/frontend-static-assets-construct.ts \
  packages/infra/lib/front/frontend-build.ts \
  packages/infra/lib/front/static-assets.ts
```

**効果**: Docker 経由で数分〜タイムアウト寸前だった bundling が数秒〜十数秒 (`✓ built in 9.06s` レベル) で完了。Docker を起動しなくても deploy が走るため、Docker クラッシュ・ディスク逼迫の要因をそもそも排除できる。

**前提**:

- ローカルに `npm` (または pnpm / yarn) + 対応 Node バージョンが入っていること
- root の `node_modules/.cache/cdk-frontend/` を書き込める権限があること (workspace root)
- front ビルド自体がローカルで成功すること。通らない場合は Phase 2 に入る前に `npm run front:build` を単独実行して TS エラー等を先に潰す

**タイミング**: Pre-check 5 で未実装と判明したら **Phase 1 着手前** に入れておくのがベスト (Phase 1 自体は Docker bundling に依存しないので Phase 2 直前でも間に合うが、先に済ませて別 commit/PR にする方がレビューしやすい)。

### 症状: Phase 2 直後に CloudFront 502 Bad Gateway

**原因**: CloudFront Origin の `DomainName` が旧 ALB ドメイン (例: `alb.dev.aq-aix.com`) のまま残っており、新 ALB への CNAME 解決に失敗 (または共有ALB側で旧 host-header ルーティング rule が無い)。

config で `backendStack.ecs.importedSettings.albDomain: "alb.<new-domain>"` を新値に指定していても、**stack 実装のバグで `importedSettings` が construct に伝搬されていない**とこの現象が起きる。config override が無視され、schema default (`DefaultEcsBackendImportedSettings.albDomain`) が CloudFront template に入る。

**確認**:

```bash
aws cloudfront get-distribution-config --id <dist-id> --profile <profile> \
  --query 'DistributionConfig.Origins.Items[0].DomainName'
```

旧 ALB ドメインが返ってきたら該当。

**修正**: `lib/stacks/backend-stack.ts` (または同等の stack) で construct を生成する箇所に `importedSettings` を明示伝搬する:

```typescript
// 修正前
const ecsBackend = new EcsBackendConstruct(this, "EcsBackend", {
  ...
  settings,
});

// 修正後
const ecsBackend = new EcsBackendConstruct(this, "EcsBackend", {
  ...
  settings,
  importedSettings: props.ecs?.importedSettings,   // ← 追加
});
```

**drift 対処**: dev 等で事前に AWS Console から CloudFront Origin DomainName を新値に手動変更していたケースは、バグ修正後の cdk deploy でコード側の正しい値が反映されて drift 解消する。手動変更済み環境は「事故らない」が、コード修正を怠ると次回 deploy で revert されるので忘れず直す。

**必須チェック**: 本スキルで V2 リネームを進める際は、Phase 2 開始前に **construct レベルで `importedSettings` が渡されているかソースレビュー**しておく。`backend-stack.ts` 等 stack 実装で `new XxxConstruct(..., { settings, importedSettings: props.xxx?.importedSettings, ... })` の形になっていなければ、bug fix を先に commit してから Phase 2 に進むこと (参考: aix-sql-ai PR #445 / #446)。

### 罠: CloudFront は shared ALB の non-default cert に SNI マッチしない

**前提構成**: 複数アプリが 1つの shared ALB を共有し、それぞれの CloudFront が `alb.<domain>` を Origin として使う構成 (例: `aix-dev-alb` を複数アプリで共有)。

**症状**: 新ドメインに切替えたアプリの CloudFront で **502 Bad Gateway** ("Error from cloudfront") が出るが以下は全て正常:

- ALB 直接 (curl に SNI=新ドメイン + x-com-token + x-host-header 付与): **200 OK**
- ALB の CloudWatch `RequestCount` が増加しない (= ALB まで届いていない)
- CloudFront Origin の DNS 解決は正常
- CloudFront Origin の Protocol/Port/Cert ARN/Custom Headers は正しい
- 同じ ALB を使う他アプリ (旧ドメイン origin) は正常稼働中

**原因**: CloudFront は ALB Listener の **default cert のみに SNI マッチする**。Listener に複数 cert が attached されていても、non-default cert は CloudFront Origin 接続時に選択されない。結果 Origin hostname と ALB が返す cert の CN/SAN 不一致で SSL verify 失敗 → 接続確立前に 502。

これは curl の動作と異なる (curl は TLS SNI で正しく non-default cert をマッチさせるので ALB 直接テストは 200 になってしまい、罠を見抜けない)。

**確認コマンド**:

```bash
# 同じ ALB を origin にしている CF distribution を列挙
aws cloudfront list-distributions --profile <profile> \
  --query 'DistributionList.Items[?Origins.Items[?contains(DomainName, `alb.`)]].{id:Id,aliases:Aliases.Items,origin:Origins.Items[0].DomainName}' \
  --output json

# ALB Listener の default cert
aws elbv2 describe-listener-certificates --region <region> --profile <profile> \
  --listener-arn <listener-arn> \
  --query 'Certificates[?IsDefault==`true`].CertificateArn'
```

列挙された全アプリが**同じ ALB Listener default cert に依存**する。1 アプリだけを新 origin に切替えは不可能。

**対処パターン**:

### 対処A: Odoo 等のアプリ側で Origin を旧 hostname に維持 (運用実績あり)

影響アプリの CloudFront Origin を **旧 hostname** のまま残し、viewer 側だけ新ドメインにする:

- CloudFront viewer cert: 新 (V2 cert)
- CloudFront Aliases: 新ドメイン
- CloudFront Origin DomainName: **旧 hostname** (ALB default cert にマッチ)
- ALB Listener Rule の x-host-header: 新ドメイン (ユーザー向けドメインで判定)

ユーザーから見れば完全に新ドメイン、CloudFront → ALB 内部通信だけ旧 hostname を維持。他アプリ・shared ALB 影響なし。将来 ALB default cert が新に切替わったら CDK コードで origin を新に戻す。

### 対処B: 共有 ALB の全アプリを一斉移行

dev 環境で数分のダウンタイム許容可能な場合。手順:

1. 全影響 CloudFront Distribution の `DistributionConfig` をバックアップ

   ```bash
   for ID in <id1> <id2> ...; do
     aws cloudfront get-distribution-config --id $ID --profile <profile> > backup/$ID.json
   done
   ```

2. 各 config を書き換えて並列 `update-distribution` 発行

   ```bash
   for ID in <id1> <id2> ...; do
     ETAG=$(jq -r '.ETag' backup/$ID.json)
     jq '.DistributionConfig | .Origins.Items[0].DomainName = "<new-alb-hostname>"' \
       backup/$ID.json > updated/$ID.json
     aws cloudfront update-distribution --id $ID --if-match $ETAG \
       --distribution-config file://updated/$ID.json &
   done
   wait
   ```

3. ALB default cert を新に切替

   ```bash
   aws elbv2 modify-listener --listener-arn <arn> \
     --certificates CertificateArn=<新cert>
   # 旧 cert は保険で additional に残しておく
   aws elbv2 add-listener-certificates --listener-arn <arn> \
     --certificates CertificateArn=<旧cert>
   ```

4. CloudFront propagation (通常 5-15分、速いと 1-2分) を `Distribution.Status` で監視

5. 全アプリ curl 疎通確認。全 200/401 (app固有) になれば成功

6. 各アプリ CDK repo + shared infra repo (aix-infra 等) を**後追いコミット** (CDK drift 解消)

**注意**: 手順 2 と 3 の順序は問わない。どちらを先にやっても一時的 502 は避けられないが、両方揃う瞬間まで最短数秒〜数分。`modify-listener --certificates` は**default のみ置換**する動作だが、AWS SDK/CLI 実装では attached cert 全てを **上書き**することがある (実測で旧 cert が消失する挙動を確認)。切替直後に `add-listener-certificates` で旧 cert を再attach しておくのが安全。

**重要**: 対処Aと対処Bのどちらを選ぶかは、同じ ALB 上の**全アプリの移行スケジュール**次第。他アプリの CDK repo を後追いで変更する権限・責任がない場合は対処A一択。

### 罠: Phase 1 時点で V2 cert の SSM export は**まだ存在しない**

CDK の cross-region export は **consumer が実際に参照する値のみ** SSM に書き出す仕様。Phase 1 は consumer (BackendStack) が V2 ARN を参照していないため:

- CertStack に V2 cert リソースは作成される
- ACM に V2 cert は ISSUED される
- しかし `/cdk/exports/.../V2...` の SSM export パラメータは**作成されない**

Phase 2 デプロイで初めて reader (BackendStack) が V2 を参照 → writer が V2 パスを新規 add & 旧を remove 試行 → 旧に strong-ref が残っていて throw → rollback 中に writer が V2 を delete する挙動が入る (forward 時 add 済み or rollback で add 逆転) → `continue-update-rollback --resources-to-skip` 復旧後、V2 SSM が**消えた状態**で writer が "完了扱い" になるパターンが発生する。

**症状**: BackendStack 再デプロイ時に次が出る:
```
Failed to create ChangeSet: Parameters: [ssm:/cdk/exports/.../V2...] cannot be found.
```

**対処**: V2 cert ARN は ACM に残っているので、該当 SSM を手動で put:

```bash
aws ssm put-parameter \
  --region <consumer-region> --profile <profile> \
  --name "/cdk/exports/<ConsumerStack>/...V2...<hash>" \
  --type String \
  --value "<V2 cert ARN>"
```

SSM パラメータ名は失敗した ChangeSet エラーメッセージに出ている。Value は `aws acm list-certificates` で V2 domain の ARN を取得。その後 `cdk deploy <ConsumerStack> --exclusively` で再試行。

**注意 (事前 put する場合)**: SSM パス末尾のハッシュは **stack 名に依存する** (`FaqBuilderDevBackendStack` と `FaqBuilderPrdBackendStack` でハッシュが異なる)。dev で確定したパスをそのまま prd にコピーして put すると後段の ChangeSet 作成で `cannot be found` になる。事前に put する場合は対象 env の `cdk synth` を走らせて `infra/cdk.out/<ConsumerStack>.template.json` から正しいパスを抽出:

```bash
grep -oE '/cdk/exports/<ConsumerStack>/[^"]*CertV2[^"]*' \
  infra/cdk.out/<ConsumerStack>.template.json | sort -u
```

もしくは迷ったら事前 put せず、まず `cdk deploy` を走らせて失敗させ、エラーメッセージ中のパスをそのまま使う方が確実。

**drift 懸念**: 手動で作った SSM は本来 writer が管理するもの。Phase 3 で CertStack が再度デプロイされる時、writer が drift 検知する可能性はあるが、writer の ResourceProperties.exports と一致する値 (= V2 パス: V2 ARN) なら実質問題なし。

### 罠: Phase 2 で SSM 手動 put → Phase 3 で writer が `ParameterAlreadyExists` / `is in use by stack(s)` で失敗

**上記「罠: Phase 1 時点で V2 cert の SSM export はまだ存在しない」の手動 put で Phase 2 を通した場合のフォローアップ**。

Phase 3 で CertStack をデプロイすると、writer は以下の理由で失敗する:

1. writer の CFn state (`OldResourceProperties.exports`) は Phase 1 時点の値 = 旧 4 key のみ (V2 は未登録)
2. Phase 3 の新 exports = V2 4 key のみ
3. writer は V2 を `added` 扱いで create 試行 → ただし SSM は手動 put で既存 → さらに consumer reader が strong-ref タグを付与済
4. writer の `throwIfInUse` / `ParameterAlreadyExists` チェックに引っかかって throw
5. rollback で旧 key が writer 管理下に戻るが、V2 key は writer が rollback で delete する (writer が管理していない前提で扱うため)
6. その後 `continue-update-rollback --resources-to-skip` も必要になる、あるいは ROLLBACK が writer だけで完了すれば `UPDATE_ROLLBACK_COMPLETE` に戻る

**症状 (順に発生しうる)**:

```
Received response status [FAILED] from custom resource. Message returned: Error: Exports cannot be updated:
/cdk/exports/.../V2... is in use by stack(s) <ConsumerStack>
```

もしくは (strong-ref タグを先に除去した場合):

```
ParameterAlreadyExists: The parameter already exists.
To overwrite this value, set the overwrite option in the request to true.
```

**対処手順**:

1. CFn スタック状態を確認:
   ```bash
   aws cloudformation describe-stacks --region <region> --profile <profile> \
     --stack-name <CertStack> --query 'Stacks[0].StackStatus' --output text
   ```

2. `UPDATE_ROLLBACK_FAILED` であれば writer をスキップして rollback 完了:
   ```bash
   aws cloudformation continue-update-rollback \
     --region <region> --profile <profile> \
     --stack-name <CertStack> \
     --resources-to-skip <ExportsWriter-LogicalId>
   ```
   `UPDATE_ROLLBACK_COMPLETE` になるまで待つ。

3. V2 SSM の現状確認。rollback 中に writer が V2 SSM を delete する挙動が入ることが多く、**すでに `ParameterNotFound` になっているケースが多い**:
   ```bash
   aws ssm get-parameter --region <consumer-region> --profile <profile> \
     --name "/cdk/exports/<ConsumerStack>/...V2..."
   ```

4. **V2 SSM が残っていれば手動 delete** (`--exclusively` で CertStack 単独再デプロイ前の必須準備):
   ```bash
   # strong-ref タグを先に除去しておかないと delete 前に tag 由来で別エラーになることがある
   aws ssm remove-tags-from-resource \
     --region <consumer-region> --profile <profile> \
     --resource-type Parameter \
     --resource-id "/cdk/exports/<ConsumerStack>/...V2..." \
     --tag-keys "aws-cdk:strong-ref:<ConsumerStack>"

   aws ssm delete-parameter \
     --region <consumer-region> --profile <profile> \
     --name "/cdk/exports/<ConsumerStack>/...V2..."
   ```

5. CertStack を再デプロイ:
   ```bash
   pnpm cdk deploy <CertStack> --exclusively
   ```
   writer は V2 を正常 create (`removed 旧` + `added V2` フロー)、旧 cert リソースも destroy 完了。

6. consumer stack の V2 SSM strong-ref タグは writer 管理外に戻っているため、次回 consumer を deploy すると reader が再度 tag 付与する。急ぐ場合は手動で `add-tags-to-resource` で `aws-cdk:strong-ref:<ConsumerStack>=true` タグを付ければ同等。

**予防策 (次回以降の改善)**:

- Phase 1 で `.env` の旧 root domain 値をハードコードで固定し、**Phase 2 を `--exclusively` なしで CertStack と consumer を同時デプロイ** する方式に切り替えると、writer が Phase 2 時点で V2 を exports に追加 → SSM 自動 create → reader tag 付与 の正常フローに乗せられる。その場合、CertStack の旧 cert 側も `props.oldHostedZoneDomainName` のような専用プロパティで domainName を固定化しておき、`.env` の `DOMAIN_NAME` を切替えても旧 cert の domainName が変わらないようにする必要がある。
- この前提を満たせないプロジェクト (レガシーな `.env` 依存が強い等) では本手順 (手動 put → 手動 delete) で進めるしかない。Phase 2 で put した SSM は **Phase 3 着手前に必ず delete する** チェックリストを進行管理に入れる。

### 罠: `.env.*` が `.gitignore` 対象で `git stash` で退避されない

`.env.development` 等の secret 含むファイルは `.gitignore` 対象のことが多い。このため:

- ユーザーが事前に一括置換してコードを stash/revert しても、`.env.*` の中身は新ドメインのまま残る
- Phase 1 実施時、`config.domainName = 新ドメイン` になり、CertStack 内の**既存 cert (旧 logical ID)** の domainName プロパティが再計算されて変化する → writer `Some exports have changed!` throw

**事前確認**:

```bash
grep -E "^(DOMAIN_NAME|SUBDOMAIN)=" .env.* 2>/dev/null
```

**対処**:
- Phase 1 実施中は `.env.*` を旧値に戻す
- または `bin/<app>.ts` 内で Phase 1 専用のハードコードに書き換え、`.env` に依存させない

### 罠: 一括置換で `cdk.context.json` が破損状態になる

CDK の `cdk.context.json` は `HostedZone.fromLookup` の結果をキャッシュしている。ユーザーが sed/IDE の一括置換を行うと、**キー名 (domainName) だけが新ドメインに置換され、値側の HostedZone Id は旧 HostedZone のまま**という破損状態になることがある。

```json
{
  "hosted-zone:...domainName=aix.aq-dx.jp:region=us-east-1": {
    "Id": "/hostedzone/<OLD-HOSTED-ZONE-ID>",   // ← 旧のまま残る
    "Name": "aix.aq-dx.jp."
  }
}
```

そのままデプロイすると存在しない HostedZone を参照して Route53 操作が失敗する。

**対処**:
- `pnpm cdk context --clear` → `pnpm cdk synth` で再 lookup
- または `cdk.context.json` を手動修正し、Pre-check で確認した新 HostedZone Id に差し替える
- 再 lookup 後は Pre-check の値と照合して検証

### 罠: SSM strong-ref タグ削除は `Some exports have changed!` には効かない

一見 writer のエラーは SSM タグ由来に見えるが、writer の **`changed` チェック** (`Some exports have changed!`) は **SSMタグも現在値も参照しない**。CFnの `OldResourceProperties` vs `ResourceProperties` のみ。

`aws ssm remove-tags-from-resource` でタグ削除しても `changed` エラーは解消しない。タグ削除が効くのは別の `throwIfInUse` チェック (エラー文言: `Exports cannot be updated: ... is in use by stack(s) ...`) のみ。

**エラーメッセージの文言を確認して対処法を選ぶこと**:
- `Some exports have changed!` → V2 リネーム (分岐B B-2)
- `Exports cannot be updated: ... is in use by stack(s) ...` → consumer側の参照解除を先に実施

---

## 検証

全phase完了後、以下を確認:

### 1. ACM証明書

```bash
aws acm list-certificates --region us-east-1 --profile <profile> \
  --query 'CertificateSummaryList[?contains(DomainName, `<サービス名>`)].[DomainName,Status]' \
  --output table
```

新ドメインの cert が `ISSUED`、旧ドメインの cert が消えていること。

### 2. SSM exports (ap-northeast-1等、consumer region)

```bash
aws ssm describe-parameters --region <consumer-region> --profile <profile> \
  --parameter-filters "Key=Name,Option=BeginsWith,Values=/cdk/exports/<ConsumerStack>" \
  --query 'Parameters[].Name'
```

V2 の新パスが存在し、旧パスが消えていること。

### 3. CloudFront distribution

```bash
aws cloudfront list-distributions --profile <profile> \
  --query 'DistributionList.Items[?Aliases.Items[?contains(@, `aix.aq-dx.jp`)]].[Id,Aliases.Items]'
```

新ドメインが Aliases に含まれていること。

### 4. Route53 alias record

```bash
dig <new-fqdn>
```

CloudFrontドメインにエイリアスされ、正しいAレコードが返ること。

### 5. 実アクセス + cert確認

```bash
curl -I https://<new-fqdn>/
# 2xx/3xx応答 + HSTSヘッダー等の確認

# cert内容確認
openssl s_client -connect <new-fqdn>:443 -servername <new-fqdn> </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

Subject CN が新ドメイン、有効期限が現在時刻より未来、などを確認。

### 6. CFn スタックステータス

```bash
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
  --region <region> --profile <profile> \
  --query 'StackSummaries[?contains(StackName, `<prefix>`)].[StackName,StackStatus]' \
  --output table
```

関連する全スタックが `*_COMPLETE` であること。

---

## 付録: 関連CDKソースコード

writer Lambda のロジック: `aws-cdk-lib/core/lib/custom-resource-handlers/cross-region-ssm-writer-handler/index.ts`

デプロイ済みの writer Lambda をAWSから取得して中身確認したい場合:

```bash
URL=$(aws lambda get-function \
  --region us-east-1 --profile <profile> \
  --function-name <CertStack>-CustomCrossRegionExportW-<hash> \
  --query 'Code.Location' --output text)
curl -s "$URL" -o /tmp/writer.zip
unzip -o /tmp/writer.zip -d /tmp/writer/
cat /tmp/writer/index.js
```

これで writer の挙動変更に気付ける (CDK のマイナーバージョンで仕様が変わった場合等)。
