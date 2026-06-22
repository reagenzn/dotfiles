---
name: cdk-ssm-snapshot-unlock
description: CDK v2 `crossRegionReferences: true` 構成で consumer stack の `cdk deploy` が `Failed to create ChangeSet ... Parameters: [ssm:...:<version>:<epoch>] last modified date does not match with the last modified date of the retrieved parameters` で失敗したときの解除手順。writer (CertStack 等) を `--exclusively` で先行 deploy した後や、`aws ssm put-parameter --overwrite` した後、SSM パラメータのタグを触った後に発生する。`put-parameter --overwrite` を何度試しても解消しない / `cdk deploy` が ChangeSet 作成で即 fail する / CloudFormation の stack template に `{{resolve:ssm:name:version:lastModified}}` の snapshot 付き参照が焼き付いている、といった症状が出たら必ずこのスキルを使う。"last modified date does not match" "SSM snapshot mismatch" "cross-region reference mismatch" "crossRegionReferences last modified" "resolve:ssm version pinned" といったキーワードを見た時点で、consumer stack を destroy せずにこのスキルで snapshot を外して復旧させる。
---

# cdk-ssm-snapshot-unlock

CDK v2 の `crossRegionReferences: true` で consumer stack template に焼き付いた SSM dynamic reference の **lastModified snapshot** を外して deploy を通すための単発手順。**stack の destroy/recreate は絶対にしない** (CloudFront distribution や Route53 record を巻き添えに破壊するため)。

## 症状 (このスキルを使う判断基準)

`cdk deploy <ConsumerStack>` が以下で必ず落ちる:

```
Failed to create ChangeSet cdk-deploy-change-set on <ConsumerStack>: FAILED,
Parameters: [ssm:/cdk/exports/<ConsumerStack>/<hash>:<version>:<epoch_ms>]
last modified date does not match with the last modified date of the retrieved parameters.
```

以下を試しても解消しない時点で、このスキルの出番:

- `aws ssm put-parameter --overwrite` で同値上書き → **無効**
- `aws ssm delete-parameter` → writer 側は復元するが CFn 内部 snapshot は変わらない → **無効**
- `rm -rf cdk.out` + `cdk deploy` → **無効** (CDK 側のキャッシュではなく CFn stack state が原因)

## 根本原因

CDK v2 の cross-region reference は、writer stack が SSM パラメータを書き、consumer stack がそれを `{{resolve:ssm:name}}` 形式で参照する。ところが consumer stack が一度 deploy されると、**persisted template に `{{resolve:ssm:name:version:lastModifiedEpochMs}}` の形で version + lastModified が焼き付けられる**。

以降 writer が SSM を書き換えるイベント (以下全て該当):

- writer stack の Phase 3 再 deploy (V2 リネーム完了時など)
- `aws ssm put-parameter --overwrite` による手動書き換え
- `aws ssm remove-tags-from-resource` / `add-tags-to-resource`
- SSM の delete + recreate

で lastModified が更新されると、次回 consumer deploy 時に CFn が ChangeSet validation で「persisted template の lastModified ≠ SSM 現値」を検知して reject する。**`put-parameter --overwrite` が効かない**のは、SSM 側を直しても CFn stack state 内の snapshot は不変だから。

## 復旧手順

### Step 1: エラーから snapshot suffix を抽出

`cdk deploy` のエラー出力の `Parameters: [ssm:...:<version>:<epoch_ms>]` 部分から `:<version>:<epoch_ms>` を控える。13 桁 epoch ms 形式。複数 SSM ref が listed されていたら全部控える。

### Step 2: 現 stack template を取得

```bash
aws cloudformation get-template \
  --region <consumer-region> --profile <profile> \
  --stack-name <ConsumerStack> \
  --output json > /tmp/stack-raw.json

jq '.TemplateBody' /tmp/stack-raw.json > /tmp/stack-template.json
```

### Step 3: snapshot suffix を strip

単一 ref ならエラーから読み取った値で exact 置換 (最も安全):

```bash
sed 's|:<version>:<lastModified>||g' /tmp/stack-template.json > /tmp/stack-template-fixed.json
```

複数 ref の場合は 13 桁 epoch ms の regex fallback:

