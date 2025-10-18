extends Control

@onready var main_menu_panel = $MarginContainer/HBoxContainer/MainMenuPanel
@onready var options_panel = $MarginContainer/HBoxContainer/OptionsPanel
@onready var fullscreen_check = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/ResolutionMargin/ResolutionContainer/Fullscreen

func _ready():
	# Initialize fullscreen checkbox state
	fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_quit_pressed():
	# Quits the application immediately
	get_tree().quit()

func _on_start_pressed():
	print("Starting the game!")
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
	# Change the window resolution
	print("Changing resolution to %dx%d" % [width, height])

	# If in fullscreen mode, switch to windowed first
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_check.button_pressed = false

	# Set the window size
	DisplayServer.window_set_size(Vector2i(width, height))

	# Center the window on screen
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var centered_pos = (screen_size - window_size) / 2
	DisplayServer.window_set_position(centered_pos)

func _on_fullscreen_toggled(toggled_on: bool):
	# Toggle fullscreen mode
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("Fullscreen enabled")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("Fullscreen disabled")
