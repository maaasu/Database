-- ============================================================
-- データベース初期構築スクリプト
-- 作成日  : 2026-03-08
-- 更新日  : 2026-04-05
--
-- 対象DB:
++   [AstralRecord]          : ゲームデータ（ユーザー・アカウント・装備動的データ）
--   [AstralRecordSnapshot]  : YAMLスナップショット管理
--
-- ============================================================
-- AstralRecord — 実行手順
--   dbo.user と dbo.account は互いに FK を参照し合う
--   循環参照のため、以下の手順で作成する。
--
--   STEP 1 : dbo.user を FK(account_id) なしで作成
--   STEP 2 : dbo.account を作成（FK → dbo.user 付き）
--   STEP 3 : ALTER TABLE で dbo.user に FK(account_id) を後付け
--   STEP 4 : dbo.equipment 関連テーブルを FK 依存順に作成
--            (4-1) equipment_instance
--            → (4-2) equipment_instance_stat_roll
--            → (4-3) equipment_instance_enchant_pool
-- ============================================================


-- ============================================================
-- [AstralRecord] STEP 1 : dbo.user（FK: account_id を除いて作成）
-- ============================================================

CREATE TABLE [dbo].[user] (
    [uuid]             UNIQUEIDENTIFIER  NOT NULL,
    [mcid]             NVARCHAR(20)      NOT NULL,
    [join_date]        DATETIME2(3)      NOT NULL,
    [last_join_date]   DATETIME2(3)      NOT NULL,
    [global_ip]        NVARCHAR(45)      NOT NULL,
    [account_id]       UNIQUEIDENTIFIER      NULL,  -- STEP 3 で NOT NULL 化・FK 付与
    [ban_indefinite]   BIT               NOT NULL  CONSTRAINT [DF_user_ban_indefinite]  DEFAULT (0),
    [ban_date]         DATETIME2(0)          NULL,
    [kick_ip]          BIT               NOT NULL  CONSTRAINT [DF_user_kick_ip]          DEFAULT (1),
    [permission]       INT               NOT NULL  CONSTRAINT [DF_user_permission]        DEFAULT (0),
    [created_at]       DATETIME2(3)      NOT NULL,
    [updated_at]       DATETIME2(3)      NOT NULL,
    [created_by]       UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]       UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]       BIT               NOT NULL  CONSTRAINT [DF_user_is_deleted]       DEFAULT (0),

    CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED ([uuid])
);
GO

CREATE NONCLUSTERED INDEX [IX_user_uuid]
    ON [dbo].[user] ([uuid]);
GO

CREATE NONCLUSTERED INDEX [IX_user_global_ip]
    ON [dbo].[user] ([global_ip]);
GO

-- ============================================================
-- [AstralRecord] STEP 2 : dbo.account（FK → dbo.user 付きで作成）
-- ============================================================

CREATE TABLE [dbo].[account] (
    [uuid]           UNIQUEIDENTIFIER  NOT NULL,
    [user_id]        UNIQUEIDENTIFIER  NOT NULL,
    [account_name]   NVARCHAR(50)      NOT NULL,
    [slot_index]     INT               NOT NULL,
    [is_active]      BIT               NOT NULL  CONSTRAINT [DF_account_is_active]   DEFAULT (0),
    [mode]           TINYINT           NOT NULL  CONSTRAINT [DF_account_mode]         DEFAULT (0),
    [created_at]     DATETIME2(3)      NOT NULL,
    [updated_at]     DATETIME2(3)      NOT NULL,
    [created_by]     UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]     UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]     BIT               NOT NULL  CONSTRAINT [DF_account_is_deleted]  DEFAULT (0),

    CONSTRAINT [PK_account] PRIMARY KEY CLUSTERED ([uuid]),
    CONSTRAINT [FK_account_user] FOREIGN KEY ([user_id])
        REFERENCES [dbo].[user] ([uuid])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_account_user_slot] UNIQUE ([user_id], [slot_index]),
    CONSTRAINT [CK_account_mode] CHECK ([mode] IN (0, 1, 2))
);
GO

CREATE NONCLUSTERED INDEX [IX_account_user_id]
    ON [dbo].[account] ([user_id]);
GO

CREATE NONCLUSTERED INDEX [IX_account_is_deleted]
    ON [dbo].[account] ([is_deleted]);
GO


