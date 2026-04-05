# dbo.equipment_instance_stat_roll テーブル定義

装備生成時に決定されたステータス乱数レンジを管理するテーブルです。  
`equipment[].stats[].random[].min / max` に対応し、個体ごとの差分を保持します。

---

## テーブル情報

| 項目      | 値                                              |
|:--------|:-----------------------------------------------|
| データベース名 | `AstralRecord`                                 |
| スキーマ名   | `dbo`                                          |
| テーブル名   | `equipment_instance_stat_roll`                 |
| 完全修飾名   | `dbo.equipment_instance_stat_roll`             |
| 主キー     | `stat_roll_id`                                 |
| 外部キー参照先 | `dbo.equipment_instance.equipment_instance_id` |

---

## カラム定義

| カラム名                    | データ型               | PK | NotNull | デフォルト値 | 説明            |
|:------------------------|:-------------------|:--:|:-------:|:------:|:--------------|
| `stat_roll_id`          | `UNIQUEIDENTIFIER` | ○  |    ○    |        | ステータス乱数レコードID |
| `equipment_instance_id` | `UNIQUEIDENTIFIER` |    |    ○    |        | 対象装備個体ID（FK）  |
| `status`                | `NVARCHAR(50)`     |    |    ○    |        | 対象ステータス       |
| `random_min`            | `NVARCHAR(20)`     |    |    ○    |        | YAML由来の乱数最小値  |
| `random_max`            | `NVARCHAR(20)`     |    |    ○    |        | YAML由来の乱数最大値  |
| `sort_order`            | `INT`              |    |    ○    |  `0`   | 同一装備内の順序      |
| `created_at`            | `DATETIME2(3)`     |    |    ○    |        | レコード作成日時      |
| `updated_at`            | `DATETIME2(3)`     |    |    ○    |        | レコード最終更新日時    |
| `created_by`            | `UNIQUEIDENTIFIER` |    |    ○    |        | 作成者の UUID     |
| `updated_by`            | `UNIQUEIDENTIFIER` |    |    ○    |        | 最終更新者の UUID   |
| `is_deleted`            | `BIT`              |    |    ○    |  `0`   | 論理削除フラグ       |

---

## 制約定義

### 主キー制約

| 制約名                               | カラム            | 種別 |
|:----------------------------------|:---------------|:---|
| `PK_equipment_instance_stat_roll` | `stat_roll_id` | PK |

### 外部キー制約

| 制約名                                                  | カラム                     | 参照先                                             | ON DELETE | ON UPDATE |
|:-----------------------------------------------------|:------------------------|:------------------------------------------------|:----------|:----------|
| `FK_equipment_instance_stat_roll_equipment_instance` | `equipment_instance_id` | `dbo.equipment_instance(equipment_instance_id)` | NO ACTION | NO ACTION |

### UNIQUE 制約

| 制約名                                               | カラム                                             | 説明           |
|:--------------------------------------------------|:------------------------------------------------|:-------------|
| `UQ_equipment_instance_stat_roll_instance_status` | `equipment_instance_id`, `status`, `sort_order` | 同一個体の重複定義を防ぐ |

### デフォルト制約

| 制約名                                          | カラム          | 値   |
|:---------------------------------------------|:-------------|:----|
| `DF_equipment_instance_stat_roll_sort_order` | `sort_order` | `0` |
| `DF_equipment_instance_stat_roll_is_deleted` | `is_deleted` | `0` |

---

## インデックス定義

| インデックス名                                                 | カラム                     | 種別             | 用途             |
|:--------------------------------------------------------|:------------------------|:---------------|:---------------|
| `PK_equipment_instance_stat_roll`                       | `stat_roll_id`          | CLUSTERED（主キー） | 主キー検索          |
| `IX_equipment_instance_stat_roll_equipment_instance_id` | `equipment_instance_id` | NONCLUSTERED   | 個体別ステータス乱数一覧取得 |

---

## DDL

```sql
CREATE TABLE [dbo].[equipment_instance_stat_roll] (
    [stat_roll_id]            UNIQUEIDENTIFIER  NOT NULL,
    [equipment_instance_id]   UNIQUEIDENTIFIER  NOT NULL,
    [status]                  NVARCHAR(50)      NOT NULL,
    [random_min]              NVARCHAR(20)      NOT NULL,
    [random_max]              NVARCHAR(20)      NOT NULL,
    [sort_order]              INT               NOT NULL  CONSTRAINT [DF_equipment_instance_stat_roll_sort_order]  DEFAULT (0),
    [created_at]              DATETIME2(3)      NOT NULL,
    [updated_at]              DATETIME2(3)      NOT NULL,
    [created_by]              UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]              UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]              BIT               NOT NULL  CONSTRAINT [DF_equipment_instance_stat_roll_is_deleted]  DEFAULT (0),

    CONSTRAINT [PK_equipment_instance_stat_roll] PRIMARY KEY CLUSTERED ([stat_roll_id]),
    CONSTRAINT [FK_equipment_instance_stat_roll_equipment_instance] FOREIGN KEY ([equipment_instance_id])
        REFERENCES [dbo].[equipment_instance] ([equipment_instance_id])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_instance_stat_roll_instance_status] UNIQUE ([equipment_instance_id], [status], [sort_order])
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_stat_roll_equipment_instance_id]
    ON [dbo].[equipment_instance_stat_roll] ([equipment_instance_id]);
GO
```

---

## 用途

| 用途      | 説明                                           |
|:--------|:---------------------------------------------|
| 乱数レンジ保持 | 装備生成時点の `random.min / random.max` を個体単位で保持する |
| 個体差再現   | 後続処理で同じ個体状態を再現・追跡できる                         |
| 論理削除    | `is_deleted = 1` で物理削除せず無効化する                |

---

## ソースコード参照

| 種別    | パス    |
|:------|:------|
| Table | `TBD` |

