extends Control

@onready var main_menu_panel = $MarginContainer/HBoxContainer/MainMenuPanel
@onready var options_panel = $MarginContainer/HBoxContainer/OptionsPanel
@onready var fullscreen_check = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/ResolutionMargin/ResolutionContainer/Fullscreen
@onready var language_dropdown = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/LanguageMargin/LanguageDropdown

func _ready():
	# Initialize fullscreen checkbox state from config
	fullscreen_check.button_pressed = ConfigManager.config.fullscreen

	# Populate language dropdown
	_populate_language_dropdown()

	# Connect to language change signal to update dropdown translations
	LocalizationManager.language_changed.connect(_on_language_changed)

	_register_tooltips()

func _register_tooltips():
	TooltipManager.register_tooltip(
		$MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Start,
		func(): return tr("BUTTON_START_GAME_TOOLTIP")
	)

	TooltipManager.register_tooltip(
		$MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options,
		func(): return tr("BUTTON_OPTIONS_TOOLTIP")
	)

	TooltipManager.register_tooltip(
		$MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Quit,
		func(): return tr("BUTTON_QUIT_TOOLTIP")
	)

func _on_quit_pressed():
	# Quits the application immediately
	get_tree().quit()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed():
	# Switch to options panel
	main_menu_panel.hide()
	options_panel.show()

func _on_back_to_menu_pressed():
	# Switch back to main menu panel
	options_panel.hide()
	main_menu_panel.show()

func _on_resolution_pressed(width: int, height: int):
	# Change the window resolution and save to config
	print(tr("MESSAGE_RESOLUTION_CHANGED") % [width, height])

	# If in fullscreen mode, switch to windowed first
	if ConfigManager.config.fullscreen:
		ConfigManager.set_fullscreen(false)
		fullscreen_check.button_pressed = false

	# Set the window size through ConfigManager
	ConfigManager.set_resolution(Vector2i(width, height))

func _on_fullscreen_toggled(toggled_on: bool):
	# Toggle fullscreen mode and save to config
	ConfigManager.set_fullscreen(toggled_on)
	var message_key = "MESSAGE_FULLSCREEN_ENABLED" if toggled_on else "MESSAGE_FULLSCREEN_DISABLED"
	print(tr(message_key))

func _populate_language_dropdown():
	# Clear existing items
	language_dropdown.clear()

	# Add all available languages
	var current_language = LocalizationManager.get_language()
	var current_index = 0

	for i in range(LocalizationManager.available_languages.size()):
		var lang = LocalizationManager.available_languages[i]
		var display_name = ""

		if lang.code == current_language:
			# For the currently selected language, only show native name
			# e.g., "Magyar" when Hungarian is selected
			display_name = lang.name
		else:
			# For other languages, show translated name with native in parenthesis
			# e.g., "Angol (English)" in Hungarian, or "German (Deutsch)" in English
			var translated_name = tr(lang.translation_key)
			if translated_name != lang.name:
				display_name = translated_name + " (" + lang.name + ")"

		language_dropdown.add_item(display_name, i)

		# Track the current language index
		if lang.code == current_language:
			current_index = i

	# Set the dropdown to current language
	language_dropdown.select(current_index)

func _on_language_changed(_locale: String):
	# Repopulate dropdown to update translated language names
	_populate_language_dropdown()

func _on_language_dropdown_selected(index: int):
	# Get the language code from the selected index
	var lang = LocalizationManager.available_languages[index]
	LocalizationManager.set_language(lang.code)
	print("Language changed to: %s" % lang.code)