-- ============================================================
-- [AstralRecord] STEP 3 : dbo.user に IX(account_id) を後付け
--   dbo.account が存在するため、ここで安全に追加できる
--   account_id は初回 INSERT 時 NULL を許容するため NULL 可のまま
-- ============================================================

CREATE NONCLUSTERED INDEX [IX_user_account_id]
    ON [dbo].[user] ([account_id]);
GO



-- ============================================================
-- [AstralRecord] STEP 4-1 : dbo.equipment_instance（装備個体）
-- ============================================================

CREATE TABLE [dbo].[equipment_instance] (
    [equipment_instance_id]  UNIQUEIDENTIFIER  NOT NULL,
    [account_id]             UNIQUEIDENTIFIER  NOT NULL,
    [item_id]                NVARCHAR(100)     NOT NULL,
    [enhance_level]          INT               NOT NULL  CONSTRAINT [DF_equipment_instance_enhance_level]      DEFAULT (0),
    [rune_max_slots]         INT               NOT NULL  CONSTRAINT [DF_equipment_instance_rune_max_slots]     DEFAULT (0),
    [transcendence_rank]     INT               NOT NULL  CONSTRAINT [DF_equipment_instance_transcendence_rank] DEFAULT (0),
    [durability_max]         INT                   NULL,
    [durability_value]       INT                   NULL,
    [created_at]             DATETIME2(3)      NOT NULL,
    [updated_at]             DATETIME2(3)      NOT NULL,
    [created_by]             UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]             UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]             BIT               NOT NULL  CONSTRAINT [DF_equipment_instance_is_deleted]         DEFAULT (0),

    CONSTRAINT [PK_equipment_instance] PRIMARY KEY CLUSTERED ([equipment_instance_id]),
    CONSTRAINT [FK_equipment_instance_account] FOREIGN KEY ([account_id])
        REFERENCES [dbo].[account] ([uuid])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT [CK_equipment_instance_enhance_level] CHECK ([enhance_level] >= 0),
    CONSTRAINT [CK_equipment_instance_rune_max_slots] CHECK ([rune_max_slots] >= 0),
    CONSTRAINT [CK_equipment_instance_transcendence_rank] CHECK ([transcendence_rank] >= 0),
    CONSTRAINT [CK_equipment_instance_durability_pair] CHECK (
        ([durability_max] IS NULL AND [durability_value] IS NULL)
        OR ([durability_max] IS NOT NULL AND [durability_value] IS NOT NULL)
    ),
    CONSTRAINT [CK_equipment_instance_durability_range] CHECK (
        [durability_max] IS NULL
        OR ([durability_max] > 0 AND [durability_value] BETWEEN 0 AND [durability_max])
    )
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_account_id]
    ON [dbo].[equipment_instance] ([account_id]);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_item_id]
    ON [dbo].[equipment_instance] ([item_id]);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_is_deleted]
    ON [dbo].[equipment_instance] ([is_deleted]);
GO


-- ============================================================
-- [AstralRecord] STEP 4-2 : dbo.equipment_instance_stat_roll
-- ============================================================

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


-- ============================================================
-- [AstralRecord] STEP 4-3 : dbo.equipment_instance_enchant_pool
-- ============================================================

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


-- ============================================================
-- [AstralRecordSnapshot] dbo.yaml_snapshot
-- ============================================================

CREATE TABLE [dbo].[yaml_snapshot] (
    [snapshot_id]    UNIQUEIDENTIFIER  NOT NULL,
    [file_path]      NVARCHAR(500)     NOT NULL,
    [file_hash]      NVARCHAR(64)      NOT NULL,
    [content_json]   NVARCHAR(MAX)     NOT NULL,
    [created_at]     DATETIME2(3)      NOT NULL,
    [updated_at]     DATETIME2(3)      NOT NULL,
    [created_by]     UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]     UNIQUEIDENTIFIER  NOT NULL,
    [is_deleted]     BIT               NOT NULL  CONSTRAINT [DF_yaml_snapshot_is_deleted]  DEFAULT (0),

    CONSTRAINT [PK_yaml_snapshot] PRIMARY KEY CLUSTERED ([snapshot_id]),
    CONSTRAINT [UQ_yaml_snapshot_file_path] UNIQUE ([file_path])
);
GO

CREATE NONCLUSTERED INDEX [IX_yaml_snapshot_file_path]
    ON [dbo].[yaml_snapshot] ([file_path]);
GO

