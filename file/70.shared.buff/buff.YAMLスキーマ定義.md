# Buff YAML スキーマ定義

Buff（一定時間付与される効果）のスキーマ定義。

本定義は、AstralSagaの独自ステータスシステム（`io.github.maaasu.astralSaga.feature.status`）に基づきます。
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
| `modifiers[].status` | String       | ○  | -         | 対象ステータス（`StatusType`。例: `ATTACK_POWER`）                          |
| `modifiers[].type`   | String       | ○  | -         | 補正タイプ（`ModifierType`。`FLAT` / `SCALAR`）                          |
| `modifiers[].value`  | Double       | ○  | -         | 補正値（Double）。`FLAT` は加算、`SCALAR` は乗算係数（例: `0.2` = +20%）           |

### 参照（ref）
他DBからbuffを参照する場合は `buff:` prefix を使用します（aliases: `bf`）。

### modifiers[].status（StatusType）
`AstralSaga.feature.status.model.StatusType` のいずれかを指定します。

例:
- `ATTACK_POWER`
- `DEFENSE`
- `MOVEMENT_SPEED`
- `COOLDOWN_REDUCTION`

### modifiers[].type（ModifierType）
`AstralSaga.feature.status.model.ModifierType` のいずれかを指定します。

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
  - status: ATTACK_POWER
    type: FLAT
    value: 10.0
  - status: CRITICAL_CHANCE
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