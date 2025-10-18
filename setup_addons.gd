extends SceneTree

# Addon setup verification script
# Run with: godot --headless --script setup_addons.gd
# This checks if required addons are installed

const REQUIRED_ADDONS = {
	"gut": {
		"path": "res://addons/gut/plugin.cfg",
		"name": "Gut - Godot Unit Test",
		"url": "https://github.com/bitwes/Gut"
	}
}

func _init():
	print("=== Addon Setup Verification ===\n")

	var all_present = true

	for addon_key in REQUIRED_ADDONS:
		var addon = REQUIRED_ADDONS[addon_key]
		print("Checking: %s" % addon.name)

		if FileAccess.file_exists(addon.path):
			print("  ✓ Found at %s" % addon.path)
		else:
			print("  ✗ MISSING!")
			print("    Install from: %s" % addon.url)
			print("    Or use AssetLib in Godot Editor")
			all_present = false
		print("")

	if all_present:
		print("=== All addons present ===")
		quit(0)
	else:
		print("=== Some addons missing ===")
		print("\nTo install addons:")
		print("1. Open Godot Editor")
		print("2. Go to AssetLib tab")
		print("3. Search for missing addon")
		print("4. Download and install")
		print("5. Enable in Project > Project Settings > Plugins")
		quit(1)
