extends GutTest

## Unit tests for EventBus singleton
##
## Tests cover:
## - Basic subscribe/emit/unsubscribe
## - Multiple listeners
## - Priority ordering
## - Event filtering
## - One-shot listeners
## - Debouncing
## - Delayed events
## - Event history
## - Statistics

var test_callback_called: bool = false
var test_callback_data: Dictionary = {}
var test_callback_count: int = 0

func before_each():
	# Reset test state
	test_callback_called = false
	test_callback_data = {}
	test_callback_count = 0

	# Clear EventBus state
	for event_name in EventBus.get_registered_events():
		EventBus.unsubscribe_all(event_name)
	EventBus.clear_history()
	EventBus.clear_debounce_timers()
	EventBus.set_stats_enabled(false)

func after_each():
	# Clean up all test listeners
	for event_name in EventBus.get_registered_events():
		EventBus.unsubscribe_all(event_name)

## Basic Functionality Tests

func test_eventbus_exists():
	assert_not_null(EventBus, "EventBus singleton should exist")

func test_subscribe_and_emit():
	EventBus.subscribe("TEST_EVENT", _test_callback)
	EventBus.emit("TEST_EVENT", {"value": 42})

	assert_true(test_callback_called, "Callback should be called")
	assert_eq(test_callback_data.value, 42, "Callback should receive correct data")

func test_unsubscribe():
	EventBus.subscribe("TEST_EVENT", _test_callback)
	EventBus.unsubscribe("TEST_EVENT", _test_callback)
	EventBus.emit("TEST_EVENT", {})

	assert_false(test_callback_called, "Callback should not be called after unsubscribe")

func test_emit_without_listeners():
	# Should not crash
	EventBus.emit("NONEXISTENT_EVENT", {})
	assert_true(true, "Emitting event without listeners should not crash")

func test_multiple_listeners():
	var callbacks_called = [false, false]  # Use array for reference semantics

	EventBus.subscribe("TEST_EVENT", func(data): callbacks_called[0] = true)
	EventBus.subscribe("TEST_EVENT", func(data): callbacks_called[1] = true)

	EventBus.emit("TEST_EVENT", {})

	assert_true(callbacks_called[0], "First callback should be called")
	assert_true(callbacks_called[1], "Second callback should be called")

func test_listener_count():
	assert_eq(EventBus.get_listener_count("TEST_EVENT"), 0, "Should start with 0 listeners")

	EventBus.subscribe("TEST_EVENT", _test_callback)
	assert_eq(EventBus.get_listener_count("TEST_EVENT"), 1, "Should have 1 listener")

	EventBus.subscribe("TEST_EVENT", func(d): pass)
	assert_eq(EventBus.get_listener_count("TEST_EVENT"), 2, "Should have 2 listeners")

	EventBus.unsubscribe("TEST_EVENT", _test_callback)
	assert_eq(EventBus.get_listener_count("TEST_EVENT"), 1, "Should have 1 listener after unsubscribe")

func test_has_listeners():
	assert_false(EventBus.has_listeners("TEST_EVENT"), "Should not have listeners initially")

	EventBus.subscribe("TEST_EVENT", _test_callback)
	assert_true(EventBus.has_listeners("TEST_EVENT"), "Should have listeners after subscribe")

	EventBus.unsubscribe("TEST_EVENT", _test_callback)
	assert_false(EventBus.has_listeners("TEST_EVENT"), "Should not have listeners after unsubscribe")

func test_unsubscribe_all():
	EventBus.subscribe("TEST_EVENT", _test_callback)
	EventBus.subscribe("TEST_EVENT", func(d): pass)
	EventBus.subscribe("TEST_EVENT", func(d): pass)

	assert_eq(EventBus.get_listener_count("TEST_EVENT"), 3, "Should have 3 listeners")

	EventBus.unsubscribe_all("TEST_EVENT")
	assert_eq(EventBus.get_listener_count("TEST_EVENT"), 0, "Should have 0 listeners after unsubscribe_all")

func test_get_registered_events():
	var events = EventBus.get_registered_events()
	assert_eq(events.size(), 0, "Should start with no registered events")

	EventBus.subscribe("EVENT_1", _test_callback)
	EventBus.subscribe("EVENT_2", _test_callback)

	events = EventBus.get_registered_events()
	assert_eq(events.size(), 2, "Should have 2 registered events")
	assert_true("EVENT_1" in events, "Should include EVENT_1")
	assert_true("EVENT_2" in events, "Should include EVENT_2")

## Priority Tests

