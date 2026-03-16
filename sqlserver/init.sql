-- ============================================================
-- AstralRecord — データベース初期構築スクリプト
-- 作成日  : 2026-03-08
-- 説明    : dbo.user と dbo.account は互いに FK を参照し合う
--           循環参照のため、以下の手順で作成する。
--
--   STEP 1 : dbo.user を FK(account_id) なしで作成
--   STEP 2 : dbo.account を作成（FK → dbo.user 付き）
--   STEP 3 : ALTER TABLE で dbo.user に FK(account_id) を後付け
-- ============================================================


-- ============================================================
-- STEP 1 : dbo.user（FK: account_id を除いて作成）
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
-- STEP 2 : dbo.account（FK → dbo.user 付きで作成）
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
-- STEP 3 : dbo.user に FK(account_id) を後付け
--          dbo.account が存在するため、ここで安全に追加できる
--          account_id は初回 INSERT 時 NULL を許容するため NULL 可のまま FK を付与する
-- ============================================================

CREATE NONCLUSTERED INDEX [IX_user_account_id]
    ON [dbo].[user] ([account_id]);
GO



-- ============================================================
-- dbo.yaml_snapshot
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

