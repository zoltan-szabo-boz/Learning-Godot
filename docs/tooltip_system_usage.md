# Tooltip System Usage Guide

## Overview

The TooltipManager provides a flexible, dynamic tooltip system that supports:
- **Dynamic content**: Tooltips update based on current game state
- **Variable interpolation**: Show live data like health, mana, etc.
- **Localization**: Full integration with LocalizationManager
- **State-aware**: Different tooltips for enabled/disabled states
- **Custom styling**: Customize appearance per tooltip or globally

## Setup

Add TooltipManager to autoload in `project.godot`:
```ini
[autoload]
TooltipManager="*res://scripts/tooltip_manager.gd"
```

## Basic Usage

### Simple Static Tooltip

```gdscript
extends Button

func _ready():
	TooltipManager.register_tooltip(
		self,
		func(): return tr("TOOLTIP_SIMPLE")
	)
```

### Dynamic Tooltip with Variables

```gdscript
extends ProgressBar

var current_hp: int = 75
var max_hp: int = 100

func _ready():
	TooltipManager.register_tooltip(
		self,
		func(): return _get_health_tooltip()
	)

func _get_health_tooltip() -> String:
	return tr("TOOLTIP_HEALTH") % [current_hp, max_hp]
	# Translation: "Health: %d/%d"
	# Result: "Health: 75/100"
```

### State-Aware Tooltip (Disabled vs Enabled)

```gdscript
extends Button

var can_afford: bool = false
var item_cost: int = 100
var player_gold: int = 50

func _ready():
	TooltipManager.register_tooltip(
		self,
		func(): return _get_purchase_tooltip()
	)

func _get_purchase_tooltip() -> String:
	if disabled or not can_afford:
		# Show why the button is disabled
		return tr("TOOLTIP_CANNOT_AFFORD") % [item_cost, player_gold]
		# Translation: "Cannot afford: Need %d gold (have %d)"
	else:
		# Show normal purchase info
		return tr("TOOLTIP_PURCHASE_ITEM") % [item_cost]
		# Translation: "Purchase for %d gold"

func _process(delta):
	can_afford = player_gold >= item_cost
	disabled = not can_afford
```

### Conditional Tooltip Display

```gdscript
extends Button

var debug_mode: bool = false

func _ready():
	# Tooltip only shows when debug mode is enabled
	TooltipManager.register_tooltip(
		self,
		func(): return "Debug Info: Node path = " + str(get_path()),
		func(): return debug_mode  # enabled_check
	)
```

### Complex Tooltip with Multiple Conditions

```gdscript
extends Control

var item_data = {
	"name": "Sword of Testing",
	"damage": 42,
	"durability": 75,
	"durability_max": 100,
	"rarity": "Epic",
	"level_required": 10
}

var player_level: int = 8

func _ready():
	TooltipManager.register_tooltip(
		self,
		func(): return _get_item_tooltip(),
		func(): return true,  # Always show
		0.3  # Show after 0.3 seconds
	)

func _get_item_tooltip() -> String:
	var lines = []

	# Item name with rarity color
	var rarity_color = _get_rarity_color(item_data.rarity)
	lines.append("[color=%s][b]%s[/b][/color]" % [rarity_color, tr(item_data.name)])

	# Stats
	lines.append("")
	lines.append(tr("TOOLTIP_DAMAGE") % item_data.damage)
	lines.append(tr("TOOLTIP_DURABILITY") % [item_data.durability, item_data.durability_max])

	# Level requirement (red if can't use)
	if player_level < item_data.level_required:
		lines.append("[color=red]%s[/color]" % (tr("TOOLTIP_LEVEL_REQUIRED") % item_data.level_required))
	else:
		lines.append(tr("TOOLTIP_LEVEL_REQUIRED") % item_data.level_required)

	return "\n".join(lines)

func _get_rarity_color(rarity: String) -> String:
	match rarity:
		"Common": return "#FFFFFF"
		"Uncommon": return "#00FF00"
		"Rare": return "#0080FF"
		"Epic": return "#A020F0"
		"Legendary": return "#FFA500"
		_: return "#FFFFFF"
```

## Localization Integration

Add tooltip translations to `translations.csv`:

```csv
keys,en,de,hu,ja
TOOLTIP_HEALTH,Health: %d/%d,Gesundheit: %d/%d,Élet: %d/%d,体力: %d/%d
TOOLTIP_CANNOT_AFFORD,Cannot afford: Need %d gold (have %d),Kann nicht leisten: Benötigt %d Gold (haben %d),Nem engedhető meg: %d arany szükséges (%d arany van),購入不可: %dゴールド必要 (%dゴールド所持)
TOOLTIP_PURCHASE_ITEM,Purchase for %d gold,Für %d Gold kaufen,Vásárlás %d aranyért,%dゴールドで購入
TOOLTIP_DAMAGE,Damage: %d,Schaden: %d,Sebzés: %d,ダメージ: %d
TOOLTIP_DURABILITY,Durability: %d/%d,Haltbarkeit: %d/%d,Tartósság: %d/%d,耐久度: %d/%d
TOOLTIP_LEVEL_REQUIRED,Requires Level %d,Benötigt Level %d,Szükséges szint: %d,必要レベル: %d
```

## Advanced Features

### Custom Tooltip Delay

```gdscript
# Show tooltip immediately (0 delay)
TooltipManager.register_tooltip(
	critical_warning_button,
	func(): return "WARNING: This cannot be undone!",
	Callable(),
	0.0  # No delay
)

# Show tooltip after 1 second
TooltipManager.register_tooltip(
	less_important_button,
	func(): return "Additional info",
	Callable(),
	1.0  # 1 second delay
)
```

### Custom Styling

```gdscript
func _ready():
	# Get tooltip label for font customization
	var tooltip_label = TooltipManager.get_tooltip_label()

	# Create custom style for tooltip background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.1, 0.0, 0.95)  # Dark orange
	style.border_color = Color(1.0, 0.5, 0.0, 1.0)  # Orange border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	TooltipManager.set_tooltip_style(style)
```

### Unregister Tooltip

```gdscript
# Remove tooltip from node
TooltipManager.unregister_tooltip(my_button)
```

### Listen to Tooltip Events

```gdscript
func _ready():
	TooltipManager.tooltip_shown.connect(_on_tooltip_shown)
	TooltipManager.tooltip_hidden.connect(_on_tooltip_hidden)

func _on_tooltip_shown(node: Control, text: String):
	print("Tooltip shown for %s: %s" % [node.name, text])

func _on_tooltip_hidden():
	print("Tooltip hidden")
```

## BBCode Support

The tooltip label supports BBCode for rich text formatting:

```gdscript
func _get_formatted_tooltip() -> String:
	return """[center][b]Epic Sword[/b][/center]
[color=yellow]Damage: 50[/color]
[color=cyan]Speed: +15%[/color]
[color=gray][i]A legendary weapon...[/i][/color]"""
```

## Performance Considerations

- Tooltip content providers are called periodically (default: every 0.1s)
- Keep provider functions lightweight
- Avoid expensive calculations in tooltip providers
- Cache values if needed:

```gdscript
var _cached_tooltip: String = ""
var _cache_dirty: bool = true

func _get_tooltip() -> String:
	if _cache_dirty:
		_cached_tooltip = _calculate_expensive_tooltip()
		_cache_dirty = false
	return _cached_tooltip

func _on_stats_changed():
	_cache_dirty = true
```

## Best Practices

1. **Use translation keys**: Always use `tr()` for localizable text
2. **Keep it concise**: Tooltips should be helpful but not overwhelming
3. **Use formatting**: BBCode can make important info stand out
4. **Update on state changes**: Tooltip content updates automatically
5. **Conditional display**: Use `enabled_check` to hide tooltips when not relevant
6. **Appropriate delays**: Critical info = short delay, optional info = longer delay

## Common Patterns

### Ability Cooldown Tooltip
```gdscript
func _get_ability_tooltip() -> String:
	if is_on_cooldown:
		var remaining = cooldown_remaining
		return tr("TOOLTIP_ABILITY_COOLDOWN") % remaining
	else:
		return tr("TOOLTIP_ABILITY_READY")
```

### Resource Cost Tooltip
```gdscript
func _get_cost_tooltip() -> String:
	var costs = []
	if gold_cost > 0:
		costs.append(tr("TOOLTIP_GOLD_COST") % gold_cost)
	if wood_cost > 0:
		costs.append(tr("TOOLTIP_WOOD_COST") % wood_cost)
	return "\n".join(costs)
```

### Stat Comparison Tooltip
```gdscript
func _get_comparison_tooltip() -> String:
	var current_damage = equipped_weapon.damage
	var new_damage = preview_weapon.damage
	var diff = new_damage - current_damage

	var color = "green" if diff > 0 else "red"
	return tr("TOOLTIP_DAMAGE_COMPARISON") % [
		new_damage,
		"[color=%s]%+d[/color]" % [color, diff]
	]
	# Result: "Damage: 50 (+10)" in green
```
