extends Node

## FileManager - Filesystem Abstraction Layer
##
## Provides a unified interface for file operations that works across PC and consoles.
##
## Key Features:
## - Mount/Unmount support (required for console platforms)
## - Write queue with batching (reduces I/O operations)
## - Auto-flush timer (periodically saves pending writes)
## - Platform detection (adapts behavior for different targets)
##
## Usage Pattern:
## 1. FileManager auto-mounts on startup
## 2. Components call queue_config_write() to stage changes
## 3. Changes are auto-flushed periodically or on-demand with flush_file()
## 4. FileManager auto-unmounts and flushes on game exit
##
## For future save system integration:
## - Add new write types (e.g., "save_game", "player_data")
## - Implement corresponding _write_* methods
## - Use the same queue/flush pattern
##
## Console-specific notes:
## - On console platforms, filesystem mounting may be required before I/O
## - Unmounting should happen as soon as possible after writes complete
## - Write batching reduces mount/unmount cycles

signal write_queued(file_path: String)
signal write_flushed(file_path: String, success: bool)

# Write queue - stores pending write operations
var _write_queue: Dictionary = {}
var _is_mounted: bool = false
var _auto_flush_timer: Timer

# Auto-flush interval in seconds (0 = disabled)
@export var auto_flush_interval: float = 5.0

# Platform-specific mount requirements
var _requires_mount: bool = false

func _ready():
	_detect_platform()
	_setup_auto_flush()
	mount_filesystem()

func _detect_platform():
	# Detect if we're on a platform that requires explicit mounting
	# For now, PC platforms don't require mounting, but consoles will
	var platform = OS.get_name()
	_requires_mount = platform in ["PS5", "PS4", "Xbox Series", "Xbox One", "Switch"]
	print("FileManager: Platform '%s', requires mount: %s" % [platform, _requires_mount])

func _setup_auto_flush():
	if auto_flush_interval > 0:
		_auto_flush_timer = Timer.new()
		_auto_flush_timer.wait_time = auto_flush_interval
		_auto_flush_timer.autostart = true
		_auto_flush_timer.timeout.connect(_on_auto_flush)
		add_child(_auto_flush_timer)

func _on_auto_flush():
	if _write_queue.size() > 0:
		print("FileManager: Auto-flushing %d pending writes" % _write_queue.size())
		flush_all()

func mount_filesystem() -> bool:
	if _is_mounted:
		push_warning("FileManager: Filesystem already mounted")
		return true

	if _requires_mount:
		print("FileManager: Mounting filesystem...")
		# Console-specific mount logic would go here
		# For now, this is a no-op on PC
		pass

	_is_mounted = true
	print("FileManager: Filesystem mounted")
	return true

func unmount_filesystem() -> bool:
	if not _is_mounted:
		push_warning("FileManager: Filesystem not mounted")
		return false

	# Flush any pending writes before unmounting
	if _write_queue.size() > 0:
		print("FileManager: Flushing pending writes before unmount")
		flush_all()

	if _requires_mount:
		print("FileManager: Unmounting filesystem...")
		# Console-specific unmount logic would go here
		pass

	_is_mounted = false
	print("FileManager: Filesystem unmounted")
	return true

func _notification(what):
	# Ensure we flush and unmount on exit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		unmount_filesystem()

# Queue a config write operation
func queue_config_write(file_path: String, config_data: Dictionary):
	if not _is_mounted:
		push_error("FileManager: Cannot queue write, filesystem not mounted")
		return

	_write_queue[file_path] = {
		"type": "config",
		"data": config_data
	}

	write_queued.emit(file_path)
	print("FileManager: Queued config write for '%s'" % file_path)

# Flush a specific file from the write queue
func flush_file(file_path: String) -> bool:
	if not _is_mounted:
		push_error("FileManager: Cannot flush, filesystem not mounted")
		return false

	if not _write_queue.has(file_path):
		push_warning("FileManager: No pending write for '%s'" % file_path)
		return true

	var write_data = _write_queue[file_path]
	var success = false

	match write_data.type:
		"config":
			success = _write_config_file(file_path, write_data.data)
		_:
			push_error("FileManager: Unknown write type '%s'" % write_data.type)

	if success:
		_write_queue.erase(file_path)
		print("FileManager: Flushed '%s'" % file_path)
	else:
		push_error("FileManager: Failed to flush '%s'" % file_path)

	write_flushed.emit(file_path, success)
	return success

# Flush all pending writes
func flush_all() -> bool:
	if not _is_mounted:
		push_error("FileManager: Cannot flush, filesystem not mounted")
		return false

	if _write_queue.size() == 0:
		return true

	var success = true
	var files_to_flush = _write_queue.keys()

	for file_path in files_to_flush:
		if not flush_file(file_path):
			success = false

	return success

# Write a config file to disk
func _write_config_file(file_path: String, config_data: Dictionary) -> bool:
	var file = ConfigFile.new()

	# Write all sections and keys
	for section in config_data.keys():
		for key in config_data[section].keys():
			file.set_value(section, key, config_data[section][key])

	var err = file.save(file_path)
	if err != OK:
		push_error("FileManager: Failed to save config '%s': %s" % [file_path, err])
		return false

	return true

# Read a config file from disk
func read_config_file(file_path: String) -> Dictionary:
	if not _is_mounted:
		push_error("FileManager: Cannot read, filesystem not mounted")
		return {}

	var file = ConfigFile.new()
	var err = file.load(file_path)

	if err != OK:
		print("FileManager: Config file '%s' not found or invalid" % file_path)
		return {}

	# Convert ConfigFile to Dictionary
	var result = {}
	for section in file.get_sections():
		result[section] = {}
		for key in file.get_section_keys(section):
			result[section][key] = file.get_value(section, key)

	print("FileManager: Loaded config '%s'" % file_path)
	return result

# Immediate write (bypasses queue, useful for critical data)
func write_config_immediate(file_path: String, config_data: Dictionary) -> bool:
	if not _is_mounted:
		push_error("FileManager: Cannot write, filesystem not mounted")
		return false

	print("FileManager: Immediate write to '%s'" % file_path)
	return _write_config_file(file_path, config_data)

# Check if a file exists
func file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)
