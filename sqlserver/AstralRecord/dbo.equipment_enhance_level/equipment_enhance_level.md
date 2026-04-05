# dbo.equipment_enhance_level テーブル定義

装備アイテムの強化レベルごとの設定を管理するテーブルです。  
`equipment[].enhance.levels[]` に対応し、各レベルの耐久ボーナス・レシピ・必要通貨・成功率・失敗時挙動を保持します。

---

## テーブル情報

| 項目       | 値                                    |
|:---------|:-------------------------------------|
| データベース名  | `AstralRecord`                       |
| スキーマ名    | `dbo`                                |
| テーブル名    | `equipment_enhance_level`            |
| 完全修飾名    | `dbo.equipment_enhance_level`        |
| 主キー      | `enhance_level_id`                   |
| 外部キー参照先  | `dbo.equipment_enhance.enhance_id`   |

---

## カラム定義

| カラム名                | データ型               | PK | NotNull | デフォルト値   | 説明                                                         |
|:------------------|:-------------------|:--:|:-------:|:--------:|:-----------------------------------------------------------|
| `enhance_level_id` | `UNIQUEIDENTIFIER` | ○  |    ○    |          | 強化レベルレコードの UUID                                            |
| `enhance_id`       | `UNIQUEIDENTIFIER` |    |    ○    |          | 対象強化設定の UUID（FK → `dbo.equipment_enhance.enhance_id`）     |
| `level`            | `INT`              |    |    ○    |          | 強化レベル（1 〜 `max_level`）                                     |
| `durability_bonus` | `INT`              |    |         |          | このレベルで加算される最大耐久値ボーナス                                       |
| `recipe_id`        | `NVARCHAR(100)`    |    |         |          | 強化レシピID（ref: `recipe:{id}`）。指定時は素材・通貨・成功率・失敗挙動の直接定義より優先    |
| `required_currency` | `INT`             |    |         |          | 強化に必要な通貨量。`recipe_id` 指定時は省略可                              |
| `success_rate`     | `DECIMAL(5,4)`     |    |         | `1.0000` | 強化成功率（`0.0000` 〜 `1.0000`）。`recipe_id` 指定時は省略可              |
| `fail_action`      | `NVARCHAR(10)`     |    |    ○    | `'NONE'` | 強化失敗時の挙動（`NONE` / `DOWNGRADE` / `DESTROY`）。`recipe_id` 指定時は省略可 |
| `created_at`       | `DATETIME2(3)`     |    |    ○    |          | レコード作成日時                                                   |
| `updated_at`       | `DATETIME2(3)`     |    |    ○    |          | レコード最終更新日時                                                 |
| `created_by`       | `UNIQUEIDENTIFIER` |    |    ○    |          | 作成者の UUID                                                  |
| `updated_by`       | `UNIQUEIDENTIFIER` |    |    ○    |          | 最終更新者の UUID                                                |
| `is_deleted`       | `BIT`              |    |    ○    |   `0`    | 論理削除フラグ                                                    |

---

## 制約定義

### 主キー制約

| 制約名                          | カラム               | 種別 |
|:-----------------------------|:----------------|:---|
| `PK_equipment_enhance_level` | `enhance_level_id` | PK |

### 外部キー制約

| 制約名                                     | カラム         | 参照先                                      | ON DELETE | ON UPDATE |
|:----------------------------------------|:----------|:-----------------------------------------|:----------|:----------|
| `FK_equipment_enhance_level_enhance`    | `enhance_id` | `dbo.equipment_enhance(enhance_id)` | NO ACTION | NO ACTION |

### UNIQUE 制約

| 制約名                                         | カラム                    | 説明                         |
|:--------------------------------------------|:-----------------------|:---------------------------|
| `UQ_equipment_enhance_level_enhance_level`  | `enhance_id`, `level`  | 同一強化設定内でレベルの重複を防ぐ          |

### CHECK 制約

| 制約名                                     | カラム           | 条件                                       | 説明                |
|:----------------------------------------|:------------|:-----------------------------------------|:------------------|
| `CK_equipment_enhance_level_fail_action` | `fail_action` | `IN ('NONE', 'DOWNGRADE', 'DESTROY')`  | 失敗時挙動の有効値を制限する    |

### デフォルト制約

| 制約名                                           | カラム            | 値         |
|:----------------------------------------------|:-------------|:----------|
| `DF_equipment_enhance_level_success_rate`     | `success_rate` | `1.0000`  |
| `DF_equipment_enhance_level_fail_action`      | `fail_action`  | `'NONE'`  |
| `DF_equipment_enhance_level_is_deleted`       | `is_deleted`   | `0`       |

---

## インデックス定義

| インデックス名                                    | カラム               | 種別             | 用途               |
|:--------------------------------------------|:----------------|:---------------|:-----------------|
| `PK_equipment_enhance_level`                | `enhance_level_id` | CLUSTERED（主キー） | 主キー検索            |
| `IX_equipment_enhance_level_enhance_id`     | `enhance_id`    | NONCLUSTERED   | 強化設定別レベル一覧取得     |

---

## DDL

```sql
CREATE TABLE [dbo].[equipment_enhance_level] (
    [enhance_level_id]   UNIQUEIDENTIFIER  NOT NULL,
    [enhance_id]         UNIQUEIDENTIFIER  NOT NULL,
    [level]              INT               NOT NULL,
    [durability_bonus]   INT                   NULL,
    [recipe_id]          NVARCHAR(100)         NULL,
    [required_currency]  INT                   NULL,
    [success_rate]       DECIMAL(5,4)          NULL  CONSTRAINT [DF_equipment_enhance_level_success_rate]  DEFAULT (1.0000),
    [fail_action]        NVARCHAR(10)      NOT NULL  CONSTRAINT [DF_equipment_enhance_level_fail_action]   DEFAULT ('NONE'),
    [created_at]         DATETIME2(3)      NOT NULL,
    [updated_at]         DATETIME2(3)      NOT NULL,
    [created_by]         UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]         UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]         BIT               NOT NULL  CONSTRAINT [DF_equipment_enhance_level_is_deleted]    DEFAULT (0),

    CONSTRAINT [PK_equipment_enhance_level] PRIMARY KEY CLUSTERED ([enhance_level_id]),
    CONSTRAINT [FK_equipment_enhance_level_enhance] FOREIGN KEY ([enhance_id])
        REFERENCES [dbo].[equipment_enhance] ([enhance_id])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_enhance_level_enhance_level] UNIQUE ([enhance_id], [level]),
    CONSTRAINT [CK_equipment_enhance_level_fail_action] CHECK ([fail_action] IN ('NONE', 'DOWNGRADE', 'DESTROY'))
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_enhance_level_enhance_id]
    ON [dbo].[equipment_enhance_level] ([enhance_id]);
GO
```

---

## 用途

| 用途                     | 説明                                                           |
|:---------------------|:-------------------------------------------------------------|
| 強化レベル管理              | 各強化レベルの耐久ボーナス・必要通貨・成功率・失敗時挙動をDBで管理する                        |
| ステータス上昇・素材の起点        | `enhance_level_id` を外部キーとして `equipment_enhance_level_stat` / `equipment_enhance_level_material` が参照する |
| 論理削除                 | `is_deleted = 1` で強化レベル定義を物理削除せず無効化する                       |

