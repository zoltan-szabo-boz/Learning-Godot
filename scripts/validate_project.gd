extends SceneTree

# Validation script to check project integrity
# Run with: godot --headless --script res://scripts/validate_project.gd

func _init():
	print("=== Project Validation ===")

	var errors = 0

	# Check if main scenes exist
	if not FileAccess.file_exists("res://scenes/main_menu.tscn"):
		print("ERROR: main_menu.tscn not found")
		errors += 1
	else:
		print("OK: main_menu.tscn exists")

	if not FileAccess.file_exists("res://scenes/game.tscn"):
		print("ERROR: game.tscn not found")
		errors += 1
	else:
		print("OK: game.tscn exists")

	# Check if scripts exist
	if not FileAccess.file_exists("res://scripts/main_menu.gd"):
		print("ERROR: main_menu.gd not found")
		errors += 1
	else:
		print("OK: main_menu.gd exists")

	if not FileAccess.file_exists("res://scripts/game.gd"):
		print("ERROR: game.gd not found")
		errors += 1
	else:
		print("OK: game.gd exists")

	print("\n=== Validation Complete ===")
	if errors > 0:
		print("FAILED: %d errors found" % errors)
		quit(1)
	else:
		print("PASSED: No errors found")
		quit(0)
