extends Control

func _on_quit_pressed():
	# Quits the application immediately
	get_tree().quit()

func _on_start_pressed():
	print("Starting the game!")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
