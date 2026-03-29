# Class YAML スキーマ定義

Class（職業）のスキーマ定義。

本定義は、プレイヤーの職業テンプレート（成長方針・初期ステータス・進行解放要件）を管理するためのものです。

## スキーマ定義

| キー                           | 型            | 必須 | デフォルト     | 説明                            |
|:-----------------------------|:-------------|:--:|:----------|:------------------------------|
| `schemaVersion`              | Integer      | ○  | -         | スキーマのバージョン（2026-03-24時点は `1`） |
| `id`                         | String       | ○  | -         | classのテンプレートID（例: `warrior`）  |
| `type`                       | String       | ○  | -         | 種別（CLASS(cls)）                |
| `name`                       | String       | ○  | -         | ゲーム内に表示される職業名                 |
| `description`                | String       | ×  | Null      | 職業説明文                         |
| `icon`                       | String       | ×  | Null      | 表示アイコン（任意。表現は実装側に委ねる）         |
| `role`                       | String       | ○  | -         | 職業ロール（後述）                     |
| `unlockLevel`                | Integer      | ×  | 1         | 解放に必要な最低プレイヤーレベル              |
| `baseStats`                  | Map          | ○  | -         | 初期ステータス（後述）                   |
| `baseStats.maxHealth`        | Integer      | ○  | -         | 初期最大HP                        |
| `baseStats.attackPower`      | Integer      | ○  | -         | 初期攻撃力                         |
| `baseStats.defense`          | Integer      | ○  | -         | 初期防御力                         |
| `baseStats.movementSpeed`    | Double       | ×  | 0.1       | 初期移動速度係数                      |
| `growthPerLevel`             | Map          | ×  | Null      | レベルアップ時の成長量（後述）               |
| `growthPerLevel.maxHealth`   | Integer      | ×  | 0         | 1レベルあたりの最大HP増加量               |
| `growthPerLevel.attackPower` | Integer      | ×  | 0         | 1レベルあたりの攻撃力増加量                |
| `growthPerLevel.defense`     | Integer      | ×  | 0         | 1レベルあたりの防御力増加量                |
| `starterSkills`              | List<String> | ×  | emptyList | 初期習得スキルID一覧（参照値）              |
| `tags`                       | List<String> | ×  | emptyList | 検索・分類用タグ（例: `melee`, `tank`）  |

### role
以下のいずれかの値を指定します。
- TANK
- DEALER
- HEALER
- SUPPORT

### 参照（ref）
他DBからclassを参照する場合は `class:` prefix を使用します（aliases: `cls`）。

## YAML 例

```yaml
schemaVersion: 1
id: warrior
type: CLASS
name: "&c戦士"
description: "&7近接戦闘を得意とする前衛職。"
role: TANK
unlockLevel: 1
baseStats:
  maxHealth: 120
  attackPower: 14
  defense: 10
  movementSpeed: 0.1
growthPerLevel:
  maxHealth: 8
  attackPower: 2
  defense: 1
starterSkills:
  - ref: skill:slash
tags:
  - melee
  - front
```
