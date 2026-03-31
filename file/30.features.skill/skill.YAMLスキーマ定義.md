# Skill YAML スキーマ定義

Skill（スキル）のスキーマ定義。

本定義は、プレイヤーやMobが使用するアクティブ／パッシブスキルのテンプレートを管理するためのものです。

## スキーマ定義

| キー                           | 型            | 必須 | デフォルト     | 説明                                                      |
|:-----------------------------|:-------------|:--:|:----------|:--------------------------------------------------------|
| `schemaVersion`              | Integer      | ○  | -         | スキーマのバージョン（2026-03-31時点は `1`）                           |
| `id`                         | String       | ○  | -         | スキルのテンプレートID（例: `slash`）                                |
| `type`                       | String       | ○  | -         | 種別（SKILL(sk)）                                           |
| `name`                       | String       | ○  | -         | ゲーム内に表示されるスキル名                                          |
| `description`                | String       | ×  | Null      | スキル説明文                                                  |
| `icon`                       | String       | ×  | Null      | 表示用アイコン（任意。表現は実装側に委ねる）                                  |
| `lore`                       | List<String> | ×  | emptyList | 説明文（§ または & の色コード利用可能）                                  |
| `skillType`                  | String       | ○  | -         | スキル種別（後述）                                               |
| `targetType`                 | String       | ○  | -         | 対象タイプ（後述）                                               |
| `cooldownTicks`              | Long         | ×  | 0         | クールダウン時間（tick）。20 tick = 1 秒。`0` の場合はクールダウンなし           |
| `manaCost`                   | Double       | ×  | 0         | 使用時のMP消費量                                               |
| `castTimeTicks`              | Long         | ×  | 0         | 詠唱時間（tick）。`0` の場合は即時発動                                 |
| `range`                      | Double       | ×  | 0         | 効果範囲（ブロック単位）。`0` の場合は自身 / 近接                            |
| `requiredLevel`              | Integer      | ×  | 1         | 習得に必要なプレイヤーレベル                                          |
| `effects[]`                  | List         | ○  | -         | スキル発動時に適用する効果のリスト（後述）                                   |
| `effects[].type`             | String       | ○  | -         | 効果種別（`SkillEffectType`。後述）                              |
| `effects[].value`            | Double       | ×  | -         | 効果値（DAMAGE / HEAL 時に使用）                                 |
| `effects[].status`           | String       | ×  | -         | 対象ステータス（HEAL 時: `HP` / `MP`）                            |
| `effects[].isPercent`        | Boolean      | ×  | false     | trueの場合、`value` を割合（%）として扱う（例: `0.10` = 最大値の10%）        |
| `effects[].scaling[]`        | List         | ×  | -         | ステータスに基づくスケーリング補正リスト（後述）                                |
| `effects[].scaling[].status` | String       | ○  | -         | スケーリング元ステータス（`StatusType`。例: `ATTACK`）            |
| `effects[].scaling[].factor` | Double       | ○  | -         | 倍率（例: `1.5` = 攻撃力の150%を加算）                              |
| `effects[].buffId`           | String       | ×  | -         | 付与するBuffID（type=BUFF時に使用）※参照値                           |
| `effects[].rate`             | Double       | ×  | 100       | 発動確率（0〜100）                                             |
| `onCast`                     | Map          | ×  | Null      | 発動時の演出（後述）                                              |
| `onCast.sound`               | String       | ×  | Null      | 発動時に流れるサウンド（SoundKey想定。例: `entity.player.attack.sweep`） |
| `onCast.particle`            | String       | ×  | Null      | 発動時のパーティクル（実装側で解釈）                                      |
| `tags`                       | List<String> | ×  | emptyList | 検索・分類用タグ（例: `melee`, `aoe`, `fire`）                     |

### skillType
以下のいずれかの値を指定します。
- `ACTIVE` : 手動で発動するスキル
- `PASSIVE` : 常時発動 / 条件を満たすと自動発動するスキル

### targetType
以下のいずれかの値を指定します。
- `SELF` : 自分自身
- `SINGLE_ENEMY` : 単体の敵
- `SINGLE_ALLY` : 単体の味方
- `AOE_ENEMY` : 範囲内の敵
- `AOE_ALLY` : 範囲内の味方
- `AOE_ALL` : 範囲内の全対象

### effects[].type（SkillEffectType）
以下のいずれかの値を指定します。
- `DAMAGE` : ダメージを与える
- `HEAL` : HPまたはMPを回復する
- `BUFF` : Buffを付与する

### 参照（ref）
他DBからskillを参照する場合は `skill:` prefix を使用します（aliases: `sk`）。

## YAML 例

### 例1: 近接攻撃スキル

```yaml
schemaVersion: 1
id: slash
type: SKILL
name: "&fスラッシュ"
description: "&7前方の敵に斬撃を与える基本攻撃スキル。"
icon: IRON_SWORD
skillType: ACTIVE
targetType: SINGLE_ENEMY
cooldownTicks: 40
manaCost: 5
castTimeTicks: 0
range: 3
requiredLevel: 1
effects:
  - type: DAMAGE
    value: 20
    scaling:
      - status: ATTACK
        factor: 1.2
    rate: 100
onCast:
  sound: entity.player.attack.sweep
  particle: sweep_attack
tags:
  - melee
  - physical
```

### 例2: 回復スキル

```yaml
schemaVersion: 1
id: heal_light
type: SKILL
name: "&aヒールライト"
description: "&7味方一人のHPを回復する。"
icon: GOLDEN_APPLE
skillType: ACTIVE
targetType: SINGLE_ALLY
cooldownTicks: 200
manaCost: 30
castTimeTicks: 20
range: 10
requiredLevel: 5
effects:
  - type: HEAL
    status: HP
    value: 0.15
    isPercent: true
    rate: 100
onCast:
  sound: block.amethyst_block.chime
  particle: heart
tags:
  - heal
  - magic
```

### 例3: バフ付きAoEスキル

```yaml
schemaVersion: 1
id: war_cry
type: SKILL
name: "&c雄叫び"
description: "&7味方全員の攻撃力を上昇させる。"
icon: GOAT_HORN
skillType: ACTIVE
targetType: AOE_ALLY
cooldownTicks: 600
manaCost: 40
castTimeTicks: 10
range: 15
requiredLevel: 10
effects:
  - type: BUFF
    buffId:
      ref: buff:battle_focus
    rate: 100
onCast:
  sound: entity.ender_dragon.growl
  particle: angry_villager
tags:
  - support
  - aoe
  - buff
```

