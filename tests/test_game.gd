extends GutTest

# Test suite for the game scene
# Run via GUT panel in Godot editor or command line

var game_scene = preload("res://scenes/game.tscn")
var game: Node2D

# Setup runs before each test
func before_each():
	game = game_scene.instantiate()
	add_child(game)

# Teardown runs after each test
func after_each():
	game.queue_free()

# Test: Game scene loads successfully
func test_game_scene_loads():
	assert_not_null(game, "Game scene should load")
	assert_true(game is Node2D, "Game scene should be a Node2D")

# Test: Game has a back button
func test_game_has_back_button():
	var back_button = game.get_node_or_null("Button")

	assert_not_null(back_button, "Back button should exist in game scene")
	if back_button:
		assert_true(back_button is Button, "Back button should be a Button node")

# Test: Back button has correct text
func test_back_button_text():
	var back_button = game.get_node_or_null("Button")

	if back_button:
		assert_eq(back_button.text, "Back", "Back button should say 'Back'")

# Test: Back button is connected to scene change
func test_back_button_connected():
	var back_button = game.get_node_or_null("Button")

	if back_button:
		var connections = back_button.pressed.get_connections()
		assert_gt(connections.size(), 0, "Back button should have signal connections")

# Test: Game scene has label
func test_game_has_label():
	var label = game.get_node_or_null("Label")

	assert_not_null(label, "Game scene should have a Label")
	if label:
		assert_eq(label.text, "Game", "Label should say 'Game'")
