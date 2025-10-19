# EventBus Events Reference

This document lists all events emitted through the EventBus system and their payloads.

## Overview

The EventBus provides a centralized event system for cross-system communication. Events are emitted with a string identifier and an optional payload dictionary.

**Subscribe to events:**
```gdscript
EventBus.subscribe("event_name", callback_function)
```

**Unsubscribe:**
```gdscript
EventBus.unsubscribe("event_name", callback_function)
```

**Emit events:**
```gdscript
EventBus.emit("event_name", {"key": "value"})
```

## System Events

### language_changed

**Emitted by:** `LocalizationManager`

**When:** User changes the language or language is loaded from config

**Payload:**
```gdscript
{
	"locale": String  # Language code (e.g., "en", "de", "hu", "ja")
}
```

**Example Usage:**
```gdscript
func _ready():
	EventBus.subscribe("language_changed", _on_language_changed)

func _exit_tree():
	EventBus.unsubscribe("language_changed", _on_language_changed)

func _on_language_changed(data: Dictionary):
	var new_locale = data.locale
	print("Language changed to: " + new_locale)
	# Update your UI, reload text, etc.
```

**Use Cases:**
- Updating UI text in real-time
- Reloading localized assets
- Refreshing tooltips with new translations
- Analytics tracking

---

## Future Events

Document new events here as they are added to the system.

### Template

```markdown
### event_name

**Emitted by:** `SystemName`

**When:** Description of when this event fires

**Payload:**
```gdscript
{
	"field1": Type,  # Description
	"field2": Type   # Description
}
```

**Example Usage:**
```gdscript
func _ready():
	EventBus.subscribe("event_name", _on_event)

func _on_event(data: Dictionary):
	# Handle event
	pass
```

**Use Cases:**
- Use case 1
- Use case 2
```

---

## Best Practices

### When to Create New Events

Create EventBus events for:
- ✅ Cross-system communication (multiple systems need to react)
- ✅ Game state changes (level loaded, player died, settings changed)
- ✅ Achievement/analytics tracking
- ✅ Global UI updates (theme changed, language changed)

Avoid EventBus for:
- ❌ Parent-child communication (use direct signals)
- ❌ High-frequency events (every frame updates)
- ❌ Tightly-coupled components (use direct signals)

See `docs/event_architecture.md` for detailed guidelines.

### Event Naming

Follow these conventions:

**Format:** `system_action` or `entity_state_changed`

**Examples:**
- `language_changed` ✅
- `player_died` ✅
- `level_loaded` ✅
- `settings_saved` ✅
- `achievement_unlocked` ✅

**Avoid:**
- `onLanguageChange` ❌ (use snake_case)
- `LANGUAGE_CHANGED` ❌ (not constants)
- `language` ❌ (not descriptive)

### Payload Structure

Always use a Dictionary, even for single values:

**Good:**
```gdscript
EventBus.emit("player_died", {"position": player_pos, "cause": "fall_damage"})
```

**Bad:**
```gdscript
EventBus.emit("player_died", player_pos)  # Not a dictionary
```

**Why?** Allows adding more data later without breaking existing subscribers.

### Unsubscribe on Exit

Always unsubscribe in `_exit_tree()` to prevent memory leaks:

```gdscript
func _ready():
	EventBus.subscribe("language_changed", _on_language_changed)

func _exit_tree():
	EventBus.unsubscribe("language_changed", _on_language_changed)
```

### Type Hints

Use type hints for clarity:

```gdscript
func _on_language_changed(data: Dictionary) -> void:
	var locale: String = data.locale
	# ...
```

### Error Handling

Validate payload data:

```gdscript
func _on_language_changed(data: Dictionary) -> void:
	if not data.has("locale"):
		push_error("language_changed event missing 'locale' field")
		return

	var locale: String = data.locale
	# Safe to use locale
```

---

## Migration from Direct Signals

If refactoring existing code from direct signals to EventBus:

### Before (Direct Signal)
```gdscript
# In manager
signal language_changed(locale: String)

func set_language(locale: String):
	language_changed.emit(locale)

# In consumer
func _ready():
	LocalizationManager.language_changed.connect(_on_language_changed)

func _on_language_changed(locale: String):
	# Handle
	pass
```

### After (EventBus)
```gdscript
# In manager
func set_language(locale: String):
	EventBus.emit("language_changed", {"locale": locale})

# In consumer
func _ready():
	EventBus.subscribe("language_changed", _on_language_changed)

func _exit_tree():
	EventBus.unsubscribe("language_changed", _on_language_changed)

func _on_language_changed(data: Dictionary):
	var locale: String = data.locale
	# Handle
	pass
```

**Key Changes:**
1. Manager emits via EventBus with Dictionary payload
2. Consumer subscribes instead of connect
3. Consumer unsubscribes in `_exit_tree()`
4. Callback receives Dictionary instead of direct parameters

---

## Debugging Events

### List All Subscriptions

```gdscript
# In console or debug script
var stats = EventBus.get_event_stats("language_changed")
print("Subscribers: ", stats.subscriber_count)
```

### Monitor Event History

EventBus keeps a history of recent events (configurable):

```gdscript
# Enable detailed logging
EventBus._debug_mode = true  # If you add this feature

# Or check history
var history = EventBus.get_event_history()
for event in history:
	print("Event: %s, Payload: %s" % [event.name, event.payload])
```

---

## Performance Considerations

### Event Frequency

EventBus is optimized for occasional events, not high-frequency updates.

**Good for:**
- Language changes (user-initiated, rare)
- Level transitions (occasional)
- Achievement unlocks (sporadic)

**Bad for:**
- Player position updates (every frame)
- Mouse movement tracking (every frame)
- Physics updates (every physics step)

For high-frequency updates, use direct signals or direct method calls.

### Priority System

EventBus supports priority ordering:

```gdscript
# Higher priority executes first
EventBus.subscribe("language_changed", _critical_update, 100)
EventBus.subscribe("language_changed", _normal_update, 0)
EventBus.subscribe("language_changed", _low_priority_update, -100)
```

Use priorities when order matters (e.g., update data before UI).

---

## Testing Events

### Unit Test Example

```gdscript
extends GutTest

func test_language_changed_event():
	var received_data = null

	# Subscribe to event
	var callback = func(data: Dictionary):
		received_data = data

	EventBus.subscribe("language_changed", callback)

	# Trigger language change
	LocalizationManager.set_language("de")

	# Wait a frame for event processing
	await get_tree().process_frame

	# Verify event was received
	assert_not_null(received_data, "Should receive event data")
	assert_eq(received_data.locale, "de", "Locale should be 'de'")

	# Cleanup
	EventBus.unsubscribe("language_changed", callback)
```

---

## Additional Resources

- **EventBus Implementation:** `scripts/event_bus.gd`
- **Architecture Guide:** `docs/event_architecture.md`
- **Usage Examples:** See `scripts/main_menu.gd` for real-world usage
- **CLAUDE.md:** Project guidelines on EventBus vs Direct Signals
