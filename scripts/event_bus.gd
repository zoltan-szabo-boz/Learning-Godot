extends Node

## EventBus - Centralized event management system
##
## Use EventBus for GLOBAL events that cross multiple systems:
## - Game state changes (pause, game over, level complete)
## - Achievement/stat tracking
## - Cross-scene communication
## - UI updates from gameplay
##
## DO NOT use EventBus for:
## - Parent-child communication (use direct signals)
## - Closely coupled components (use direct signals)
## - High-frequency events (use direct signals for performance)
##
## Event naming convention: CATEGORY_ACTION
## Examples: PLAYER_DIED, UI_MENU_OPENED, GAME_PAUSED, ACHIEVEMENT_UNLOCKED

# Event metadata for tracking and debugging
class EventMetadata:
	var name: String
	var timestamp: float
	var data: Dictionary

	func _init(event_name: String, event_data: Dictionary = {}):
		name = event_name
		timestamp = Time.get_ticks_msec() / 1000.0
		data = event_data

# Listener wrapper with priority and filters
class EventListener:
	var callback: Callable
	var priority: int = 0  # Higher priority = called first
	var filter: Callable = Callable()  # Optional filter: func(data) -> bool
	var one_shot: bool = false  # Remove after first call

	func _init(cb: Callable, prio: int = 0, filt: Callable = Callable(), one: bool = false):
		callback = cb
		priority = prio
		filter = filt
		one_shot = one

# Registry of all event listeners: event_name -> Array[EventListener]
var _listeners: Dictionary = {}

# Event history for debugging (last N events)
var _event_history: Array[EventMetadata] = []
var _max_history_size: int = 50

# Debouncing: event_name -> timestamp of last emission
var _debounce_timers: Dictionary = {}

# Statistics
var _stats_enabled: bool = false
var _event_counts: Dictionary = {}  # event_name -> count

## Subscribe to an event with optional priority and filtering.
##
## [param event_name]: Name of the event to listen for
## [param callback]: Function to call when event fires: func(data: Dictionary)
## [param priority]: Higher priority callbacks are invoked first (default: 0)
## [param filter]: Optional filter function: func(data: Dictionary) -> bool
## [param one_shot]: If true, listener is removed after first invocation
##
## Example:
##   EventBus.subscribe("PLAYER_DIED", _on_player_died)
##   EventBus.subscribe("ENEMY_SPAWNED", _on_enemy_spawned, 10)  # High priority
##   EventBus.subscribe("DAMAGE_TAKEN", _on_damage, 0, func(d): return d.amount > 50)
func subscribe(event_name: String, callback: Callable, priority: int = 0, filter: Callable = Callable(), one_shot: bool = false) -> void:
	if not _listeners.has(event_name):
		_listeners[event_name] = []

	var listener = EventListener.new(callback, priority, filter, one_shot)
	_listeners[event_name].append(listener)

	# Sort by priority (descending)
	_listeners[event_name].sort_custom(func(a, b): return a.priority > b.priority)

## Unsubscribe from an event.
##
## [param event_name]: Name of the event
## [param callback]: The callback function to remove
func unsubscribe(event_name: String, callback: Callable) -> void:
	if not _listeners.has(event_name):
		return

	_listeners[event_name] = _listeners[event_name].filter(
		func(listener): return listener.callback != callback
	)

	# Clean up empty listener arrays
	if _listeners[event_name].is_empty():
		_listeners.erase(event_name)

## Unsubscribe all listeners for an event.
##
## [param event_name]: Name of the event to clear
func unsubscribe_all(event_name: String) -> void:
	_listeners.erase(event_name)