func test_priority_ordering():
	var call_order = []

	EventBus.subscribe("TEST_EVENT", func(d): call_order.append("low"), 0)
	EventBus.subscribe("TEST_EVENT", func(d): call_order.append("high"), 100)
	EventBus.subscribe("TEST_EVENT", func(d): call_order.append("medium"), 50)

	EventBus.emit("TEST_EVENT", {})

	assert_eq(call_order.size(), 3, "All callbacks should be called")
	assert_eq(call_order[0], "high", "High priority should be called first")
	assert_eq(call_order[1], "medium", "Medium priority should be called second")
	assert_eq(call_order[2], "low", "Low priority should be called third")

func test_priority_same_value():
	var call_count = [0]  # Use array for reference semantics

	EventBus.subscribe("TEST_EVENT", func(d): call_count[0] += 1, 10)
	EventBus.subscribe("TEST_EVENT", func(d): call_count[0] += 1, 10)
	EventBus.subscribe("TEST_EVENT", func(d): call_count[0] += 1, 10)

	EventBus.emit("TEST_EVENT", {})

	assert_eq(call_count[0], 3, "All same-priority callbacks should be called")

## Filtering Tests

func test_filter_basic():
	var calls = {"filtered": false, "unfiltered": false}  # Use dict for reference semantics

	# Only accept events where value > 50
	EventBus.subscribe(
		"TEST_EVENT",
		func(d): calls["filtered"] = true,
		0,
		func(d): return d.get("value", 0) > 50
	)

	EventBus.subscribe("TEST_EVENT", func(d): calls["unfiltered"] = true)

	# Emit with value = 30 (should not pass filter)
	EventBus.emit("TEST_EVENT", {"value": 30})

	assert_false(calls["filtered"], "Filtered callback should not be called")
	assert_true(calls["unfiltered"], "Unfiltered callback should be called")

	# Reset
	calls["filtered"] = false
	calls["unfiltered"] = false

	# Emit with value = 60 (should pass filter)
	EventBus.emit("TEST_EVENT", {"value": 60})

	assert_true(calls["filtered"], "Filtered callback should be called")
	assert_true(calls["unfiltered"], "Unfiltered callback should be called")

func test_filter_string_matching():
	var spawns = {"boss": false, "any": false}  # Use dict for reference semantics

	# Filter for boss enemies only
	EventBus.subscribe(
		"ENEMY_SPAWNED",
		func(d): spawns["boss"] = true,
		0,
		func(d): return d.get("type", "") == "boss"
	)

	EventBus.subscribe("ENEMY_SPAWNED", func(d): spawns["any"] = true)

	# Spawn a goblin
	EventBus.emit("ENEMY_SPAWNED", {"type": "goblin"})
	assert_false(spawns["boss"], "Boss callback should not trigger for goblin")
	assert_true(spawns["any"], "Any callback should trigger")

	# Reset
	spawns["boss"] = false
	spawns["any"] = false

	# Spawn a boss
	EventBus.emit("ENEMY_SPAWNED", {"type": "boss"})
	assert_true(spawns["boss"], "Boss callback should trigger for boss")
	assert_true(spawns["any"], "Any callback should trigger")

## One-Shot Tests

func test_one_shot_listener():
	EventBus.subscribe("TEST_EVENT", _test_callback_counter, 0, Callable(), true)

	EventBus.emit("TEST_EVENT", {})
	assert_eq(test_callback_count, 1, "Callback should be called once")

	EventBus.emit("TEST_EVENT", {})
	assert_eq(test_callback_count, 1, "One-shot callback should not be called again")

func test_one_shot_multiple_listeners():
	var counts = [0, 0]  # Use array for reference semantics [oneshot, permanent]

	EventBus.subscribe("TEST_EVENT", func(d): counts[0] += 1, 0, Callable(), true)
	EventBus.subscribe("TEST_EVENT", func(d): counts[1] += 1, 0, Callable(), false)

	EventBus.emit("TEST_EVENT", {})
	assert_eq(counts[0], 1, "One-shot should be called first time")
	assert_eq(counts[1], 1, "Permanent should be called first time")

	EventBus.emit("TEST_EVENT", {})
	assert_eq(counts[0], 1, "One-shot should not be called again")
	assert_eq(counts[1], 2, "Permanent should be called again")

## Debouncing Tests

