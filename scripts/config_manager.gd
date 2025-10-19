extends Node

const CONFIG_FILE = "user://config.cfg"

var config = {
	"resolution": Vector2i(1152, 648),
	"fullscreen": false
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

func _notification(what):
	# Ensure config is saved on exit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Force immediate flush of any pending config writes
		FileManager.flush_file(CONFIG_FILE)

func save_config():
	# Prepare config data in FileManager's expected format
	var config_data = {
		"display": {
			"resolution_x": config.resolution.x,
			"resolution_y": config.resolution.y,
			"fullscreen": config.fullscreen
		}
	}

	# Queue the write through FileManager
	FileManager.queue_config_write(CONFIG_FILE, config_data)

	# Optionally flush immediately for critical settings
	# FileManager will auto-flush periodically otherwise
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

func set_resolution(resolution: Vector2i):
	config.resolution = resolution
	apply_resolution()
	save_config()

func set_fullscreen(enabled: bool):
	config.fullscreen = enabled
	apply_fullscreen()
	save_config()

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

func get_resolution_index() -> int:
	for i in range(available_resolutions.size()):
		if available_resolutions[i] == config.resolution:
			return i
	return 0
