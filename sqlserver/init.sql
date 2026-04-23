-- ============================================================
-- データベース初期構築スクリプト
-- 作成日  : 2026-03-08
-- 更新日  : 2026-04-19
--
-- このスクリプトは通常のクエリ実行で動作します（SQLCMDモード不要）。
--
-- [任意] 既存DBを作り直したい場合は、以下を必要に応じて実行してください。
--   USE [master];
--   ALTER DATABASE [AstralRecord] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--   DROP DATABASE [AstralRecord];
--   ALTER DATABASE [AstralRecordSnapshot] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--   DROP DATABASE [AstralRecordSnapshot];
-- ============================================================

USE [master];
GO

IF DB_ID(N'AstralRecord') IS NULL
BEGIN
    CREATE DATABASE [AstralRecord];
END
GO

USE [AstralRecord];
GO

-- ============================================================
-- 対象DB:
--   [AstralRecord]          : ゲームデータ（ユーザー・アカウント・装備動的データ）
--   [AstralRecordSnapshot]  : YAMLスナップショット管理
--
-- ============================================================
-- AstralRecord — 実行手順
--   dbo.user と dbo.account は互いに FK を参照し合う
--   循環参照のため、以下の手順で作成する。
--
--   STEP 1 : dbo.user を FK(account_id) なしで作成
--   STEP 2 : dbo.account を作成（FK → dbo.user 付き）
--   STEP 3 : dbo.user.account_id 用のインデックスを後付け
--            （FK は付与せず、整合性はアプリケーション層で保証）
--   STEP 4 : dbo.equipment 関連テーブルを FK 依存順に作成
--            (4-1) equipment_instance
--            → (4-2) equipment_instance_stat_roll
--            → (4-3) equipment_instance_enchant
--            → (4-4) equipment_instance_rune
--   STEP 5 : dbo.rune 関連テーブルを FK 依存順に作成
--            (5-1) rune_instance
--            → (5-2) rune_instance_stat_roll
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
    [account_id]       UNIQUEIDENTIFIER      NULL,  -- 初回 INSERT 時は NULL（FK は付与しない）
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
    [transcendence_name]              NVARCHAR(100)        NULL,
    [transcendence_enhance_max_level] INT                  NULL,
    [transcendence_enchant_max_slots] INT                  NULL,
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
    CONSTRAINT [CK_equipment_instance_transcendence_enhance_max_level] CHECK ([transcendence_enhance_max_level] IS NULL OR [transcendence_enhance_max_level] >= 0),
    CONSTRAINT [CK_equipment_instance_transcendence_enchant_max_slots] CHECK ([transcendence_enchant_max_slots] IS NULL OR [transcendence_enchant_max_slots] >= 0),
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

    CONSTRAINT [PK_equipment_instance_stat_roll] PRIMARY KEY CLUSTERED ([stat_roll_id]),
    CONSTRAINT [FK_equipment_instance_stat_roll_equipment_instance] FOREIGN KEY ([equipment_instance_id])
        REFERENCES [dbo].[equipment_instance] ([equipment_instance_id])
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_instance_stat_roll_instance_status] UNIQUE ([equipment_instance_id], [status], [sort_order])
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_stat_roll_equipment_instance_id]
    ON [dbo].[equipment_instance_stat_roll] ([equipment_instance_id]);
GO


-- ============================================================
-- [AstralRecord] STEP 4-3 : dbo.equipment_instance_enchant
-- ============================================================

CREATE TABLE [dbo].[equipment_instance_enchant] (
    [enchant_id]                  UNIQUEIDENTIFIER  NOT NULL,
    [equipment_instance_id]       UNIQUEIDENTIFIER  NOT NULL,
    [slot_index]                  INT               NOT NULL,
    [status]                      NVARCHAR(50)      NOT NULL,
    [type]                        NVARCHAR(20)      NOT NULL,
    [value]                       DECIMAL(18, 4)    NOT NULL,
    [created_at]                  DATETIME2(3)      NOT NULL,
    [updated_at]                  DATETIME2(3)      NOT NULL,
    [created_by]                  UNIQUEIDENTIFIER  NOT NULL,
    [updated_by]                  UNIQUEIDENTIFIER  NOT NULL,

    CONSTRAINT [PK_equipment_instance_enchant] PRIMARY KEY CLUSTERED ([enchant_id]),
    CONSTRAINT [FK_equipment_instance_enchant_equipment_instance] FOREIGN KEY ([equipment_instance_id])
        REFERENCES [dbo].[equipment_instance] ([equipment_instance_id])
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_instance_enchant_slot_index] UNIQUE ([equipment_instance_id], [slot_index])
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_enchant_equipment_instance_id]
    ON [dbo].[equipment_instance_enchant] ([equipment_instance_id]);
GO


-- ============================================================
-- [AstralRecord] STEP 4-4 : dbo.equipment_instance_rune
-- ============================================================

