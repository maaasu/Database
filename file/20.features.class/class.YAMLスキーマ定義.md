# Class YAML スキーマ定義

Class（職業）のスキーマ定義。

本定義は、プレイヤーの職業テンプレート（成長方針・初期ステータス・進行解放要件）を管理するためのものです。
ステータスの種別はプラグイン側で定義されるため、本スキーマではステータス名（`status`）と値（`value`）のペアのみを指定します。

## スキーマ定義

| キー                        | 型            | 必須 | デフォルト     | 説明                                             |
|:--------------------------|:-------------|:--:|:----------|:-----------------------------------------------|
| `schemaVersion`           | Integer      | ○  | -         | スキーマのバージョン（2026-03-31時点は `1`）                  |
| `id`                      | String       | ○  | -         | classのテンプレートID（例: `warrior`）                   |
| `type`                    | String       | ○  | -         | 種別（CLASS(cls)）                                 |
| `name`                    | String       | ○  | -         | ゲーム内に表示される職業名                                  |
| `description`             | String       | ×  | Null      | 職業説明文                                          |
| `icon`                    | String       | ×  | Null      | 表示アイコン（任意。表現は実装側に委ねる）                          |
| `role`                    | String       | ○  | -         | 職業ロール（後述）                                      |
| `unlockLevel`             | Integer      | ×  | 1         | 解放に必要な最低プレイヤーレベル                               |
| `baseStats[]`             | List         | ○  | -         | 初期ステータスのリスト（後述）                                |
| `baseStats[].status`      | String       | ○  | -         | ステータス名（`StatusType`。プラグイン側で定義。例: `MAX_HEALTH`） |
| `baseStats[].value`       | Double       | ○  | -         | 初期値                                            |
| `growthPerLevel[]`        | List         | ×  | emptyList | レベルアップ時の成長量リスト（後述）                             |
| `growthPerLevel[].status` | String       | ○  | -         | ステータス名（`StatusType`。`baseStats` と同様）           |
| `growthPerLevel[].value`  | Double       | ○  | -         | 1レベルあたりの増加量                                    |
| `starterSkills`           | List<String> | ×  | emptyList | 初期習得スキルID一覧（参照値）                               |
| `tags`                    | List<String> | ×  | emptyList | 検索・分類用タグ（例: `melee`, `tank`）                   |

### role
以下のいずれかの値を指定します。
- TANK
- DEALER
- HEALER
- SUPPORT

### baseStats[].status / growthPerLevel[].status（StatusType）
プラグイン側（`io.github.maaasu.astralRecord.feature.status.model.StatusType`）で定義されるステータス名を指定します。

| カテゴリ       | StatusType                | 表示名        | 説明                         |
|:-----------|:--------------------------|:-----------|:---------------------------|
| RESOURCE   | `MAX_HEALTH`              | 最大HP       |                            |
| RESOURCE   | `MAX_MANA`                | 最大MP       |                            |
| RESOURCE   | `MAX_ENERGY`              | 最大EN       | スキル発動・ダッシュ・回避行動等に消費       |
| PRIMARY    | `STRENGTH`                | 筋力         | 近接攻撃のダメージスケーリングに影響         |
| PRIMARY    | `DEXTERITY`               | 器用さ        | 間接攻撃（弓・投擲等）のダメージスケーリングに影響  |
| PRIMARY    | `INTELLIGENCE`            | 知力         | 魔法攻撃スケーリング・最大MP・MP回復に影響    |
| PRIMARY    | `VITALITY`                | 体力         | 最大HP・物理/魔法防御・HP回復に影響       |
| PRIMARY    | `AGILITY`                 | 敏捷性        | 攻撃速度・移動速度・回避率に影響           |
| PRIMARY    | `LUCK`                    | 幸運         | 会心率・ドロップ率に影響               |
| OFFENSE    | `ATTACK`                  | 攻撃力        | 武器のベース攻撃力 + バフ等の加算値        |
| OFFENSE    | `MELEE_ATTACK`            | 近接攻撃力      | ATTACK × STRENGTH スケーリング   |
| OFFENSE    | `RANGED_ATTACK`           | 間接攻撃力      | ATTACK × DEXTERITY スケーリング  |
| OFFENSE    | `MAGIC_ATTACK`            | 魔法攻撃力      | ATTACK × INTELLIGENCE スケーリング |
| OFFENSE    | `CRITICAL_RATE`           | 会心率        | 攻撃時に会心が発生する確率（%）           |
| OFFENSE    | `CRITICAL_DAMAGE`         | 会心ダメージ     | 会心発生時のダメージ倍率（%）            |
| OFFENSE    | `SUPER_CRITICAL_RATE`     | 超会心率       | 会心時にさらに発動する第二の会心確率（%）      |
| OFFENSE    | `SUPER_CRITICAL_DAMAGE`   | 超会心ダメージ    | 超会心発動時に追加乗算される倍率（%）        |
| OFFENSE    | `FINAL_DAMAGE_RATE`       | 最終ダメージ確率   | 全ダメージ計算後に追加ダメージが発動する確率（%）  |
| OFFENSE    | `FINAL_DAMAGE_MULTIPLIER` | 最終ダメージ倍率   | 追加ダメージ発動時の倍率（%）            |
| OFFENSE    | `ACCURACY`                | 命中率        | 攻撃がヒットする確率（%）。EVASIONとの対抗判定 |
| OFFENSE    | `ATTACK_SPEED`            | 攻撃速度       | 攻撃のクールダウン短縮割合（%）           |
| DEFENSE    | `DEFENSE`                 | 物理防御力      | 近接・間接攻撃による物理ダメージを軽減        |
| DEFENSE    | `MAGIC_DEFENSE`           | 魔法防御力      | 魔法攻撃によるダメージを軽減             |
| DEFENSE    | `EVASION`                 | 回避率        | 攻撃を完全に回避する確率（%）            |
| UTILITY    | `HP_REGEN`                | HP回復力      | HP自然回復量（5秒あたり）             |
| UTILITY    | `MP_REGEN`                | MP回復力      | MP自然回復量（5秒あたり）             |
| UTILITY    | `ENERGY_REGEN`            | EN回復力      | エネルギー自然回復量（5秒あたり）          |
| UTILITY    | `MOVEMENT_SPEED`          | 移動速度       | 100% が標準速度（%）              |
| UTILITY    | `COOLDOWN_REDUCTION`      | CD短縮       | クールダウン短縮率（%）               |

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
  - status: MAX_HEALTH
    value: 120
  - status: MAX_MANA
    value: 50
  - status: STRENGTH
    value: 14
  - status: VITALITY
    value: 12
  - status: AGILITY
    value: 8
  - status: ATTACK
    value: 10
  - status: DEFENSE
    value: 10
  - status: MOVEMENT_SPEED
    value: 100
growthPerLevel:
  - status: MAX_HEALTH
    value: 8
  - status: MAX_MANA
    value: 2
  - status: STRENGTH
    value: 2
  - status: VITALITY
    value: 1.5
  - status: ATTACK
    value: 1
  - status: DEFENSE
    value: 1
starterSkills:
  - ref: skill:slash
tags:
  - melee
  - front
```
