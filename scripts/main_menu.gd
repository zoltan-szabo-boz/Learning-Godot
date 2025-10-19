extends Control

@onready var main_menu_panel = $MarginContainer/HBoxContainer/MainMenuPanel
@onready var options_panel = $MarginContainer/HBoxContainer/OptionsPanel
@onready var fullscreen_check = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/ResolutionMargin/ResolutionContainer/Fullscreen

func _ready():
	# Initialize fullscreen checkbox state from config
	fullscreen_check.button_pressed = ConfigManager.config.fullscreen

func _on_quit_pressed():
	# Quits the application immediately
	get_tree().quit()

func _on_start_pressed():
	print(tr("MESSAGE_STARTING_GAME"))
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

func _on_language_pressed(locale: String):
	# Change language through LocalizationManager
	LocalizationManager.set_language(locale)
	print("Language changed to: %s" % locale)
