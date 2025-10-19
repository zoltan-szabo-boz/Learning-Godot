extends Node

## TooltipManager - Dynamic Tooltip System
##
## Provides a flexible tooltip system that supports:
## - Dynamic content generation via callbacks
## - State-aware tooltips (different text based on UI state)
## - Variable interpolation
## - Full localization support
## - Custom positioning and styling
##
## Usage:
## TooltipManager.register_tooltip(button, func(): return _get_button_tooltip())
##
## The callback function is evaluated when the tooltip is shown,
## allowing for dynamic content based on current game state.

signal tooltip_shown(node: Control, text: String)
signal tooltip_hidden()

# Tooltip provider data
class TooltipProvider:
	var get_text: Callable  # Function that returns tooltip text: func() -> String
	var enabled_check: Callable  # Optional: func() -> bool to check if tooltip should show
	var delay: float = 0.5  # Delay before showing tooltip

	func _init(text_callable: Callable, enabled_callable: Callable = Callable(), tooltip_delay: float = 0.5):
		get_text = text_callable
		enabled_check = enabled_callable
		delay = tooltip_delay

# Registry of all tooltip providers
var _providers: Dictionary = {}  # Control node -> TooltipProvider

# Current tooltip state
var _current_hovered_node: Control = null
var _hover_time: float = 0.0
var _tooltip_visible: bool = false

# Tooltip UI elements
var _tooltip_panel: PanelContainer
var _tooltip_label: RichTextLabel
var _tooltip_container: Control

# Configuration
var tooltip_offset: Vector2 = Vector2(10, 10)  # Offset from mouse cursor
var max_tooltip_width: float = 300.0
var update_interval: float = 0.1  # How often to update tooltip text (seconds)
var _update_timer: float = 0.0

func _ready():
	_create_tooltip_ui()
	set_process(true)

func _create_tooltip_ui():
	# Create a CanvasLayer for tooltip (always on top)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "TooltipCanvasLayer"
	canvas_layer.layer = 100  # High layer to ensure it's always on top
	add_child(canvas_layer)

	# Create container for tooltip
	_tooltip_container = Control.new()
	_tooltip_container.name = "TooltipContainer"
	_tooltip_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(_tooltip_container)

	# Create panel for tooltip background
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.name = "TooltipPanel"
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.visible = false
	_tooltip_container.add_child(_tooltip_panel)

	# Create label for tooltip text
	_tooltip_label = RichTextLabel.new()
	_tooltip_label.name = "TooltipLabel"
	_tooltip_label.bbcode_enabled = true
	_tooltip_label.fit_content = true
	_tooltip_label.scroll_active = false
	_tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_label.custom_minimum_size.x = max_tooltip_width
	_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_panel.add_child(_tooltip_label)

	# Apply default styling
	_apply_default_style()

func _apply_default_style():
	# Create a simple dark style for the tooltip
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style_box.border_color = Color(0.3, 0.3, 0.3, 1.0)
	style_box.border_width_left = 1
	style_box.border_width_right = 1
	style_box.border_width_top = 1
	style_box.border_width_bottom = 1
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.corner_radius_bottom_right = 4
	style_box.content_margin_left = 8
	style_box.content_margin_right = 8
	style_box.content_margin_top = 6
	style_box.content_margin_bottom = 6

	_tooltip_panel.add_theme_stylebox_override("panel", style_box)

func register_tooltip(node: Control, text_provider: Callable, enabled_check: Callable = Callable(), delay: float = 0.5):
	"""
	Register a tooltip for a UI node.

	Args:
		node: The Control node to attach the tooltip to
		text_provider: A Callable that returns the tooltip text (func() -> String)
		enabled_check: Optional Callable that returns whether tooltip should show (func() -> bool)
		delay: Delay in seconds before showing the tooltip (default: 0.5)

	Example:
		TooltipManager.register_tooltip(
			my_button,
			func(): return "Health: %d/%d" % [current_hp, max_hp]
		)
	"""
	if not node:
		push_error("TooltipManager: Cannot register tooltip for null node")
		return

	var provider = TooltipProvider.new(text_provider, enabled_check, delay)
	_providers[node] = provider

	# Connect mouse signals if not already connected
	if not node.mouse_entered.is_connected(_on_node_mouse_entered):
		node.mouse_entered.connect(_on_node_mouse_entered.bind(node))
	if not node.mouse_exited.is_connected(_on_node_mouse_exited):
		node.mouse_exited.connect(_on_node_mouse_exited.bind(node))

	# Connect tree_exiting to clean up when node is freed
	if not node.tree_exiting.is_connected(_on_node_tree_exiting):
		node.tree_exiting.connect(_on_node_tree_exiting.bind(node))

