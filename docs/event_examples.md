# Event System Examples

## Example 1: Player Health System

### Using Direct Signals (Recommended for this case)

```gdscript
# player.gd
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died
signal respawned

@export var max_health: int = 100
var current_health: int = 100

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func die() -> void:
	died.emit()

func respawn() -> void:
	current_health = max_health
	respawned.emit()
	health_changed.emit(current_health, max_health)
```

```gdscript
# health_bar.gd (UI Component)
extends ProgressBar

@onready var player = get_node("/root/GameScene/Player")

func _ready():
	# Direct connection to player
	player.health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, maximum: int):
	max_value = maximum
	value = current
```

**Why direct signals here?**
- HealthBar is tightly coupled to Player
- High update frequency possible
- Type-safe parameters
- Easy to debug (can see connection in editor)

## Example 2: Achievement System

### Using EventBus (Recommended for this case)

```gdscript
# player.gd
func die() -> void:
	died.emit()  # Local signal for UI

	# Emit global event for achievement/stats tracking
	EventBus.emit("PLAYER_DIED", {
		"position": global_position,
		"level": current_level,
		"score": score,
		"cause": last_damage_source
	})
```

```gdscript
# achievement_manager.gd
extends Node

var deaths_in_level: int = 0

func _ready():
	EventBus.subscribe("PLAYER_DIED", _on_player_died)
	EventBus.subscribe("LEVEL_COMPLETED", _on_level_completed)

func _on_player_died(data: Dictionary):
	deaths_in_level += 1

	# Check various achievements
	if deaths_in_level >= 100:
		unlock_achievement("PERSISTENT")

	if data.cause == "fall" and data.position.y > 1000:
		unlock_achievement("LONG_FALL")

func _on_level_completed(data: Dictionary):
	if deaths_in_level == 0:
		unlock_achievement("FLAWLESS_LEVEL")
	deaths_in_level = 0

func unlock_achievement(id: String):
	EventBus.emit("ACHIEVEMENT_UNLOCKED", {"id": id})
```

```gdscript
# stats_tracker.gd
extends Node

var total_deaths: int = 0
var death_causes: Dictionary = {}

func _ready():
	EventBus.subscribe("PLAYER_DIED", _on_player_died)

func _on_player_died(data: Dictionary):
	total_deaths += 1

	var cause = data.get("cause", "unknown")
	death_causes[cause] = death_causes.get(cause, 0) + 1
```

**Why EventBus here?**
- Multiple unrelated systems need the same event
- Achievement and Stats don't need direct reference to Player
- Easy to add new listeners without changing Player code
- Decoupled architecture

## Example 3: Hybrid Approach (Game State Management)

```gdscript
# game_manager.gd
extends Node

signal game_paused  # Local signal for direct listeners
signal game_resumed

var is_paused: bool = false

func pause_game() -> void:
	if is_paused:
		return

	is_paused = true
	get_tree().paused = true

	# Emit local signal
	game_paused.emit()

	# Emit global event
	EventBus.emit("GAME_PAUSED", {
		"timestamp": Time.get_ticks_msec(),
		"reason": "user_input"
	})

func resume_game() -> void:
	if not is_paused:
		return

	is_paused = false
	get_tree().paused = false

	# Emit local signal
	game_resumed.emit()

	# Emit global event
	EventBus.emit("GAME_RESUMED", {
		"timestamp": Time.get_ticks_msec(),
		"pause_duration": calculate_pause_duration()
	})
```

```gdscript
# pause_menu.gd (UI - uses direct signal)
extends Control

@onready var game_manager = get_node("/root/GameManager")

func _ready():
	game_manager.game_paused.connect(_on_game_paused)
	game_manager.game_resumed.connect(_on_game_resumed)

func _on_game_paused():
	show()

func _on_game_resumed():
	hide()
```

```gdscript
# analytics.gd (uses EventBus)
extends Node

func _ready():
	EventBus.subscribe("GAME_PAUSED", _on_game_paused)
	EventBus.subscribe("GAME_RESUMED", _on_game_resumed)

func _on_game_paused(data: Dictionary):
	track_event("game_paused", data)

func _on_game_resumed(data: Dictionary):
	track_event("game_resumed", data)
```

## Example 4: Advanced EventBus Features

### Priority and Filtering

```gdscript
# game_manager.gd
func _ready():
	# Save game FIRST (priority 100) before showing game over
	EventBus.subscribe("GAME_OVER", _save_game, 100)

	# Then show UI (priority 50)
	EventBus.subscribe("GAME_OVER", _show_game_over_screen, 50)

	# Finally track analytics (priority 0)
	EventBus.subscribe("GAME_OVER", _track_game_over, 0)
```