func test_debounce_basic():
	var emit_count = [0]  # Use array for reference semantics
	EventBus.subscribe("TEST_EVENT", func(d): emit_count[0] += 1)

	# First emit should succeed
	var result1 = EventBus.emit_debounced("TEST_EVENT", {}, 0.1)
	assert_true(result1, "First emit should succeed")
	assert_eq(emit_count[0], 1, "Callback should be called once")

	# Immediate second emit should be debounced
	var result2 = EventBus.emit_debounced("TEST_EVENT", {}, 0.1)
	assert_false(result2, "Second emit should be debounced")
	assert_eq(emit_count[0], 1, "Callback should not be called again")

func test_debounce_after_timeout():
	var emit_count = [0]  # Use array for reference semantics
	EventBus.subscribe("TEST_EVENT", func(d): emit_count[0] += 1)

	EventBus.emit_debounced("TEST_EVENT", {}, 0.05)
	assert_eq(emit_count[0], 1, "First emit should succeed")

	# Wait longer than debounce time (use multiple frames to ensure time passes)
	await wait_process_frames(10)

	EventBus.emit_debounced("TEST_EVENT", {}, 0.05)
	assert_eq(emit_count[0], 2, "Second emit should succeed after timeout")

## Delayed Event Tests

func test_delayed_event():
	EventBus.subscribe("TEST_EVENT", _test_callback)

	EventBus.emit_delayed("TEST_EVENT", {"value": 99}, 0.05)

	# Should not be called immediately
	assert_false(test_callback_called, "Callback should not be called immediately")

	# Wait for delay (use GUT's wait_seconds)
	await wait_seconds(0.1)

	assert_true(test_callback_called, "Callback should be called after delay")
	assert_eq(test_callback_data.value, 99, "Delayed event should have correct data")

func test_delayed_event_zero_delay():
	EventBus.subscribe("TEST_EVENT", _test_callback)

	EventBus.emit_delayed("TEST_EVENT", {"value": 123}, 0.0)

	# Should not be called immediately (even with 0 delay)
	assert_false(test_callback_called, "Callback should not be called immediately")

	# Wait one frame (use GUT's wait_process_frames)
	await wait_process_frames(1)

	assert_true(test_callback_called, "Callback should be called after one frame")

## Event History Tests

func test_event_history_recording():
	EventBus.emit("EVENT_1", {"data": 1})
	EventBus.emit("EVENT_2", {"data": 2})
	EventBus.emit("EVENT_3", {"data": 3})

	var history = EventBus.get_event_history()
	assert_eq(history.size(), 3, "Should have 3 events in history")

	assert_eq(history[0].name, "EVENT_1", "First event should be EVENT_1")
	assert_eq(history[0].data.data, 1, "First event should have correct data")

	assert_eq(history[1].name, "EVENT_2", "Second event should be EVENT_2")
	assert_eq(history[2].name, "EVENT_3", "Third event should be EVENT_3")

func test_event_history_limit():
	# EventBus has max_history_size of 50
	# Emit more than 50 events
	for i in range(60):
		EventBus.emit("TEST_EVENT", {"index": i})

	var history = EventBus.get_event_history()
	assert_eq(history.size(), 50, "History should be limited to 50 events")

	# Should have the last 50 events (10-59)
	assert_eq(history[0].data.index, 10, "Should have dropped oldest events")
	assert_eq(history[49].data.index, 59, "Should have most recent event")

func test_get_event_history_count():
	EventBus.emit("EVENT_1", {})
	EventBus.emit("EVENT_2", {})
	EventBus.emit("EVENT_3", {})
	EventBus.emit("EVENT_4", {})
	EventBus.emit("EVENT_5", {})

	var recent = EventBus.get_event_history(2)
	assert_eq(recent.size(), 2, "Should get last 2 events")
	assert_eq(recent[0].name, "EVENT_4", "Should be second to last event")
	assert_eq(recent[1].name, "EVENT_5", "Should be last event")

func test_clear_history():
	EventBus.emit("EVENT_1", {})
	EventBus.emit("EVENT_2", {})

	var history = EventBus.get_event_history()
	assert_eq(history.size(), 2, "Should have 2 events before clear")

	EventBus.clear_history()

	history = EventBus.get_event_history()
	assert_eq(history.size(), 0, "History should be empty after clear")

func test_event_history_metadata():
	EventBus.emit("TEST_EVENT", {"key": "value"})

	var history = EventBus.get_event_history()
	assert_eq(history.size(), 1, "Should have 1 event in history")

	var metadata = history[0]
	assert_eq(metadata.name, "TEST_EVENT", "Metadata should have event name")
	assert_true(metadata.timestamp > 0, "Metadata should have timestamp")
	assert_eq(metadata.data.key, "value", "Metadata should have event data")

## Statistics Tests