CREATE TABLE [dbo].[equipment_instance_rune] (
    [rune_id]                UNIQUEIDENTIFIER NOT NULL,
    [equipment_instance_id]  UNIQUEIDENTIFIER NOT NULL,
    [slot_index]             INT              NOT NULL,
    [rune_instance_id]       UNIQUEIDENTIFIER     NULL,
    [item_id]                NVARCHAR(100)    NOT NULL,
    [created_at]             DATETIME2(3)     NOT NULL,
    [updated_at]             DATETIME2(3)     NOT NULL,
    [created_by]             UNIQUEIDENTIFIER NOT NULL,
    [updated_by]             UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT [PK_equipment_instance_rune] PRIMARY KEY CLUSTERED ([rune_id]),
    CONSTRAINT [FK_equipment_instance_rune_equipment_instance] FOREIGN KEY ([equipment_instance_id])
        REFERENCES [dbo].[equipment_instance] ([equipment_instance_id])
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_equipment_instance_rune_slot_index] UNIQUE ([equipment_instance_id], [slot_index])
);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_rune_equipment_instance_id]
    ON [dbo].[equipment_instance_rune] ([equipment_instance_id]);
GO

CREATE NONCLUSTERED INDEX [IX_equipment_instance_rune_rune_instance_id]
    ON [dbo].[equipment_instance_rune] ([rune_instance_id]);
GO


-- ============================================================
-- [AstralRecord] STEP 5-1 : dbo.rune_instance（ルーン個体）
-- ============================================================

CREATE TABLE [dbo].[rune_instance] (
    [rune_instance_id] UNIQUEIDENTIFIER NOT NULL,
    [account_id]        UNIQUEIDENTIFIER NOT NULL,
    [item_id]           NVARCHAR(100)    NOT NULL,
    [created_at]        DATETIME2(3)     NOT NULL,
    [updated_at]        DATETIME2(3)     NOT NULL,
    [created_by]        UNIQUEIDENTIFIER NOT NULL,
    [updated_by]        UNIQUEIDENTIFIER NOT NULL,
    [is_deleted]        BIT              NOT NULL CONSTRAINT [DF_rune_instance_is_deleted] DEFAULT (0),

    CONSTRAINT [PK_rune_instance] PRIMARY KEY CLUSTERED ([rune_instance_id]),
    CONSTRAINT [FK_rune_instance_account] FOREIGN KEY ([account_id])
        REFERENCES [dbo].[account] ([uuid])
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE NONCLUSTERED INDEX [IX_rune_instance_account_id]
    ON [dbo].[rune_instance] ([account_id]);
GO

CREATE NONCLUSTERED INDEX [IX_rune_instance_item_id]
    ON [dbo].[rune_instance] ([item_id]);
GO

CREATE NONCLUSTERED INDEX [IX_rune_instance_is_deleted]
    ON [dbo].[rune_instance] ([is_deleted]);
GO


-- ============================================================
-- [AstralRecord] STEP 5-2 : dbo.rune_instance_stat_roll
-- ============================================================

CREATE TABLE [dbo].[rune_instance_stat_roll] (
    [stat_roll_id]       UNIQUEIDENTIFIER NOT NULL,
    [rune_instance_id]   UNIQUEIDENTIFIER NOT NULL,
    [status]             NVARCHAR(50)     NOT NULL,
    [type]               NVARCHAR(20)     NOT NULL,
    [random_value]       NVARCHAR(20)     NOT NULL,
    [sort_order]         INT              NOT NULL CONSTRAINT [DF_rune_instance_stat_roll_sort_order] DEFAULT (0),
    [created_at]         DATETIME2(3)     NOT NULL,
    [updated_at]         DATETIME2(3)     NOT NULL,
    [created_by]         UNIQUEIDENTIFIER NOT NULL,
    [updated_by]         UNIQUEIDENTIFIER NOT NULL,
    [is_deleted]         BIT              NOT NULL CONSTRAINT [DF_rune_instance_stat_roll_is_deleted] DEFAULT (0),

    CONSTRAINT [PK_rune_instance_stat_roll] PRIMARY KEY CLUSTERED ([stat_roll_id]),
    CONSTRAINT [FK_rune_instance_stat_roll_rune_instance] FOREIGN KEY ([rune_instance_id])
        REFERENCES [dbo].[rune_instance] ([rune_instance_id])
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT [UQ_rune_instance_stat_roll_instance_status] UNIQUE ([rune_instance_id], [status], [sort_order])
);
GO

CREATE NONCLUSTERED INDEX [IX_rune_instance_stat_roll_rune_instance_id]
    ON [dbo].[rune_instance_stat_roll] ([rune_instance_id]);
GO


-- ============================================================
-- [AstralRecordSnapshot] dbo.yaml_snapshot
-- ============================================================

USE [master];
GO

IF DB_ID(N'AstralRecordSnapshot') IS NULL
BEGIN
    CREATE DATABASE [AstralRecordSnapshot];
END
GO

USE [AstralRecordSnapshot];
GO

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

