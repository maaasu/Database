`r`n補足: プロファイル分離（GAME/BUILDER）は親テーブル `dbo.inventory.inventory_profile` で管理します。`r`n蜷・う繝ｳ繝吶Φ繝医Μ縺ｮ荳ｭ霄ｫ繧剃ｿ晄戟縺吶ｋ繝・・繝悶Ν縺ｧ縺吶・ 
騾壼ｸｸ繧｢繧､繝・Β繝ｻ騾夊ｲｨ縺ｮ繧医≧縺ｪ繧ｹ繧ｿ繝・け蝙九い繧､繝・Β縺ｨ縲∬｣・ｙ繝ｻ繝ｫ繝ｼ繝ｳ繝ｻ蟆・擂縺ｮ繝壹ャ繝医・繧医≧縺ｪ繧､繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ蜿ら・蝙九い繧､繝・Β縺ｮ荳｡譁ｹ繧・1 繝・・繝悶Ν縺ｧ謇ｱ縺医ｋ繧医≧縺ｫ縺励※縺・∪縺吶・ 
縺ｩ縺ｮ繧､繝ｳ繝吶Φ繝医Μ遞ｮ蛻･縺ｫ螻槭☆繧九°縺ｮ蛻､螳壹・隕ｪ繝・・繝悶Ν `dbo.inventory.inventory_type` 縺ｨ繝励Λ繧ｰ繧､繝ｳ蛛ｴ繧ｳ繝ｼ繝峨〒陦後＞縺ｾ縺吶・

---

## 繝・・繝悶Ν諠・ｱ

| 鬆・岼 | 蛟､ |
|:---|:---|
| 繧ｹ繧ｭ繝ｼ繝槫錐 | `dbo` |
| 繝・・繝悶Ν蜷・| `inventory_entry` |
| 螳悟・菫ｮ鬟ｾ蜷・| `dbo.inventory_entry` |
| 荳ｻ繧ｭ繝ｼ | `inventory_entry_id` |
| 螟夜Κ繧ｭ繝ｼ | `dbo.inventory.inventory_id` |

---

## 繧ｫ繝ｩ繝險ｭ險・

| 繧ｫ繝ｩ繝蜷・| 繝・・繧ｿ蝙・| PK | NotNull | 繝・ヵ繧ｩ繝ｫ繝・| 隱ｬ譏・|
|:---|:---|:---:|:---:|:---:|:---|
| `inventory_entry_id` | `UNIQUEIDENTIFIER` | 笳・| 笳・|  | 繧､繝ｳ繝吶Φ繝医Μ繧ｨ繝ｳ繝医Μ ID |
| `inventory_id` | `UNIQUEIDENTIFIER` |  | 笳・|  | 謇螻槭う繝ｳ繝吶Φ繝医Μ ID |
| `slot_index` | `INT` |  |  |  | 繧ｹ繝ｭ繝・ヨ逡ｪ蜿ｷ縲ゅせ繝ｭ繝・ヨ繝ｬ繧ｹ縺ｮ蝣ｴ蜷医・ `NULL` |
| `item_category` | `NVARCHAR(30)` |  | 笳・|  | 繧｢繧､繝・Β繧ｫ繝・ざ繝ｪ縲ゆｾ・ `CONSUMABLE`, `MATERIAL`, `CURRENCY`, `EQUIPMENT`, `RUNE`, `PET` |
| `item_id` | `NVARCHAR(100)` |  |  |  | YAML 繝槭せ繧ｿ縺ｮ繧｢繧､繝・Β ID縲ゅせ繧ｿ繝・け蝙九〒菴ｿ逕ｨ |
| `instance_type` | `NVARCHAR(30)` |  |  |  | 繧､繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ蜿ら・遞ｮ蛻･縲ゆｾ・ `EQUIPMENT`, `RUNE`, `PET` |
| `instance_id` | `UNIQUEIDENTIFIER` |  |  |  | 繧､繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ蜿ら・蜈・ID |
| `quantity` | `BIGINT` |  | 笳・| `1` | 謇謖∵焚縲ゅせ繧ｿ繝・け蝙九・ 1 莉･荳翫√う繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ蜿ら・蝙九・騾壼ｸｸ 1 |
| `metadata_json` | `NVARCHAR(MAX)` |  |  |  | 蟆・擂逧・↑諡｡蠑ｵ逕ｨ繝｡繧ｿ繝・・繧ｿ |
| `created_at` | `DATETIME2(3)` |  | 笳・|  | 繝ｬ繧ｳ繝ｼ繝我ｽ懈・譌･譎・|
| `updated_at` | `DATETIME2(3)` |  | 笳・|  | 繝ｬ繧ｳ繝ｼ繝画峩譁ｰ譌･譎・|
| `created_by` | `UNIQUEIDENTIFIER` |  | 笳・|  | 菴懈・閠・UUID |
| `updated_by` | `UNIQUEIDENTIFIER` |  | 笳・|  | 譖ｴ譁ｰ閠・UUID |
| `is_deleted` | `BIT` |  | 笳・| `0` | 隲也炊蜑企勁繝輔Λ繧ｰ |