```bash
sed -E 's|(resolve:ssm:[^"]+):[0-9]+:[0-9]{13}|\1|g' \
  /tmp/stack-template.json > /tmp/stack-template-fixed.json
```

確認 (snapshot が全て消えていること):

```bash
grep -oE '"[^"]*resolve:ssm[^"]*"' /tmp/stack-template-fixed.json | head -3
# 期待: `"{{resolve:ssm:/cdk/exports/<Stack>/<hash>}}"` (suffix なし)
grep -cE ':[0-9]+:[0-9]{13}[}]' /tmp/stack-template-fixed.json
# 期待: 0
```

### Step 4: `update-stack` で直接投入 (ChangeSet をバイパス)

```bash
aws cloudformation update-stack \
  --region <consumer-region> --profile <profile> \
  --stack-name <ConsumerStack> \
  --template-body file:///tmp/stack-template-fixed.json \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
```

`update-stack` は ChangeSet 作成の validation (lastModified check) を通らないため、そのまま適用される。差分は snapshot suffix だけで他のリソースに影響はない。

### Step 5: 完了待ち

```bash
aws cloudformation wait stack-update-complete \
  --region <consumer-region> --profile <profile> \
  --stack-name <ConsumerStack>

aws cloudformation describe-stacks \
  --region <consumer-region> --profile <profile> \
  --stack-name <ConsumerStack> \
  --query 'Stacks[0].StackStatus' --output text
# UPDATE_COMPLETE が出れば OK (通常 10 秒以内)
```

### Step 6: 通常の `cdk deploy` を再実行

```bash
rm -rf packages/infra/cdk.out   # CDK キャッシュもクリア推奨
ENVIRONMENT=<env> pnpm cdk deploy <ConsumerStack> --exclusively \
  --require-approval never --profile <profile>
```

今度は CFn stack state に snapshot がないので、ChangeSet 作成時に fresh lastModified が取得 + 新 snapshot で登録される。成功したらもう同じエラーは出ない (次に writer 側を単独 deploy するまでは)。

## 実例 (aix-concierge prd で実際に踏んだケース)

- Stack: `ForSalesPrdFrontendStack` (region `ap-northeast-1`, profile `prd_aq_aix_AA`)
- エラーの suffix: `:1:1776856803514`
- 復旧コマンド: `sed 's|:1:1776856803514||g' /tmp/stack-template.json > ...` → `update-stack` → 約 6 秒で `UPDATE_COMPLETE` → `cdk deploy` が通った

## 予防策

- writer stack (CertStack 等) を `--exclusively` で単独 deploy する場合は、**同じ作業セッション内で consumer stack も続けて deploy** する。CDK が自動で依存順 resolve してくれるので、依存関係で紐付いていれば一度に deploy されて snapshot も fresh に更新される。
- どうしても時間を空けて consumer deploy する必要がある場面では、**このスキルを deploy 前に先回りで適用**しておく。writer 側で `put-parameter --overwrite` や tag 操作をした覚えがあれば、それだけで必要条件は揃う。

## 注意

- `update-stack` は snapshot suffix を削るだけの実質 no-op update。他のリソースは一切変化しないので、本番運用中でも安全 (影響範囲は stack template metadata のみ)。
- `CAPABILITY_NAMED_IAM` は IAM resource に explicit logical ID を持つ stack で必須。迷ったら defensive に両方付ける。
- **consumer stack を `cdk destroy` してはいけない**。CloudFront distribution / Route53 record / S3 bucket / ECS service が消え、再作成に数十分〜数時間の停止が出る。このスキルの `update-stack` 経路が正解。
- エラーメッセージの `Parameters: [...]` 部分は stack Parameters ではなく **template 内の SSM dynamic reference**。混同しないこと (stack Parameters を `--parameters UsePreviousValue=false` で上書きしても解消しない)。
- 複数の SSM ref が同じ stack に存在する場合、regex fallback の `sed -E 's|(resolve:ssm:[^"]+):[0-9]+:[0-9]{13}|\1|g'` で全部一度に strip する方が抜け漏れがない。

## 関連スキル

- `cdk-domain-migration` — CDK でルートドメインを変える大物ワークフロー。Phase 3 完了後に consumer 再 deploy で本エラーを踏む想定 / 対処がドキュメント内に書かれているが、**単独で使いたい場合はこのスキルを呼ぶ方が確実**。
