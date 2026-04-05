# Database Project

Minecraft Purpur サーバー向け MMO RPG プラグインで利用する、データ定義を管理するリポジトリです。

## 目的

- プラグイン実行に必要なデータ定義を、静的データと動的データに分離して管理する。
- 別プロジェクト（API）が本リポジトリを探索し、データ種別を判定して入力データとして取り込める構造を維持する。

## データ領域

### 1) file/（静的データ）

アイテム、クエスト、バフ、ルートテーブルなどのマスタデータを YAML で管理します。

- 主な配下:
	- `file/10.features.item/`（item系）
	- `file/20.features.class/`（class系）
	- `file/30.features.skill/`（skill系）
	- `file/40.features.mob/`（mob系 — enemy / boss / npc）
	- `file/70.shared.buff/`（buff系）
	- `file/80.shared.loot/`（loot系）
	- `file/85.shared.recipe/`（recipe系）
- スキーマ定義:
	- 各領域の `*.YAMLスキーマ定義.md`
- 命名規則（YAML）:
	- `schemaVersion-英数字のスネークケース.yml`
	- 例: `v1-healing_potion.yml`

### 2) sqlserver/（動的データ）

プレイヤーのレベル、職業、アカウント情報などを SQL Server テーブル定義として管理します。

- 主な配下:
	- `sqlserver/init.sql`（全DB共通の初期構築スクリプト）
	- `sqlserver/AstralRecord/`（ゲームデータDB）
		- `dbo.account/`
		- `dbo.user/`
		- `dbo.equipment_instance/`（装備個体の動的状態）
		- `dbo.equipment_instance_stat_roll/`（生成時の random.min / random.max）
		- `dbo.equipment_instance_enchant_pool/`（個体に紐づく enchant.pools）
	- `sqlserver/AstralRecordSnapshot/`（YAMLスナップショット管理DB）
		- `dbo.yaml_snapshot/`

#### DBの役割

| DB名                    | 役割                                      |
|:-----------------------|:----------------------------------------|
| `AstralRecord`         | プレイヤー・アカウント・装備個体の動的データを管理する                     |
| `AstralRecordSnapshot` | YAMLファイルのスナップショットを保持し、前回ロード時との差分検出に使用する |

## API 連携向け探索ガイド

別プロジェクト（API）は、以下のルールで本リポジトリを探索することを想定します。

1. ルート配下で `file/` と `sqlserver/` を識別する。
2. `file/` は静的データとして収集し、対象 YAML とスキーマ定義を対応付ける。
3. `sqlserver/` は動的データとして収集し、`init.sql` と各テーブル定義ドキュメントを入力にする。
4. 判定結果（静的/動的）を保持したうえで、API 側の取り込み処理に渡す。

## 共通定義

複数のリソース種別から参照される共有定義は `file/00.meta/` に集約しています。

| ファイル                          | 内容                                                                                                    |
|:------------------------------|:------------------------------------------------------------------------------------------------------|
| `file/00.meta/StatusType.md`  | プラグイン側（`io.github.maaasu.astralRecord.feature.status.model.StatusType`）のステータス名一覧。mob / class / buff / equipment など `status` フィールドを持つすべてのリソースはこちらを参照する。 |

> プラグイン側の定義に変更が入った場合は `file/00.meta/StatusType.md` のみを更新してください。各スキーマ定義の個別更新は不要です。

## 運用ルール

- `file/` を編集する場合は `.github/prompts/file.prompt.md` を参照する。
- `sqlserver/` を編集する場合は `.github/prompts/table.prompt.md` を参照する。
- 本リポジトリの構成・命名規則・運用ルールに改修が入った場合は、この README を更新する。
