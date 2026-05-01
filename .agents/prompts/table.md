# Database Table Prompt

## 読むタイミング

- `sqlserver/` 配下でテーブル定義を追加するとき
- 既存テーブルのカラム、制約、インデックスを変更するとき
- `init.sql` の更新要否を判断するとき

## 必須ルール

- テーブル定義は `sqlserver/AstralRecord/dbo.<table>/<table>.md` で管理する。
- テーブル定義 `.md` を更新したら `sqlserver/init.sql` も必ず更新する。
- 制約名、インデックス名は `.md` と `init.sql` で一致させる。

## 更新チェックリスト

1. テーブルの責務を確認する。
2. カラム、型、NULL 可否、デフォルト値を整理する。
3. 主キー、外部キー、UNIQUE、CHECK を整理する。
4. 必要なインデックスを整理する。
5. `<table>.md` を更新する。
6. `sqlserver/init.sql` を更新する。
7. API、Plugin、説明資料への影響を確認する。

## DDL ルール

- `CREATE TABLE` の後に必要な `CREATE INDEX` を続ける。
- 循環参照がある場合は作成順を意識する。
- 論理削除テーブルでは `is_deleted` を考慮した索引条件も確認する。

## 非推奨

- `.md` だけ更新して `init.sql` を更新しないこと
- 実装側コードだけ先に進めて DB 契約を後回しにすること
