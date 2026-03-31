# Buff YAML スキーマ定義

Buff（一定時間付与される効果）のスキーマ定義。

本定義は、AstralRecordの独自ステータスシステム（`io.github.maaasu.astralRecord.feature.status.model`）に基づきます。
バニラのステータスシステムやポーション効果（PotionEffect等）は考慮しません。

## スキーマ定義

| キー                   | 型            | 必須 | デフォルト     | 説明                                                               |
|:---------------------|:-------------|:--:|:----------|:-----------------------------------------------------------------|
| `schemaVersion`      | Integer      | ○  | -         | スキーマのバージョン（2026-01-18時点は `1`）                                    |
| `id`                 | String       | ○  | -         | buffのテンプレートID。（例: `haste_small`）                                 |
| `type`               | String       | ○  | -         | 種別（BUFF(bf)）                                                     |
| `name`               | String       | ○  | -         | ゲーム内に表示される名前                                                     |
| `icon`               | String       | ×  | Null      | 表示用アイコン（任意。表現は実装側に委ねる）                                           |
| `lore`               | List<String> | ×  | emptyList | 説明文（§ または & の色コード利用可能）                                           |
| `durationTicks`      | Long         | ○  | -         | 効果時間（tick）。Minecraftの慣習として 20 tick = 1 秒。`-1` の場合は無期限（tickで減らない） |
| `isDebuff`           | Boolean      | ×  | false     | trueでデバフ扱い（表示や演出用途。計算式には影響しない）                                   |
| `modifiers[]`        | List         | ○  | -         | 付与するステータス補正のリスト（後述）                                              |
| `modifiers[].status` | String       | ○  | -         | 対象ステータス（`StatusType`。例: `ATTACK`）                          |
| `modifiers[].type`   | String       | ○  | -         | 補正タイプ（`ModifierType`。`FLAT` / `SCALAR`）                          |
| `modifiers[].value`  | Double       | ○  | -         | 補正値（Double）。`FLAT` は加算、`SCALAR` は乗算係数（例: `0.2` = +20%）           |

### 参照（ref）
他DBからbuffを参照する場合は `buff:` prefix を使用します（aliases: `bf`）。

### modifiers[].status（StatusType）

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

### modifiers[].type（ModifierType）

- `FLAT` : 定数加算
- `SCALAR`: 乗算（ベース値に対して）。計算式: **最終値 = (base + flatTotal) * (1 + scalarTotal)**


## YAML 例

```yaml
schemaVersion: 1
id: haste_small
type: BUFF
name: "&e迅速(小)"
lore:
  - "&7一定時間、移動速度が上昇する。"
durationTicks: 600 # 30秒
isDebuff: false
modifiers:
  - status: MOVEMENT_SPEED
    type: SCALAR
    value: 0.10 # +10%
```

```yaml
schemaVersion: 1
id: battle_focus
type: BUFF
name: "&c戦闘集中"
durationTicks: 400 # 20秒
modifiers:
  - status: ATTACK
    type: FLAT
    value: 10.0
  - status: CRITICAL_RATE
    type: FLAT
    value: 0.05
```

```yaml
schemaVersion: 1
id: armor_break
type: BUFF
name: "&9防御低下"
durationTicks: 200 # 10秒
isDebuff: true
modifiers:
  - status: DEFENSE
    type: FLAT
    value: -15.0
```