# Mob 共通 YAML スキーマ定義

MOBの基本的なスキーマ定義。全カテゴリ（ENEMY / BOSS / NPC）で共通のフィールドを定義します。

本定義は、ProtocolLib を用いて表示されるカスタムエンティティのテンプレートを管理するためのものです。
ステータスはプラグイン側の独自ステータスシステム（`io.github.maaasu.astralRecord.feature.status.model.StatusType`）に基づき、バニラの Attribute は使用しません。
AI（行動ロジック）もプラグイン独自実装であり、本スキーマでは行動パラメータのみを宣言します。

各カテゴリ固有のフィールドは、それぞれのサブディレクトリ配下にあるスキーマ定義を参照してください。

| カテゴリ    | 固有スキーマ                      | 説明                                |
|:--------|:----------------------------|:----------------------------------|
| `ENEMY` | `enemy/enemy.YAMLスキーマ定義.md` | 通常の敵Mob。フィールドやダンジョンに配置            |
| `BOSS`  | `boss/boss.YAMLスキーマ定義.md`   | ボスMob。基本動作はENEMYと同様。固有ギミックはプラグイン側 |
| `NPC`   | `npc/npc.YAMLスキーマ定義.md`     | 非戦闘Mob。会話・ショップなどのインタラクション用        |

---

## スキーマ定義

| キー              | 型            | 必須 | デフォルト     | 説明                                                      |
|:----------------|:-------------|:--:|:----------|:--------------------------------------------------------|
| `schemaVersion` | Integer      | ○  | -         | スキーマのバージョン（2026-04-01時点は `1`）                           |
| `id`            | String       | ○  | -         | mobのテンプレートID（例: `goblin_warrior`）                       |
| `type`          | String       | ○  | -         | 種別（MOB(mob)）                                            |
| `category`      | String       | ○  | -         | カテゴリ（`ENEMY` / `BOSS` / `NPC`）。ファイルが適切なフォルダに配置されているかの確認 |
| `name`          | String       | ○  | -         | ゲーム内に表示される名前（色コード利用可能）                                  |
| `title`         | String       | ×  | Null      | 二つ名・称号（例: `"&4闇の支配者"`）                                  |
| `level`         | Integer      | ○  | -         | Mobのレベル                                                 |
| `entityType`    | String       | ○  | -         | Bukkit EntityType（ProtocolLib表示用。例: `ZOMBIE`）           |
| `skin`          | Map          | ×  | Null      | エンティティの外見設定（後述。entityType が `PLAYER` の場合に主に使用）          |
| `nameVisible`   | Boolean      | ×  | true      | ネームタグ表示の有無                                              |
| `icon`          | String       | ×  | Null      | UI/図鑑表示用アイコン（Bukkit Material名）                          |
| `lore`          | List<String> | ×  | emptyList | 説明文（§ または & の色コード利用可能）                                  |
| `tags`          | List<String> | ×  | emptyList | 検索・分類用タグ（例: `undead`, `humanoid`, `fire`）               |

### skin（外見設定）

`entityType` が `PLAYER` の場合など、スキンテクスチャを指定する際に使用します。

| キー               | 型      | 必須 | デフォルト | 説明                     |
|:-----------------|:-------|:--:|:------|:-----------------------|
| `skin.texture`   | String | ×  | Null  | Base64エンコードされたスキンテクスチャ値 |
| `skin.signature` | String | ×  | Null  | テクスチャの署名値              |

### equipment（装備設定）

Mobが表示上装備するアイテムを指定します。すべて任意項目です。

| キー                     | 型      | 必須 | デフォルト | 説明             |
|:-----------------------|:-------|:--:|:------|:---------------|
| `equipment.mainHand`   | String | ×  | Null  | メインハンド（※参照値）   |
| `equipment.offHand`    | String | ×  | Null  | オフハンド（※参照値）    |
| `equipment.helmet`     | String | ×  | Null  | ヘルメット（※参照値）    |
| `equipment.chestplate` | String | ×  | Null  | チェストプレート（※参照値） |
| `equipment.leggings`   | String | ×  | Null  | レギンス（※参照値）     |
| `equipment.boots`      | String | ×  | Null  | ブーツ（※参照値）      |

※ 参照値は `item:` prefix（例: `ref: item:iron_sword`）

### baseStats（ステータス）

プラグイン独自の `StatusType` を使用したステータス定義。class と同様の形式です。

| キー                   | 型      | 必須 | デフォルト | 説明                                  |
|:---------------------|:-------|:--:|:------|:--------------------------------------|
| `baseStats[]`        | List   | ○  | -     | ステータスのリスト                           |
| `baseStats[].status` | String | ○  | -     | ステータス名（`StatusType`。例: `MAX_HEALTH`） |
| `baseStats[].value`  | Double | ○  | -     | ステータス値                              |

#### baseStats[].status（StatusType）

プラグイン側（`io.github.maaasu.astralRecord.feature.status.model.StatusType`）で定義されるステータス名を指定します。（class / buff と同一の体系）

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

### ai.idle（非接敵時行動）— 全カテゴリ共通

| キー                     | 型      | 必須 | デフォルト | 説明                              |
|:------------------------|:-------|:--:|:------|:----------------------------------|
| `ai.idle.behavior`     | String | ○  | -     | 非接敵時の行動パターン（後述 `IdleBehavior`）   |
| `ai.idle.wanderRadius` | Double | ×  | 10.0  | `WANDER` 時の徘徊半径（ブロック単位）          |
| `ai.idle.speed`        | Double | ×  | 1.0   | 非接敵時の移動速度倍率（1.0 = 通常速度）          |

#### IdleBehavior
- `STATIONARY` : その場から動かない
- `WANDER` : スポーン地点を中心にランダムに徘徊
- `PATROL` : プラグイン側で定義された経路を巡回

### 参照（ref）
他DBからmobを参照する場合は `mob:` prefix を使用します（aliases: `mb`）。

---

## YAML 例

共通フィールドのみの最小構成例です。カテゴリ固有フィールドを含む完全な例は各サブディレクトリのスキーマ定義を参照してください。

```yaml
schemaVersion: 1
id: goblin_warrior
type: MOB
category: ENEMY
name: "&cゴブリンウォリアー"
level: 5
entityType: ZOMBIE
icon: ZOMBIE_HEAD
lore:
  - "&7森に生息する好戦的なゴブリン。"
tags:
  - humanoid
  - goblin

equipment:
  mainHand:
    ref: item:rusty_sword

baseStats:
  - status: MAX_HEALTH
    value: 150
  - status: ATTACK
    value: 18
  - status: DEFENSE
    value: 5
  - status: MOVEMENT_SPEED
    value: 0.12

ai:
  idle:
    behavior: WANDER
    wanderRadius: 8
    speed: 0.8
  # ... カテゴリ固有のAI設定が続く（各スキーマ定義を参照）
```