### Debouncing High-Frequency Events

```gdscript
# weapon.gd
func shoot() -> void:
	# Local logic
	spawn_bullet()

	# Debounced global event (max 5 per second for sound/effects)
	EventBus.emit_debounced("WEAPON_FIRED", {
		"weapon_type": weapon_type,
		"ammo_remaining": ammo
	}, 0.2)
```

### Conditional Listening

```gdscript
# boss_music_controller.gd
func _ready():
	# Only react to boss enemy spawns
	EventBus.subscribe(
		"ENEMY_SPAWNED",
		_on_boss_spawned,
		0,
		func(data): return data.enemy_type == "boss"
	)

func _on_boss_spawned(data: Dictionary):
	play_boss_music()
```

### One-Shot Listeners

```gdscript
# tutorial_manager.gd
func _ready():
	# Show tutorial only on first damage
	EventBus.subscribe(
		"PLAYER_TOOK_DAMAGE",
		_show_damage_tutorial,
		0,
		Callable(),
		true  # one_shot = true
	)

func _show_damage_tutorial(data: Dictionary):
	show_tutorial("How to heal yourself")
```

### Delayed Events

```gdscript
# enemy.gd
func die():
	play_death_animation()

	# Spawn loot after animation completes
	EventBus.emit_delayed("ENEMY_LOOT_DROPPED", {
		"position": global_position,
		"loot_table": loot_table
	}, 0.5)
```

## Example 5: Debugging Events

```gdscript
# debug_overlay.gd
extends CanvasLayer

@onready var event_log: RichTextLabel = $EventLog

func _ready():
	if not OS.is_debug_build():
		queue_free()
		return

	EventBus.set_stats_enabled(true)

	# Subscribe to ALL events (debugging only!)
	# In production, this would be too expensive
	for event_name in ["PLAYER_DIED", "ENEMY_SPAWNED", "LEVEL_COMPLETED"]:
		EventBus.subscribe(event_name, _on_any_event.bind(event_name))

func _on_any_event(data: Dictionary, event_name: String):
	var log_text = "[color=yellow]%s[/color]: %s\n" % [event_name, str(data)]
	event_log.text += log_text

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3:
			EventBus.print_debug_info()
		elif event.keycode == KEY_F4:
			print_event_history()

func print_event_history():
	print("=== Recent Events ===")
	var history = EventBus.get_event_history(10)
	for event_data in history:
		print("%.2fs - %s: %s" % [
			event_data.timestamp,
			event_data.name,
			event_data.data
		])
```

## Example 6: Testing Events

```gdscript
# test_player_events.gd
extends GutTest

var player: Player

func before_each():
	player = Player.new()
	add_child_autofree(player)

func test_player_death_emits_event():
	var event_received = false
	var event_data = {}

	EventBus.subscribe("PLAYER_DIED", func(data):
		event_received = true
		event_data = data
	)

	# Kill the player
	player.take_damage(9999)

	assert_true(event_received, "PLAYER_DIED event should be emitted")
	assert_true(event_data.has("position"), "Event should include position")
	assert_eq(event_data.cause, "damage", "Death cause should be recorded")

func test_multiple_listeners_called():
	var listener1_called = false
	var listener2_called = false

	EventBus.subscribe("TEST_EVENT", func(data): listener1_called = true)
	EventBus.subscribe("TEST_EVENT", func(data): listener2_called = true)

	EventBus.emit("TEST_EVENT", {})

	assert_true(listener1_called)
	assert_true(listener2_called)

func test_priority_order():
	var call_order = []

	EventBus.subscribe("TEST_EVENT", func(d): call_order.append("low"), 0)
	EventBus.subscribe("TEST_EVENT", func(d): call_order.append("high"), 100)
	EventBus.subscribe("TEST_EVENT", func(d): call_order.append("mid"), 50)

	EventBus.emit("TEST_EVENT", {})

	assert_eq(call_order, ["high", "mid", "low"])

func after_each():
	EventBus.unsubscribe_all("PLAYER_DIED")
	EventBus.unsubscribe_all("TEST_EVENT")
```

## Best Practices Summary

1. **Start with direct signals** - Only move to EventBus when decoupling is beneficial
2. **Use clear naming** - Follow CATEGORY_ACTION convention
3. **Include relevant data** - Make event data self-contained and well-structured
4. **Clean up listeners** - Always unsubscribe in `_exit_tree()`
5. **Avoid event chains** - Don't emit events from event handlers
6. **Document events** - List all events in a central location
7. **Test events** - Write unit tests for critical event flows
8. **Monitor performance** - Use built-in stats to track event frequency