---

## 蛻ｶ邏・ｨｭ險・

| 蛻ｶ邏・錐 | 遞ｮ蛻･ | 螳夂ｾｩ |
|:---|:---|:---|
| `PK_inventory_entry` | PK | `inventory_entry_id` |
| `FK_inventory_entry_inventory` | FK | `inventory_id -> dbo.inventory(inventory_id)` |
| `CK_inventory_entry_slot_index` | CHECK | `[slot_index] IS NULL OR [slot_index] >= 0` |
| `CK_inventory_entry_quantity` | CHECK | `[quantity] >= 1` |
| `CK_inventory_entry_payload` | CHECK | `([item_id] IS NOT NULL AND [instance_type] IS NULL AND [instance_id] IS NULL) OR ([item_id] IS NULL AND [instance_type] IS NOT NULL AND [instance_id] IS NOT NULL)` |
| `DF_inventory_entry_quantity` | DEFAULT | `quantity = 1` |
| `DF_inventory_entry_is_deleted` | DEFAULT | `is_deleted = 0` |

### 險ｭ險域э蝗ｳ

| 鬆・岼 | 隱ｬ譏・|
|:---|:---|
| 繧ｹ繧ｿ繝・け蝙・| `item_id` 縺ｨ `quantity` 繧剃ｽｿ逕ｨ縲る壼ｸｸ繧､繝ｳ繝吶Φ繝医Μ繧・夊ｲｨ蜷代￠ |
| 繧､繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ蜿ら・蝙・| `instance_type` 縺ｨ `instance_id` 繧剃ｽｿ逕ｨ縲り｣・ｙ繝ｻ繝ｫ繝ｼ繝ｳ繝ｻ繝壹ャ繝亥髄縺・|
| FK 繧貞ｼｵ繧峨↑縺・炊逕ｱ | 蟆・擂 `PET` 縺ｪ縺ｩ縺ｮ譁ｰ繧､繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ繝・・繝悶Ν繧定ｿｽ蜉縺励※繧ゅ∵悽繝・・繝悶Ν縺ｮ繧ｹ繧ｭ繝ｼ繝槫､画峩繧帝∩縺代ｋ縺溘ａ |

---

## 繧､繝ｳ繝・ャ繧ｯ繧ｹ險ｭ險・

| 繧､繝ｳ繝・ャ繧ｯ繧ｹ蜷・| 繧ｫ繝ｩ繝 | 遞ｮ蛻･ | 逕ｨ騾・|
|:---|:---|:---|:---|
| `PK_inventory_entry` | `inventory_entry_id` | CLUSTERED | 荳ｻ繧ｭ繝ｼ讀懃ｴ｢ |
| `IX_inventory_entry_inventory_id` | `inventory_id` | NONCLUSTERED | 繧､繝ｳ繝吶Φ繝医Μ蜊倅ｽ榊叙蠕・|
| `UX_inventory_entry_inventory_slot` | `inventory_id`, `slot_index` | UNIQUE FILTERED | 繧ｹ繝ｭ繝・ヨ驥崎､・亟豁｢ |
| `UX_inventory_entry_inventory_item` | `inventory_id`, `item_id` | UNIQUE FILTERED | 繧ｹ繝ｭ繝・ヨ繝ｬ繧ｹ縺ｪ繧ｹ繧ｿ繝・け蝙矩㍾隍・亟豁｢ |
| `IX_inventory_entry_instance` | `instance_type`, `instance_id` | NONCLUSTERED | 繧､繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ騾・ｼ輔″ |
| `IX_inventory_entry_is_deleted` | `is_deleted` | NONCLUSTERED | 隲也炊蜑企勁繝輔ぅ繝ｫ繧ｿ |

