# Event Architecture Guide

## Overview

This project uses a **hybrid event system** combining Godot's native signals with a centralized EventBus for different use cases.

## When to Use What

### Direct Signals (Godot Native)

**Use for:**
- Parent-child communication
- Closely coupled components
- High-frequency events (60+ times per second)
- UI interactions (button clicks, hover events)
- Component-specific events

**Advantages:**
- Type-safe (compile-time checking)
- Better performance
- Explicit connections (easy to trace)
- Editor integration (can see connections)
- Local scope (no global pollution)

**Example:**
```gdscript
# In Player.gd
signal health_changed(new_health: int, max_health: int)
signal died(position: Vector2)

func take_damage(amount: int):
	health -= amount
	health_changed.emit(health, max_health)
	if health <= 0:
		died.emit(global_position)

# In HealthBar.gd (UI component)
func _ready():
	player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int, max_health: int):
	update_bar(new_health, max_health)
```

### EventBus (Global Events)

**Use for:**
- Cross-system communication
- Game state changes (pause, game over, level complete)
- Achievement/stat tracking
- Events that multiple unrelated systems need to know about
- Debugging and analytics
- Loosely coupled architecture

**Advantages:**
- Decouples systems
- Easy to add new listeners without modifying emitters
- Built-in debugging (history, stats)
- Debouncing and filtering
- Priority system

**Example:**
```gdscript
# In Player.gd
func die():
	EventBus.emit("PLAYER_DIED", {
		"position": global_position,
		"cause": last_damage_type,
		"score": score
	})

# In AchievementManager.gd
func _ready():
	EventBus.subscribe("PLAYER_DIED", _on_player_died)

func _on_player_died(data: Dictionary):
	check_death_related_achievements(data)

# In StatsTracker.gd
func _ready():
	EventBus.subscribe("PLAYER_DIED", _on_player_died)

func _on_player_died(data: Dictionary):
	total_deaths += 1
	record_death_location(data.position)

# In GameManager.gd
func _ready():
	EventBus.subscribe("PLAYER_DIED", _on_player_died)

func _on_player_died(data: Dictionary):
	show_game_over_screen()
```

## Architecture Patterns

### 1. Layered Event Architecture

```
┌─────────────────────────────────────┐
│          EventBus (Global)          │  <- Cross-system events
│  GAME_PAUSED, ACHIEVEMENT_UNLOCKED  │
└─────────────────────────────────────┘
           ↑
┌─────────────────────────────────────┐
│      Manager Layer (Signals)        │  <- System-level signals
│  GameManager, AudioManager, etc.    │
└─────────────────────────────────────┘
           ↑
┌─────────────────────────────────────┐
│     Component Layer (Signals)       │  <- Local signals
│   Player, Enemy, UI, etc.           │
└─────────────────────────────────────┘
```

### 2. Event Naming Convention

Use clear, hierarchical naming:

```gdscript
# Format: CATEGORY_ACTION or CATEGORY_SUBCATEGORY_ACTION

# Player events
PLAYER_SPAWNED
PLAYER_DIED
PLAYER_LEVEL_UP
PLAYER_INVENTORY_CHANGED

# Game state events
GAME_STARTED
GAME_PAUSED
GAME_RESUMED
GAME_OVER

# UI events
UI_MENU_OPENED
UI_MENU_CLOSED
UI_DIALOG_CONFIRMED

# Achievement events
ACHIEVEMENT_UNLOCKED
ACHIEVEMENT_PROGRESS_UPDATED
```

### 3. Event Data Structure

Keep event data consistent and documented:

```gdscript
# Good: Structured data with clear keys
EventBus.emit("ENEMY_KILLED", {
	"enemy_type": "goblin",
	"position": Vector2(100, 200),
	"killed_by": "player",
	"exp_reward": 50
})

# Bad: Inconsistent or unclear data
EventBus.emit("ENEMY_KILLED", {
	"type": enemy.name,  # Inconsistent key names
	"pos": enemy.position,  # Abbreviated
	"data": some_random_value  # Vague
})
```

## Advanced Features

### Priority Listeners

Higher priority listeners are called first:

```gdscript
# Critical system (priority 100)
EventBus.subscribe("GAME_OVER", save_game, 100)

# UI update (priority 50)
EventBus.subscribe("GAME_OVER", show_game_over_screen, 50)

# Analytics (priority 0)
EventBus.subscribe("GAME_OVER", track_game_over)
```

### Filtered Listeners

Only receive events matching a condition:

```gdscript
# Only listen for critical damage (> 50)
EventBus.subscribe(
	"DAMAGE_TAKEN",
	_on_critical_damage,
	0,
	func(data): return data.amount > 50
)

# Only listen for specific enemy types
EventBus.subscribe(
	"ENEMY_SPAWNED",
	_on_boss_spawned,
	0,
	func(data): return data.enemy_type == "boss"
)
```

