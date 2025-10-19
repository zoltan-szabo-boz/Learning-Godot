extends Node

const CONFIG_FILE = "user://config.cfg"

var config = {
	"resolution": Vector2i(1152, 648),
	"fullscreen": false,
	"font_scale": 1.0
}

var available_resolutions = [
	Vector2i(1920, 1080),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1024, 768)
]

func _ready():
	load_config()
	apply_fullscreen()
	# Apply font scale after a frame to ensure scene tree is ready
	await get_tree().process_frame
	apply_font_scale()

func _notification(what):
	# Ensure config is saved on exit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Force immediate flush of any pending config writes
		FileManager.flush_file(CONFIG_FILE)

func save_config(flush_immediately: bool = true):
	# Prepare config data in FileManager's expected format
	var config_data = {
		"display": {
			"resolution_x": config.resolution.x,
			"resolution_y": config.resolution.y,
			"fullscreen": config.fullscreen,
			"font_scale": config.font_scale
		}
	}

	# Queue the write through FileManager
	FileManager.queue_config_write(CONFIG_FILE, config_data)

	# Optionally flush immediately for critical settings
	# FileManager will auto-flush periodically otherwise
	if flush_immediately:
		FileManager.flush_file(CONFIG_FILE)

func load_config():
	# Load config through FileManager
	var config_data = FileManager.read_config_file(CONFIG_FILE)

	if config_data.is_empty():
		print("No config file found, using defaults")
		return

	# Extract display settings with defaults
	if config_data.has("display"):
		var display = config_data.display
		var res_x = display.get("resolution_x", config.resolution.x)
		var res_y = display.get("resolution_y", config.resolution.y)
		config.resolution = Vector2i(res_x, res_y)
		config.fullscreen = display.get("fullscreen", config.fullscreen)
		config.font_scale = display.get("font_scale", config.font_scale)

func set_resolution(resolution: Vector2i):
	config.resolution = resolution
	apply_resolution()
	save_config()

func set_fullscreen(enabled: bool):
	config.fullscreen = enabled
	apply_fullscreen()
	save_config()

func set_font_scale(scale: float):
	# Clamp to reasonable limits (0.7 to 1.4)
	config.font_scale = clampf(scale, 0.7, 1.4)
	# Don't flush immediately - let FileManager auto-flush periodically
	# This prevents freezing when dragging the slider
	save_config(false)
	# Apply font scale immediately to all nodes
	apply_font_scale()
	# Emit event via EventBus for UI to react (for updating UI elements like the slider value)
	EventBus.emit("font_scale_changed", {"scale": config.font_scale})

func apply_resolution():
	if not config.fullscreen:
		DisplayServer.window_set_size(config.resolution)

		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - config.resolution) / 2
		DisplayServer.window_set_position(window_pos)

func apply_fullscreen():
	if config.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		apply_resolution()

func apply_font_scale():
	# Apply font scaling to the entire scene tree
	_apply_font_scale_to_tree(get_tree().root, config.font_scale)

func _apply_font_scale_to_tree(node: Node, scale: float):
	# Recursively apply font size override to all Control nodes
	if node is Control:
		# Store the original base font size as metadata if not already stored
		if not node.has_meta("_base_font_size"):
			# Get the current font size from theme or use default
			var current_size = node.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 16  # Default fallback size
			node.set_meta("_base_font_size", current_size)

		# Get the base size and apply scale
		var base_size = node.get_meta("_base_font_size")
		var scaled_size = int(base_size * scale)

		# Apply the scaled font size override
		node.add_theme_font_size_override("font_size", scaled_size)

	# Recursively process children
	for child in node.get_children():
		_apply_font_scale_to_tree(child, scale)

func get_resolution_index() -> int:
	for i in range(available_resolutions.size()):
		if available_resolutions[i] == config.resolution:
			return i
	return 0
