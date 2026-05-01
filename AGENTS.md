# Database Guide

対象: `Database/sqlserver/` と `Database/file/`

## 役割

- SQL Server スキーマ定義を管理する。
- YAML マスタデータを管理する。
- アプリケーションが依存する DB / マスタ契約を明文化する。

## ディレクトリ方針

- テーブル定義は `sqlserver/AstralRecord/dbo.<table>/<table>.md` で管理する。
- Snapshot 系は `sqlserver/AstralRecordSnapshot/` に置く。
- YAML は `file/<連番>.<カテゴリ>/` に置く。

## SQL Server 運用ルール

- テーブル定義を追加・更新・削除したら対応する `.md` を更新する。
- テーブル定義の `.md` を更新したら、必ず `sqlserver/init.sql` も更新する。
- 制約、外部キー、インデックスの変更も `init.sql` へ反映する。
- 関連する API、Plugin、説明資料の更新が必要か確認する。

## YAML 運用ルール

- プレイヤー操作で変化しない定義を中心に YAML で管理する。
- 大量定義や運用調整が必要なデータは YAML を優先する。
- 少数でコード変更前提の定義は、無理に YAML 化しなくてよい。

## 命名方針

- スキーマは原則 `dbo` を使う。
- テーブル名、カラム名は `snake_case` を使う。
- 制約名、インデックス名は `.md` と `init.sql` で一致させる。

## 補助プロンプト

- `.agents/prompts/table.md`
  - `sqlserver/` のテーブル定義、DDL、`init.sql` 同期ルールを扱う。
- `.agents/prompts/file.md`
  - `file/` 配下の YAML 定義追加・更新ルールを扱う。