func test_stats_disabled_by_default():
	var stats = EventBus.get_stats()
	assert_eq(stats.size(), 0, "Stats should be empty when disabled")

func test_stats_tracking():
	EventBus.set_stats_enabled(true)

	EventBus.emit("EVENT_A", {})
	EventBus.emit("EVENT_A", {})
	EventBus.emit("EVENT_B", {})
	EventBus.emit("EVENT_A", {})

	var stats = EventBus.get_stats()
	assert_eq(stats["EVENT_A"], 3, "EVENT_A should have count of 3")
	assert_eq(stats["EVENT_B"], 1, "EVENT_B should have count of 1")

func test_stats_clear_on_disable():
	EventBus.set_stats_enabled(true)
	EventBus.emit("TEST_EVENT", {})
	EventBus.emit("TEST_EVENT", {})

	var stats = EventBus.get_stats()
	assert_eq(stats["TEST_EVENT"], 2, "Should have stats before disable")

	EventBus.set_stats_enabled(false)

	stats = EventBus.get_stats()
	assert_eq(stats.size(), 0, "Stats should be cleared on disable")

## Edge Cases and Error Handling

func test_subscribe_null_callback():
	# Should not crash, but won't be useful
	EventBus.subscribe("TEST_EVENT", Callable())
	EventBus.emit("TEST_EVENT", {})

	# If we get here without crash, test passes
	assert_true(true, "Should handle null callback gracefully")

func test_unsubscribe_nonexistent():
	# Should not crash
	EventBus.unsubscribe("NONEXISTENT_EVENT", _test_callback)
	assert_true(true, "Should handle unsubscribe of nonexistent event")

func test_empty_event_data():
	EventBus.subscribe("TEST_EVENT", _test_callback)
	EventBus.emit("TEST_EVENT")  # No data parameter

	assert_true(test_callback_called, "Callback should be called with empty data")
	assert_eq(test_callback_data.size(), 0, "Data should be empty dictionary")

func test_multiple_subscribe_same_callback():
	# Subscribing same callback multiple times should add multiple listeners
	EventBus.subscribe("TEST_EVENT", _test_callback_counter)
	EventBus.subscribe("TEST_EVENT", _test_callback_counter)

	EventBus.emit("TEST_EVENT", {})

	assert_eq(test_callback_count, 2, "Same callback should be called multiple times")

## Integration Tests

func test_complex_event_flow():
	# Simulate a realistic game scenario
	var states = {"player_died": false, "achievement_unlocked": false, "stats_recorded": false}

	# High priority: Save game
	EventBus.subscribe("PLAYER_DIED", func(d):
		states["stats_recorded"] = true
	, 100)

	# Medium priority: Check achievements
	EventBus.subscribe("PLAYER_DIED", func(d):
		if d.deaths >= 100:
			states["achievement_unlocked"] = true
			EventBus.emit("ACHIEVEMENT_UNLOCKED", {"id": "DIE_HARD"})
	, 50)

	# Low priority: Show UI
	EventBus.subscribe("PLAYER_DIED", func(d):
		states["player_died"] = true
	, 0)

	# Emit player death with 100 deaths
	EventBus.emit("PLAYER_DIED", {"deaths": 100})

	assert_true(states["stats_recorded"], "Stats should be recorded")
	assert_true(states["achievement_unlocked"], "Achievement should be unlocked")
	assert_true(states["player_died"], "UI should be notified")

func test_filter_and_priority_combined():
	var calls = {"high_priority": false, "filtered": false}  # Use dict for reference semantics

	# High priority, no filter
	EventBus.subscribe("TEST_EVENT", func(d): calls["high_priority"] = true, 100)

	# Low priority, with filter
	EventBus.subscribe(
		"TEST_EVENT",
		func(d): calls["filtered"] = true,
		0,
		func(d): return d.get("value", 0) > 50
	)

	# Emit with value that fails filter
	EventBus.emit("TEST_EVENT", {"value": 10})

	assert_true(calls["high_priority"], "High priority should be called")
	assert_false(calls["filtered"], "Filtered should not be called")

	# Reset and try with passing filter
	calls["high_priority"] = false
	calls["filtered"] = false

	EventBus.emit("TEST_EVENT", {"value": 100})

	assert_true(calls["high_priority"], "High priority should be called")
	assert_true(calls["filtered"], "Filtered should be called")

## Helper Methods

func _test_callback(data: Dictionary):
	test_callback_called = true
	test_callback_data = data

func _test_callback_counter(data: Dictionary):
	test_callback_count += 1
