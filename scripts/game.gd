extends Node2D

func _ready():
	# Apply font scale when scene loads
	ConfigManager.apply_font_scale()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