func unregister_tooltip(node: Control):
	"""Remove a tooltip from a node."""
	if node and _providers.has(node):
		_providers.erase(node)

		# Disconnect signals
		if node.mouse_entered.is_connected(_on_node_mouse_entered):
			node.mouse_entered.disconnect(_on_node_mouse_entered)
		if node.mouse_exited.is_connected(_on_node_mouse_exited):
			node.mouse_exited.disconnect(_on_node_mouse_exited)
		if node.tree_exiting.is_connected(_on_node_tree_exiting):
			node.tree_exiting.disconnect(_on_node_tree_exiting)

		# Hide tooltip if this was the current node
		if _current_hovered_node == node:
			_hide_tooltip()

func _on_node_mouse_entered(node: Control):
	_current_hovered_node = node
	_hover_time = 0.0

func _on_node_mouse_exited(node: Control):
	if _current_hovered_node == node:
		_current_hovered_node = null
		_hover_time = 0.0
		_hide_tooltip()

func _on_node_tree_exiting(node: Control):
	unregister_tooltip(node)

func _process(delta: float):
	if _current_hovered_node and _providers.has(_current_hovered_node):
		var provider: TooltipProvider = _providers[_current_hovered_node]

		# Check if tooltip should be enabled
		var is_enabled = true
		if provider.enabled_check.is_valid():
			is_enabled = provider.enabled_check.call()

		if not is_enabled:
			_hide_tooltip()
			return

		# Increment hover time
		_hover_time += delta

		# Show tooltip after delay
		if _hover_time >= provider.delay:
			if not _tooltip_visible:
				_show_tooltip()

			# Update tooltip content periodically
			_update_timer += delta
			if _update_timer >= update_interval:
				_update_tooltip_content()
				_update_timer = 0.0

			# Update position every frame
			_update_tooltip_position()
	else:
		_hide_tooltip()

func _show_tooltip():
	if not _current_hovered_node or not _providers.has(_current_hovered_node):
		return

	_update_tooltip_content()
	_tooltip_panel.visible = true
	_tooltip_visible = true
	_update_timer = 0.0

	var text = _tooltip_label.text
	tooltip_shown.emit(_current_hovered_node, text)

func _hide_tooltip():
	_tooltip_panel.visible = false
	_tooltip_visible = false
	_hover_time = 0.0
	_update_timer = 0.0
	tooltip_hidden.emit()

func _update_tooltip_content():
	if not _current_hovered_node or not _providers.has(_current_hovered_node):
		return

	var provider: TooltipProvider = _providers[_current_hovered_node]

	# Call the provider function to get current tooltip text
	var tooltip_text = provider.get_text.call()

	# Update label
	_tooltip_label.text = tooltip_text

func _update_tooltip_position():
	if not _tooltip_panel.visible:
		return

	# Get mouse position
	var mouse_pos = _tooltip_container.get_viewport().get_mouse_position()

	# Calculate tooltip position with offset
	var tooltip_pos = mouse_pos + tooltip_offset

	# Get viewport size to ensure tooltip stays on screen
	var viewport_size = _tooltip_container.get_viewport_rect().size
	var tooltip_size = _tooltip_panel.size

	# Adjust position to keep tooltip on screen
	if tooltip_pos.x + tooltip_size.x > viewport_size.x:
		tooltip_pos.x = mouse_pos.x - tooltip_size.x - tooltip_offset.x

	if tooltip_pos.y + tooltip_size.y > viewport_size.y:
		tooltip_pos.y = mouse_pos.y - tooltip_size.y - tooltip_offset.y

	# Clamp to viewport bounds
	tooltip_pos.x = clamp(tooltip_pos.x, 0, viewport_size.x - tooltip_size.x)
	tooltip_pos.y = clamp(tooltip_pos.y, 0, viewport_size.y - tooltip_size.y)

	_tooltip_panel.position = tooltip_pos

func set_tooltip_style(style_box: StyleBox):
	"""Apply a custom style to the tooltip panel."""
	_tooltip_panel.add_theme_stylebox_override("panel", style_box)

func get_tooltip_label() -> RichTextLabel:
	"""Get the tooltip label for custom styling."""
	return _tooltip_label