---

## DDL

```sql
CREATE TABLE [dbo].[inventory_entry] (
    [inventory_entry_id]    UNIQUEIDENTIFIER  NOT NULL,
    [inventory_id]          UNIQUEIDENTIFIER  NOT NULL,
    [slot_index]            INT                   NULL,
    [item_category]         NVARCHAR(30)      NOT NULL,
    [item_id]               NVARCHAR(100)         NULL,
    [instance_type]         NVARCHAR(30)          NULL,
    [instance_id]           UNIQUEIDENTIFIER      NULL,
    [quantity]              BIGINT            NOT NULL  CONSTRAINT [DF_inventory_entry_quantity] DEFAULT (1),
    [metadata_json]         NVARCHAR(MAX)         NULL,
    [created_at]            DATETIME2(3)      NOT NULL,
    [updated_at]            DATETIME2(3)      NOT NULL,
    [created_by]            UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]            UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]            BIT               NOT NULL  CONSTRAINT [DF_inventory_entry_is_deleted] DEFAULT (0),

    CONSTRAINT [PK_inventory_entry] PRIMARY KEY CLUSTERED ([inventory_entry_id]),
    CONSTRAINT [FK_inventory_entry_inventory] FOREIGN KEY ([inventory_id])
        REFERENCES [dbo].[inventory] ([inventory_id])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [CK_inventory_entry_slot_index] CHECK ([slot_index] IS NULL OR [slot_index] >= 0),
    CONSTRAINT [CK_inventory_entry_quantity] CHECK ([quantity] >= 1),
    CONSTRAINT [CK_inventory_entry_payload] CHECK (
        ([item_id] IS NOT NULL AND [instance_type] IS NULL AND [instance_id] IS NULL)
        OR ([item_id] IS NULL AND [instance_type] IS NOT NULL AND [instance_id] IS NOT NULL)
    )
);
GO

CREATE NONCLUSTERED INDEX [IX_inventory_entry_inventory_id]
    ON [dbo].[inventory_entry] ([inventory_id]);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_inventory_entry_inventory_slot]
    ON [dbo].[inventory_entry] ([inventory_id], [slot_index])
    WHERE [slot_index] IS NOT NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_inventory_entry_inventory_item]
    ON [dbo].[inventory_entry] ([inventory_id], [item_id])
    WHERE [slot_index] IS NULL
      AND [item_id] IS NOT NULL
      AND [is_deleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_inventory_entry_instance]
    ON [dbo].[inventory_entry] ([instance_type], [instance_id]);
GO

CREATE NONCLUSTERED INDEX [IX_inventory_entry_is_deleted]
    ON [dbo].[inventory_entry] ([is_deleted]);
GO
```

---

## 逕ｨ騾・

| 逕ｨ騾・| 隱ｬ譏・|
|:---|:---|
| 騾壼ｸｸ繧､繝ｳ繝吶Φ繝医Μ | `slot_index` 縺ｨ `item_id` 縺ｧ騾壼ｸｸ繧｢繧､繝・Β繧堤ｮ｡逅・|
| 騾夊ｲｨ繧､繝ｳ繝吶Φ繝医Μ | `slot_index = NULL`縲～item_id` + `quantity` 縺ｧ荳企剞縺ｪ縺礼ｮ｡逅・|
| 陬・ｙ繧､繝ｳ繝吶Φ繝医Μ | `instance_type = 'EQUIPMENT'` 縺ｨ `instance_id` 縺ｧ陬・ｙ螳滉ｽ薙ｒ邂｡逅・|
| 繝ｫ繝ｼ繝ｳ繧､繝ｳ繝吶Φ繝医Μ | `instance_type = 'RUNE'` 縺ｨ `instance_id` 縺ｧ繝ｫ繝ｼ繝ｳ螳滉ｽ薙ｒ邂｡逅・|
| 蟆・擂縺ｮ繝壹ャ繝郁ｿｽ蜉 | `instance_type = 'PET'` 繧定ｿｽ蜉縺吶ｌ縺ｰ蜷後§讒矩縺ｧ謇ｱ縺医ｋ |

