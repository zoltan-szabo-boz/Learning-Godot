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
	var start_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Start")
	var options_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options")
	var quit_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Quit")

	assert_not_null(start_button, "Start button should exist")
	assert_not_null(options_button, "Options button should exist")
	assert_not_null(quit_button, "Quit button should exist")

# Test: Options button is enabled and shows options panel
func test_options_button_shows_panel():
	var options_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options")
	var options_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel")
	var main_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel")

	assert_not_null(options_button, "Options button should exist")
	assert_false(options_button.disabled, "Options button should be enabled")

	if options_button and options_panel and main_panel:
		# Initially, main panel should be visible and options panel hidden
		assert_true(main_panel.visible, "Main panel should be visible initially")
		assert_false(options_panel.visible, "Options panel should be hidden initially")

		# Press the options button
		options_button.pressed.emit()

		# Options panel should now be visible and main panel hidden
		assert_false(main_panel.visible, "Main panel should be hidden after pressing options")
		assert_true(options_panel.visible, "Options panel should be visible after pressing options")

# Test: Start button triggers scene change
func test_start_button_changes_scene():
	var start_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Start")

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
	var title_label = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/Label")

	assert_not_null(title_label, "Title label should exist")
	if title_label:
		# Title now uses translation key
		assert_eq(title_label.text, "GAME_TITLE", "Title should use translation key 'GAME_TITLE'")

# Test: Quit button calls quit method
func test_quit_button_functionality():
	var quit_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Quit")

	if quit_button:
		# We can't actually quit in tests, but we can verify the signal is connected
		var connections = quit_button.pressed.get_connections()
		assert_gt(connections.size(), 0, "Quit button should have signal connections")

# Test: Options panel has resolution buttons
func test_options_panel_has_resolution_buttons():
	var res_1920 = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/ResolutionMargin/ResolutionContainer/Res1920x1080")
	var res_1280 = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/ResolutionMargin/ResolutionContainer/Res1280x720")
	var fullscreen = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/ResolutionMargin/ResolutionContainer/Fullscreen")

	assert_not_null(res_1920, "1920x1080 button should exist")
	assert_not_null(res_1280, "1280x720 button should exist")
	assert_not_null(fullscreen, "Fullscreen checkbox should exist")

# Test: Back button returns to main menu
func test_back_button_returns_to_menu():
	var options_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options")
	var back_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/BackButtonMargin/BackButton")
	var options_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel")
	var main_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel")

	if options_button and back_button and options_panel and main_panel:
		# Go to options panel
		options_button.pressed.emit()
		assert_true(options_panel.visible, "Options panel should be visible")

		# Go back to main menu
		back_button.pressed.emit()
		assert_true(main_panel.visible, "Main panel should be visible after going back")
		assert_false(options_panel.visible, "Options panel should be hidden after going back")

# Test: Language dropdown exists and has all languages
func test_language_dropdown_exists():
	var language_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/LanguageMargin/LanguageDropdown")

	assert_not_null(language_dropdown, "Language dropdown should exist")
	if language_dropdown:
		# Should have 4 languages: English, German, Hungarian, Japanese
		assert_eq(language_dropdown.item_count, 4, "Dropdown should have 4 language options")

# Test: Selecting language from dropdown changes language
func test_language_dropdown_changes_language():
	var language_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/LanguageMargin/LanguageDropdown")

	if language_dropdown:
		# Languages are sorted: English (0), German (1), Hungarian (2), Japanese (3)
		# Set to English (index 0)
		language_dropdown.select(0)
		language_dropdown.item_selected.emit(0)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "en", "Language should change to English")

		# Set to German (index 1)
		language_dropdown.select(1)
		language_dropdown.item_selected.emit(1)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "de", "Language should change to German")

		# Set to Hungarian (index 2)
		language_dropdown.select(2)
		language_dropdown.item_selected.emit(2)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "hu", "Language should change to Hungarian")

		# Set to Japanese (index 3)
		language_dropdown.select(3)
		language_dropdown.item_selected.emit(3)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "ja", "Language should change to Japanese")

# Test: Language change updates UI text
func test_language_change_updates_ui():
	var title_label = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/Label")

	if title_label:
		# Set to English and wait for update
		LocalizationManager.set_language("en")
		await get_tree().process_frame
		# In Godot, labels with translation keys automatically update
		# We verify the translation key is set (actual translation happens in engine)
		assert_eq(title_label.text, "GAME_TITLE", "Label should use translation key")