### Debouncing

Prevent event spam:

```gdscript
# Limit rapid-fire input events
func _on_shoot_pressed():
	EventBus.emit_debounced("WEAPON_FIRED", {}, 0.1)  # Max 10/sec

# Throttle position updates
func _process(delta):
	EventBus.emit_debounced("PLAYER_MOVED", {
		"position": global_position
	}, 0.05)  # Max 20/sec
```

### One-Shot Listeners

Automatically unsubscribe after first call:

```gdscript
# Listen for game start only once
EventBus.subscribe("GAME_STARTED", _initialize_systems, 0, Callable(), true)
```

### Delayed Events

Emit after a delay:

```gdscript
# Show tutorial after 2 seconds
EventBus.emit_delayed("SHOW_TUTORIAL", {}, 2.0)
```

## Memory Management

### Proper Cleanup

Always unsubscribe when objects are freed:

```gdscript
func _ready():
	EventBus.subscribe("GAME_OVER", _on_game_over)

func _exit_tree():
	EventBus.unsubscribe("GAME_OVER", _on_game_over)
```

### Weak References (Advanced)

For temporary objects, consider using weak references:

```gdscript
# In Enemy.gd
func _ready():
	# Store weak reference to self
	var weak_self = weakref(self)

	EventBus.subscribe("POWER_UP_COLLECTED", func(data):
		var obj = weak_self.get_ref()
		if obj:  # Check if still alive
			obj.react_to_powerup(data)
	)
```

## Debugging

### Enable Statistics

```gdscript
# In debug build
func _ready():
	if OS.is_debug_build():
		EventBus.set_stats_enabled(true)

# Print stats
func _on_debug_key_pressed():
	print(EventBus.get_stats())
	EventBus.print_debug_info()
```

### View Event History

```gdscript
# Get last 10 events
var recent = EventBus.get_event_history(10)
for event in recent:
	print("%s at %.2fs: %s" % [event.name, event.timestamp, event.data])
```

## Anti-Patterns to Avoid

### ❌ Don't: Use EventBus for Everything

```gdscript
# Bad: High-frequency events
func _process(delta):
	EventBus.emit("PLAYER_POSITION_UPDATE", {"pos": position})

# Good: Use direct signals or callbacks
signal position_changed(new_position: Vector2)
```

### ❌ Don't: Create Event Dependency Chains

```gdscript
# Bad: Events triggering events
func _on_event_a(data):
	EventBus.emit("EVENT_B", data)

func _on_event_b(data):
	EventBus.emit("EVENT_C", data)  # Hard to debug!

# Good: Direct calls or single event
func _on_event_a(data):
	handle_event_a(data)
	handle_event_b(data)
	handle_event_c(data)
```

### ❌ Don't: Put Game Logic in Events

```gdscript
# Bad: Complex logic in event handlers
func _on_player_died(data):
	if data.cause == "fall":
		respawn_at_checkpoint()
	elif data.cause == "enemy":
		show_death_animation()
	# ... 100 lines of logic

# Good: Keep handlers thin, delegate to proper systems
func _on_player_died(data):
	death_handler.handle_death(data)
```

### ❌ Don't: Use Vague Event Names

```gdscript
# Bad
EventBus.emit("UPDATE", {})
EventBus.emit("THING_HAPPENED", {})
EventBus.emit("DO_STUFF", {})

# Good
EventBus.emit("PLAYER_HEALTH_CHANGED", {"health": 50})
EventBus.emit("ENEMY_SPAWNED", {"type": "goblin"})
EventBus.emit("LEVEL_COMPLETED", {"level_id": 3})
```

## Performance Considerations

### Event Frequency Guidelines

- **< 10/sec**: Safe for EventBus
- **10-60/sec**: Consider direct signals
- **> 60/sec**: Must use direct signals or callbacks

### Listener Count

- **< 10 listeners**: No concern
- **10-50 listeners**: Monitor performance
- **> 50 listeners**: Consider breaking into multiple events

## Testing Events

```gdscript
# In test_game_events.gd
extends GutTest

func test_player_death_event():
	var received = false
	var event_data = {}

	EventBus.subscribe("PLAYER_DIED", func(data):
		received = true
		event_data = data
	)

	# Simulate player death
	player.take_damage(9999)

	assert_true(received, "PLAYER_DIED event should be emitted")
	assert_eq(event_data.cause, "damage", "Death cause should be recorded")
```

## Summary

**Use Direct Signals When:**
- Components are closely related
- High performance needed
- Type safety important
- Connections should be explicit

**Use EventBus When:**
- Systems are loosely coupled
- Multiple unrelated listeners needed
- Debugging/analytics required
- Cross-scene communication

**Golden Rule**: Start with direct signals. Move to EventBus only when decoupling is clearly beneficial.
