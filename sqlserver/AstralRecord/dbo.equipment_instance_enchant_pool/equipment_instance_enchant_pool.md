# dbo.equipment_instance_enchant_pool テーブル定義

装備個体に紐づくエンチャントプール情報を管理するテーブルです。  
`equipment[].enchant.pools[]` に対応し、個体生成時点のプール構成を保持します。

---

## テーブル情報

| 項目      | 値                                              |
|:--------|:-----------------------------------------------|
| データベース名 | `AstralRecord`                                 |
| スキーマ名   | `dbo`                                          |
| テーブル名   | `equipment_instance_enchant_pool`              |
| 完全修飾名   | `dbo.equipment_instance_enchant_pool`          |
| 主キー     | `enchant_pool_id`                              |
| 外部キー参照先 | `dbo.equipment_instance.equipment_instance_id` |

---

## カラム定義

| カラム名                        | データ型               | PK | NotNull | デフォルト値 | 説明               |
|:----------------------------|:-------------------|:--:|:-------:|:------:|:-----------------|
| `enchant_pool_id`           | `UNIQUEIDENTIFIER` | ○  |    ○    |        | エンチャントプールレコードID  |
| `equipment_instance_id`     | `UNIQUEIDENTIFIER` |    |    ○    |        | 対象装備個体ID（FK）     |
| `pool_index`                | `INT`              |    |    ○    |        | YAML内プール順序（0始まり） |
| `recipe_id`                 | `NVARCHAR(100)`    |    |         |        | レシピ参照ID          |
| `required_material_item_id` | `NVARCHAR(100)`    |    |         |        | 必要素材 itemId      |
| `required_material_amount`  | `INT`              |    |         |  `1`   | 必要素材数            |
| `required_currency`         | `INT`              |    |    ○    |  `0`   | 必要通貨             |
| `created_at`                | `DATETIME2(3)`     |    |    ○    |        | レコード作成日時         |
| `updated_at`                | `DATETIME2(3)`     |    |    ○    |        | レコード最終更新日時       |
| `created_by`                | `UNIQUEIDENTIFIER` |    |    ○    |        | 作成者の UUID        |
| `updated_by`                | `UNIQUEIDENTIFIER` |    |    ○    |        | 最終更新者の UUID      |
| `is_deleted`                | `BIT`              |    |    ○    |  `0`   | 論理削除フラグ          |

---

## 制約定義

### 主キー制約

| 制約名                                  | カラム               | 種別 |
|:-------------------------------------|:------------------|:---|
| `PK_equipment_instance_enchant_pool` | `enchant_pool_id` | PK |

### 外部キー制約

| 制約名                                                     | カラム                     | 参照先                                             | ON DELETE | ON UPDATE |
|:--------------------------------------------------------|:------------------------|:------------------------------------------------|:----------|:----------|
| `FK_equipment_instance_enchant_pool_equipment_instance` | `equipment_instance_id` | `dbo.equipment_instance(equipment_instance_id)` | NO ACTION | NO ACTION |

### UNIQUE 制約

| 制約名                                                 | カラム                                   | 説明              |
|:----------------------------------------------------|:--------------------------------------|:----------------|
| `UQ_equipment_instance_enchant_pool_instance_index` | `equipment_instance_id`, `pool_index` | 同一個体でプール順序重複を防ぐ |

### デフォルト制約

| 制約名                                                           | カラム                        | 値   |
|:--------------------------------------------------------------|:---------------------------|:----|
| `DF_equipment_instance_enchant_pool_required_material_amount` | `required_material_amount` | `1` |
| `DF_equipment_instance_enchant_pool_required_currency`        | `required_currency`        | `0` |
| `DF_equipment_instance_enchant_pool_is_deleted`               | `is_deleted`               | `0` |

---

## インデックス定義

| インデックス名                                                    | カラム                     | 種別             | 用途               |
|:-----------------------------------------------------------|:------------------------|:---------------|:-----------------|
| `PK_equipment_instance_enchant_pool`                       | `enchant_pool_id`       | CLUSTERED（主キー） | 主キー検索            |
| `IX_equipment_instance_enchant_pool_equipment_instance_id` | `equipment_instance_id` | NONCLUSTERED   | 個体別エンチャントプール一覧取得 |

---

## DDL

```sql
CREATE TABLE [dbo].[equipment_instance_enchant_pool] (
    [enchant_pool_id]             UNIQUEIDENTIFIER  NOT NULL,
    [equipment_instance_id]       UNIQUEIDENTIFIER  NOT NULL,
    [pool_index]                  INT               NOT NULL,
    [recipe_id]                   NVARCHAR(100)         NULL,
    [required_material_item_id]   NVARCHAR(100)         NULL,
    [required_material_amount]    INT                   NULL  CONSTRAINT [DF_equipment_instance_enchant_pool_required_material_amount]  DEFAULT (1),
    [required_currency]           INT               NOT NULL  CONSTRAINT [DF_equipment_instance_enchant_pool_required_currency]         DEFAULT (0),
    [created_at]                  DATETIME2(3)      NOT NULL,
    [updated_at]                  DATETIME2(3)      NOT NULL,
    [created_by]                  UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]                  UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]                  BIT               NOT NULL  CONSTRAINT [DF_equipment_instance_enchant_pool_is_deleted]                DEFAULT (0),

    CONSTRAINT [PK_equipment_instance_enchant_pool] PRIMARY KEY CLUSTERED ([enchant_pool_id]),
    CONSTRAINT [FK_equipment_instance_enchant_pool_equipment_instance] FOREIGN KEY ([equipment_instance_id])
        REFERENCES [dbo].[equipment_instance] ([equipment_instance_id])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_instance_enchant_pool_instance_index] UNIQUE ([equipment_instance_id], [pool_index])
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_enchant_pool_equipment_instance_id]
    ON [dbo].[equipment_instance_enchant_pool] ([equipment_instance_id]);
GO
```

---

## 用途

| 用途 | 説明 |
|:-----|:-----|
| エンチャントプール保持 | 生成時点の `enchant.pools` を個体単位で保持する |
| 動的処理基盤 | 個体の強化素材/通貨要件の判定に利用する |
| 論理削除 | `is_deleted = 1` で物理削除せず無効化する |

---

## ソースコード参照

| 種別 | パス |
|:-----|:-----|
| Table | `TBD` |

