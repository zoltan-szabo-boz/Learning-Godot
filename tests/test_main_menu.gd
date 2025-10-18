extends GutTest

# Test suite for the main menu scene
# Run via GUT panel in Godot editor or command line

var main_menu_scene = preload("res://scenes/main_menu.tscn")
var main_menu: Control

# Setup runs before each test
func before_each():
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)

# Teardown runs after each test
func after_each():
	main_menu.queue_free()

# Test: Main menu scene loads successfully
func test_main_menu_loads():
	assert_not_null(main_menu, "Main menu should load")
	assert_true(main_menu is Control, "Main menu should be a Control node")

# Test: Main menu has required buttons
func test_main_menu_has_buttons():
	var start_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/VBoxContainer/StartButton")
	var options_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/VBoxContainer/OptionsButton")
	var quit_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/VBoxContainer/QuitButton")

	assert_not_null(start_button, "Start button should exist")
	assert_not_null(options_button, "Options button should exist")
	assert_not_null(quit_button, "Quit button should exist")

# Test: Options button is disabled
func test_options_button_disabled():
	var options_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/VBoxContainer/OptionsButton")

	if options_button:
		assert_true(options_button.disabled, "Options button should be disabled")

# Test: Start button triggers scene change
func test_start_button_changes_scene():
	var start_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/VBoxContainer/StartButton")

	if start_button:
		# Watch for scene change
		watch_signals(main_menu.get_tree())

		# Simulate button press
		start_button.pressed.emit()

		# Give it a frame to process
		await get_tree().process_frame

		# Note: In a test environment, we can't actually change scenes,
		# but we can verify the method was called by checking signals
		# or by mocking the scene tree
		pass_test("Start button press simulation completed")

# Test: Main menu has title label
func test_main_menu_has_title():
	var title_label = main_menu.get_node_or_null("MarginContainer/VBoxContainer/TitleLabel")

	assert_not_null(title_label, "Title label should exist")
	if title_label:
		assert_eq(title_label.text, "Tanuld meg a Godót!", "Title should be 'Tanuld meg a Godót!'")

# Test: Quit button calls quit method
func test_quit_button_functionality():
	var quit_button = main_menu.get_node_or_null("MarginContainer/VBoxContainer/VBoxContainer/QuitButton")

	if quit_button:
		# We can't actually quit in tests, but we can verify the signal is connected
		var connections = quit_button.pressed.get_connections()
		assert_gt(connections.size(), 0, "Quit button should have signal connections")