## Emit an event to all subscribed listeners.
##
## [param event_name]: Name of the event to emit
## [param data]: Optional data dictionary to pass to listeners
##
## Example:
##   EventBus.emit("PLAYER_DIED", {"position": player.position, "cause": "fall"})
func emit(event_name: String, data: Dictionary = {}) -> void:
	# Record in history
	_record_event(event_name, data)

	# Update stats
	if _stats_enabled:
		_event_counts[event_name] = _event_counts.get(event_name, 0) + 1

	# Get listeners
	if not _listeners.has(event_name):
		return

	var listeners = _listeners[event_name].duplicate()  # Copy to allow modifications during iteration
	var to_remove: Array[EventListener] = []

	for listener in listeners:
		# Skip if callback is invalid
		if not listener.callback or not listener.callback.is_valid():
			continue

		# Apply filter if provided
		if listener.filter and listener.filter.is_valid():
			if not listener.filter.call(data):
				continue

		# Call the callback
		listener.callback.call(data)

		# Mark one-shot listeners for removal
		if listener.one_shot:
			to_remove.append(listener)

	# Remove one-shot listeners
	for listener in to_remove:
		_listeners[event_name].erase(listener)

## Emit event with debouncing (prevents rapid-fire emissions).
##
## [param event_name]: Name of the event to emit
## [param data]: Optional data dictionary
## [param debounce_time]: Minimum time between emissions (seconds)
##
## Returns true if event was emitted, false if debounced.
func emit_debounced(event_name: String, data: Dictionary = {}, debounce_time: float = 0.1) -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	var last_emit = _debounce_timers.get(event_name, 0.0)

	if current_time - last_emit < debounce_time:
		return false  # Debounced

	_debounce_timers[event_name] = current_time
	emit(event_name, data)
	return true

## Emit event after a delay.
##
## [param event_name]: Name of the event to emit
## [param data]: Optional data dictionary
## [param delay]: Delay in seconds before emission
func emit_delayed(event_name: String, data: Dictionary = {}, delay: float = 0.0) -> void:
	await get_tree().create_timer(delay).timeout
	emit(event_name, data)

## Check if an event has any listeners.
##
## [param event_name]: Name of the event to check
##
## Returns true if the event has at least one listener.
func has_listeners(event_name: String) -> bool:
	return _listeners.has(event_name) and not _listeners[event_name].is_empty()

## Get the number of listeners for an event.
##
## [param event_name]: Name of the event
##
## Returns the listener count.
func get_listener_count(event_name: String) -> int:
	if not _listeners.has(event_name):
		return 0
	return _listeners[event_name].size()

## Get all registered event names.
##
## Returns an array of event name strings.
func get_registered_events() -> Array:
	return _listeners.keys()

## Enable/disable event statistics tracking.
func set_stats_enabled(enabled: bool) -> void:
	_stats_enabled = enabled
	if not enabled:
		_event_counts.clear()

## Get event statistics (call counts).
##
## Returns a dictionary of event_name -> count.
func get_stats() -> Dictionary:
	return _event_counts.duplicate()

## Get recent event history for debugging.
##
## [param count]: Number of recent events to retrieve (default: all)
##
## Returns array of EventMetadata.
func get_event_history(count: int = -1) -> Array[EventMetadata]:
	if count < 0 or count >= _event_history.size():
		return _event_history.duplicate()
	return _event_history.slice(-count)

## Clear event history.
func clear_history() -> void:
	_event_history.clear()

## Clear debounce timers (useful for testing).
func clear_debounce_timers() -> void:
	_debounce_timers.clear()

## Print debug information about registered events.
func print_debug_info() -> void:
	print("=== EventBus Debug Info ===")
	print("Registered events: %d" % _listeners.size())

	for event_name in _listeners.keys():
		var listener_count = _listeners[event_name].size()
		print("  %s: %d listeners" % [event_name, listener_count])

	if _stats_enabled and not _event_counts.is_empty():
		print("\nEvent Statistics:")
		for event_name in _event_counts.keys():
			print("  %s: %d emissions" % [event_name, _event_counts[event_name]])

	print("========================")

# Internal: Record event in history
func _record_event(event_name: String, data: Dictionary) -> void:
	var metadata = EventMetadata.new(event_name, data)
	_event_history.append(metadata)

	# Limit history size
	if _event_history.size() > _max_history_size:
		_event_history.pop_front()
