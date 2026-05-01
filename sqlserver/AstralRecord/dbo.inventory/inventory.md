# dbo.inventory テーブル設計

アカウントごと・インベントリ種別ごとに 1 レコード持つインベントリ本体テーブルです。  
実際の中身は `dbo.inventory_entry` に保持し、本テーブルは「どのアカウントが、どの種別のインベントリを持っているか」と容量設定を管理します。  
インベントリ種別は DB マスタではなく、プラグイン側コードで管理する前提です。

---

## テーブル情報

| 項目 | 値 |
|:---|:---|
| スキーマ名 | `dbo` |
| テーブル名 | `inventory` |
| 完全修飾名 | `dbo.inventory` |
| 主キー | `inventory_id` |
| 外部キー | `dbo.account.uuid` |

---

## カラム設計

| カラム名 | データ型 | PK | NotNull | デフォルト | 説明 |
|:---|:---|:---:|:---:|:---:|:---|
| `inventory_id` | `UNIQUEIDENTIFIER` | ○ | ○ |  | インベントリ ID |
| `account_id` | `UNIQUEIDENTIFIER` |  | ○ |  | 所有アカウント UUID |
| `inventory_type` | `NVARCHAR(30)` |  | ○ |  | インベントリ種別コード。例: `NORMAL`, `CURRENCY`, `EQUIPMENT`, `RUNE` |
| `slot_capacity` | `INT` |  |  |  | 実際のスロット数。スロットレスの場合は `NULL` |
| `is_enabled` | `BIT` |  | ○ | `1` | 利用可能フラグ |
| `metadata_json` | `NVARCHAR(MAX)` |  |  |  | 将来的な拡張用メタデータ |
| `created_at` | `DATETIME2(3)` |  | ○ |  | レコード作成日時 |
| `updated_at` | `DATETIME2(3)` |  | ○ |  | レコード更新日時 |
| `created_by` | `UNIQUEIDENTIFIER` |  | ○ |  | 作成者 UUID |
| `updated_by` | `UNIQUEIDENTIFIER` |  | ○ |  | 更新者 UUID |
| `is_deleted` | `BIT` |  | ○ | `0` | 論理削除フラグ |

---

## 制約設計

| 制約名 | 種別 | 定義 |
|:---|:---|:---|
| `PK_inventory` | PK | `inventory_id` |
| `FK_inventory_account` | FK | `account_id -> dbo.account(uuid)` |
| `UQ_inventory_account_type` | UNIQUE | `account_id, inventory_type` |
| `CK_inventory_slot_capacity` | CHECK | `[slot_capacity] IS NULL OR [slot_capacity] >= 0` |
| `DF_inventory_is_enabled` | DEFAULT | `is_enabled = 1` |
| `DF_inventory_is_deleted` | DEFAULT | `is_deleted = 0` |

---

## インデックス設計

| インデックス名 | カラム | 種別 | 用途 |
|:---|:---|:---|:---|
| `PK_inventory` | `inventory_id` | CLUSTERED | 主キー検索 |
| `UQ_inventory_account_type` | `account_id`, `inventory_type` | UNIQUE | アカウントごとの種別一意制約 |
| `IX_inventory_account_id` | `account_id` | NONCLUSTERED | アカウント単位取得 |
| `IX_inventory_inventory_type` | `inventory_type` | NONCLUSTERED | 種別単位取得 |
| `IX_inventory_is_deleted` | `is_deleted` | NONCLUSTERED | 論理削除フィルタ |

---

## DDL

```sql
CREATE TABLE [dbo].[inventory] (
    [inventory_id]       UNIQUEIDENTIFIER  NOT NULL,
    [account_id]         UNIQUEIDENTIFIER  NOT NULL,
    [inventory_type]     NVARCHAR(30)      NOT NULL,
    [slot_capacity]      INT                   NULL,
    [is_enabled]         BIT               NOT NULL  CONSTRAINT [DF_inventory_is_enabled] DEFAULT (1),
    [metadata_json]      NVARCHAR(MAX)         NULL,
    [created_at]         DATETIME2(3)      NOT NULL,
    [updated_at]         DATETIME2(3)      NOT NULL,
    [created_by]         UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]         UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]         BIT               NOT NULL  CONSTRAINT [DF_inventory_is_deleted] DEFAULT (0),

    CONSTRAINT [PK_inventory] PRIMARY KEY CLUSTERED ([inventory_id]),
    CONSTRAINT [FK_inventory_account] FOREIGN KEY ([account_id])
        REFERENCES [dbo].[account] ([uuid])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_inventory_account_type] UNIQUE ([account_id], [inventory_type]),
    CONSTRAINT [CK_inventory_slot_capacity] CHECK ([slot_capacity] IS NULL OR [slot_capacity] >= 0)
);
GO

CREATE NONCLUSTERED INDEX [IX_inventory_account_id]
    ON [dbo].[inventory] ([account_id]);
GO

CREATE NONCLUSTERED INDEX [IX_inventory_inventory_type]
    ON [dbo].[inventory] ([inventory_type]);
GO

CREATE NONCLUSTERED INDEX [IX_inventory_is_deleted]
    ON [dbo].[inventory] ([is_deleted]);
GO
```

---

## 用途

| 用途 | 説明 |
|:---|:---|
| 種別ごとの枠管理 | `NORMAL` / `CURRENCY` / `EQUIPMENT` / `RUNE` を同一構造で管理できる |
| 将来の拡張 | `PET` や `QUEST_ITEM` などもプラグイン側コード定義の追加で利用できる |
| 容量差の吸収 | 種別の基本ルールとは別に、アカウントごとにスロット数を持てる |
