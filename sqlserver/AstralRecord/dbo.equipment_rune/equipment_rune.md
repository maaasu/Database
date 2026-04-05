# dbo.equipment_rune テーブル定義

装備アイテムのルーンスロットシステム設定を管理するテーブルです。  
`equipment[].rune` に対応し、最大スロット数（固定値またはランダム範囲）を保持します。1装備につき1レコードが対応します。

---

## テーブル情報

| 項目       | 値                              |
|:---------|:-------------------------------|
| データベース名  | `AstralRecord`                 |
| スキーマ名    | `dbo`                          |
| テーブル名    | `equipment_rune`               |
| 完全修飾名    | `dbo.equipment_rune`           |
| 主キー      | `rune_id`                      |
| 外部キー参照先  | `dbo.equipment.equipment_id`   |

---

## カラム定義

| カラム名           | データ型               | PK | NotNull | デフォルト値 | 説明                                                        |
|:--------------|:-------------------|:--:|:-------:|:------:|:----------------------------------------------------------|
| `rune_id`     | `UNIQUEIDENTIFIER` | ○  |    ○    |        | ルーン設定レコードの UUID                                           |
| `equipment_id` | `UNIQUEIDENTIFIER` |    |    ○    |        | 対象装備の UUID（FK → `dbo.equipment.equipment_id`）           |
| `max_slots`   | `INT`              |    |         |        | 装着できる最大ルーン数（固定値）。`NULL` の場合はランダム（`random_min` / `random_max` を使用） |
| `random_min`  | `INT`              |    |         |        | スロット数ランダム決定の最小値。`max_slots` が `NULL` の場合に使用             |
| `random_max`  | `INT`              |    |         |        | スロット数ランダム決定の最大値。`max_slots` が `NULL` の場合に使用             |
| `created_at`  | `DATETIME2(3)`     |    |    ○    |        | レコード作成日時                                                  |
| `updated_at`  | `DATETIME2(3)`     |    |    ○    |        | レコード最終更新日時                                                |
| `created_by`  | `UNIQUEIDENTIFIER` |    |    ○    |        | 作成者の UUID                                                 |
| `updated_by`  | `UNIQUEIDENTIFIER` |    |    ○    |        | 最終更新者の UUID                                               |
| `is_deleted`  | `BIT`              |    |    ○    |  `0`   | 論理削除フラグ                                                   |

---

## 制約定義

### 主キー制約

| 制約名                   | カラム      | 種別 |
|:-----------------------|:---------|:---|
| `PK_equipment_rune`   | `rune_id` | PK |

### 外部キー制約

| 制約名                              | カラム           | 参照先                          | ON DELETE | ON UPDATE |
|:--------------------------------|:-------------|:-----------------------------|:----------|:----------|
| `FK_equipment_rune_equipment`   | `equipment_id` | `dbo.equipment(equipment_id)` | NO ACTION | NO ACTION |

### UNIQUE 制約

| 制約名                                   | カラム           | 説明                      |
|:--------------------------------------|:-------------|:------------------------|
| `UQ_equipment_rune_equipment_id`      | `equipment_id` | 1装備につき1ルーン設定を保証する       |

### デフォルト制約

| 制約名                              | カラム         | 値   |
|:---------------------------------|:------------|:----|
| `DF_equipment_rune_is_deleted`   | `is_deleted` | `0` |

---

## インデックス定義

| インデックス名                          | カラム           | 種別             | 用途              |
|:---------------------------------|:-------------|:---------------|:----------------|
| `PK_equipment_rune`              | `rune_id`    | CLUSTERED（主キー） | 主キー検索           |
| `IX_equipment_rune_equipment_id` | `equipment_id` | NONCLUSTERED | 装備別ルーン設定取得      |

---

## DDL

```sql
CREATE TABLE [dbo].[equipment_rune] (
    [rune_id]       UNIQUEIDENTIFIER  NOT NULL,
    [equipment_id]  UNIQUEIDENTIFIER  NOT NULL,
    [max_slots]     INT                   NULL,  -- NULL の場合は random_min / random_max を使用
    [random_min]    INT                   NULL,
    [random_max]    INT                   NULL,
    [created_at]    DATETIME2(3)      NOT NULL,
    [updated_at]    DATETIME2(3)      NOT NULL,
    [created_by]    UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]    UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]    BIT               NOT NULL  CONSTRAINT [DF_equipment_rune_is_deleted]  DEFAULT (0),

    CONSTRAINT [PK_equipment_rune] PRIMARY KEY CLUSTERED ([rune_id]),
    CONSTRAINT [FK_equipment_rune_equipment] FOREIGN KEY ([equipment_id])
        REFERENCES [dbo].[equipment] ([equipment_id])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_rune_equipment_id] UNIQUE ([equipment_id])
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_rune_equipment_id]
    ON [dbo].[equipment_rune] ([equipment_id]);
GO
```

---

## 用途

| 用途                | 説明                                                         |
|:---------------|:-----------------------------------------------------------|
| ルーンスロット管理       | 装備に装着できるルーン数（固定またはランダム）をDBで管理する                           |
| 許可ルーンの起点        | `rune_id` を外部キーとして `equipment_rune_allowed` が参照する          |
| 論理削除           | `is_deleted = 1` でルーン設定を物理削除せず無効化する                        |

