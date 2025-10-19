extends GutTest

# Test suite for LocalizationManager
# Tests language switching, persistence, and translation functionality

var initial_locale: String

# Setup runs before each test
func before_each():
	# Store initial locale to restore after tests
	initial_locale = LocalizationManager.current_language

# Teardown runs after each test
func after_each():
	# Restore initial locale
	LocalizationManager.set_language(initial_locale)

# Test: LocalizationManager is loaded as singleton
func test_localization_manager_exists():
	assert_not_null(LocalizationManager, "LocalizationManager should exist as singleton")

# Test: Available languages are defined
func test_available_languages_defined():
	var languages = LocalizationManager.get_available_languages()

	assert_not_null(languages, "Available languages should be defined")
	assert_gt(languages.size(), 0, "Should have at least one language")

# Test: Language codes are correct
func test_language_codes():
	var languages = LocalizationManager.get_available_languages()
	var codes = []

	for lang in languages:
		codes.append(lang.code)

	assert_true(codes.has("en"), "Should have English (en)")
	assert_true(codes.has("hu"), "Should have Hungarian (hu)")

# Test: Current language is set
func test_current_language_is_set():
	var current = LocalizationManager.get_language()

	assert_not_null(current, "Current language should be set")
	assert_true(current == "en" or current == "hu", "Current language should be 'en' or 'hu'")

# Test: Change language to English
func test_change_language_to_english():
	LocalizationManager.set_language("en")

	assert_eq(LocalizationManager.get_language(), "en", "Language should be set to English")
	assert_eq(TranslationServer.get_locale(), "en", "TranslationServer locale should be 'en'")

# Test: Change language to Hungarian
func test_change_language_to_hungarian():
	LocalizationManager.set_language("hu")

	assert_eq(LocalizationManager.get_language(), "hu", "Language should be set to Hungarian")
	assert_eq(TranslationServer.get_locale(), "hu", "TranslationServer locale should be 'hu'")

# Test: Invalid language code is rejected
# Note: This test validates that setting an invalid language doesn't change the current language
# The warning logged by LocalizationManager is expected behavior
func test_invalid_language_rejected():
	# Set to a known valid language first
	LocalizationManager.set_language("en")
	var before_invalid = LocalizationManager.get_language()

	# Try to set invalid language - this will log a warning but shouldn't change the language
	LocalizationManager.set_language("invalid")

	# Language should remain unchanged
	assert_eq(LocalizationManager.get_language(), before_invalid, "Invalid language should not change current language")

# Test: Language changed signal is emitted
func test_language_changed_signal():
	watch_signals(LocalizationManager)

	LocalizationManager.set_language("en")

	assert_signal_emitted(LocalizationManager, "language_changed", "Signal should be emitted when language changes")

# Test: Language changed signal contains correct locale
func test_language_changed_signal_parameters():
	watch_signals(LocalizationManager)

	LocalizationManager.set_language("hu")

	# Verify signal was emitted
	assert_signal_emitted(LocalizationManager, "language_changed", "Signal should be emitted")

	# Get the signal parameters manually and check them
	var signal_params = get_signal_parameters(LocalizationManager, "language_changed", 0)
	if signal_params != null and signal_params.size() > 0:
		assert_eq(signal_params[0], "hu", "Signal parameter should be 'hu'")

# Test: Translation works for English
func test_translation_english():
	LocalizationManager.set_language("en")

	var translated = tr("GAME_TITLE")
	assert_eq(translated, "Learn Godot!", "GAME_TITLE should translate to 'Learn Godot!' in English")

	var button = tr("BUTTON_START_GAME")
	assert_eq(button, "Start Game", "BUTTON_START_GAME should translate to 'Start Game' in English")

# Test: Translation works for Hungarian
func test_translation_hungarian():
	LocalizationManager.set_language("hu")

	var translated = tr("GAME_TITLE")
	assert_eq(translated, "Tanuld meg a Godót!", "GAME_TITLE should translate to 'Tanuld meg a Godót!' in Hungarian")

	var button = tr("BUTTON_START_GAME")
	assert_eq(button, "Játék indítása", "BUTTON_START_GAME should translate to 'Játék indítása' in Hungarian")

# Test: Translation with string formatting works
func test_translation_with_formatting():
	LocalizationManager.set_language("en")

	var message = tr("MESSAGE_RESOLUTION_CHANGED") % [1920, 1080]
	assert_eq(message, "Changing resolution to 1920x1080", "String formatting with tr() should work")

# Test: Missing translation key returns key itself
func test_missing_translation_key():
	var translated = tr("NONEXISTENT_KEY")
	assert_eq(translated, "NONEXISTENT_KEY", "Missing translation key should return the key itself")

# Test: Get language name by code
func test_get_language_name():
	var english_name = LocalizationManager.get_language_name("en")
	assert_eq(english_name, "English", "English language name should be 'English'")

	var hungarian_name = LocalizationManager.get_language_name("hu")
	assert_eq(hungarian_name, "Magyar", "Hungarian language name should be 'Magyar'")

# Test: Get language name for unknown code
func test_get_language_name_unknown():
	var unknown_name = LocalizationManager.get_language_name("unknown")
	assert_eq(unknown_name, "Unknown", "Unknown language code should return 'Unknown'")

# Test: Language persistence (saved to config)
func test_language_persistence():
	# Change language (this automatically saves to config)
	LocalizationManager.set_language("hu")

	# Wait a frame for file operations to complete
	await get_tree().process_frame

	# Read config directly to verify (file was already flushed by set_language)
	var config_data = FileManager.read_config_file("user://config.cfg")

	assert_true(config_data.has("localization"), "Config should have localization section")
	if config_data.has("localization"):
		assert_eq(config_data.localization.language, "hu", "Saved language should be 'hu'")

# Test: Switch language multiple times
func test_multiple_language_switches():
	LocalizationManager.set_language("en")
	assert_eq(LocalizationManager.get_language(), "en", "Should switch to English")

	LocalizationManager.set_language("hu")
	assert_eq(LocalizationManager.get_language(), "hu", "Should switch to Hungarian")

	LocalizationManager.set_language("en")
	assert_eq(LocalizationManager.get_language(), "en", "Should switch back to English")

# Test: All translation keys exist in both languages
func test_all_keys_exist_in_both_languages():
	var test_keys = [
		"GAME_TITLE",
		"BUTTON_START_GAME",
		"BUTTON_OPTIONS",
		"BUTTON_QUIT",
		"OPTIONS_TITLE",
		"LABEL_RESOLUTION",
		"BUTTON_FULLSCREEN",
		"LABEL_LANGUAGE"
	]

	# Test English
	LocalizationManager.set_language("en")
	for key in test_keys:
		var translated = tr(key)
		assert_ne(translated, key, "Key '%s' should have English translation" % key)

	# Test Hungarian
	LocalizationManager.set_language("hu")
	for key in test_keys:
		var translated = tr(key)
		assert_ne(translated, key, "Key '%s' should have Hungarian translation" % key)
