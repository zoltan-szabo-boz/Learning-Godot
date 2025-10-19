@tool
extends EditorScript

## Setup Base Theme Script
##
## This script creates a comprehensive base_theme.tres with all the styling
## that was removed from the main_menu scene during theme refactoring.
##
## Run this once in Godot Editor: File > Run > Run Script

func _run():
	print("Creating base_theme.tres...")

	var theme := Theme.new()

	# ========================================================================
	# PANEL STYLING - Replaces the removed ColorRect backgrounds
	# ========================================================================

	var panel_style := StyleBoxFlat.new()
	# Match the old hardcoded color: Color(0.15, 0.15, 0.15, 0.85)
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.85)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color(0.4, 0.4, 0.4, 1.0)  # ThemeColors.BORDER
	panel_style.set_corner_radius_all(8)  # ThemeConstants.CORNER_RADIUS_MEDIUM

	theme.set_stylebox("panel", "Panel", panel_style)

	# ========================================================================
	# MARGIN CONTAINER - Replaces removed theme_override_constants
	# ========================================================================

	# Outer margins (was 50px in main container)
	theme.set_constant("margin_left", "MarginContainer", 50)
	theme.set_constant("margin_top", "MarginContainer", 50)
	theme.set_constant("margin_right", "MarginContainer", 50)
	theme.set_constant("margin_bottom", "MarginContainer", 50)

	# ========================================================================
	# VBOX/HBOX CONTAINER - Replaces removed theme_override_constants
	# ========================================================================

	# Default separation (was 20px in main VBox)
	theme.set_constant("separation", "VBoxContainer", 20)
	theme.set_constant("separation", "HBoxContainer", 20)

	# ========================================================================
	# BUTTON STYLING
	# ========================================================================

	# Normal state
	var button_normal := StyleBoxFlat.new()
	button_normal.bg_color = Color(0.2, 0.6, 0.8, 1.0)  # ThemeColors.PRIMARY
	button_normal.set_corner_radius_all(4)  # ThemeConstants.CORNER_RADIUS_SMALL
	button_normal.content_margin_left = 16
	button_normal.content_margin_right = 16
	button_normal.content_margin_top = 8
	button_normal.content_margin_bottom = 8
	theme.set_stylebox("normal", "Button", button_normal)

	# Hover state
	var button_hover := StyleBoxFlat.new()
	button_hover.bg_color = Color(0.25, 0.65, 0.85, 1.0)  # ThemeColors.PRIMARY_HOVER
	button_hover.set_corner_radius_all(4)
	button_hover.content_margin_left = 16
	button_hover.content_margin_right = 16
	button_hover.content_margin_top = 8
	button_hover.content_margin_bottom = 8
	theme.set_stylebox("hover", "Button", button_hover)

	# Pressed state
	var button_pressed := StyleBoxFlat.new()
	button_pressed.bg_color = Color(0.15, 0.55, 0.75, 1.0)  # ThemeColors.PRIMARY_PRESSED
	button_pressed.set_corner_radius_all(4)
	button_pressed.content_margin_left = 16
	button_pressed.content_margin_right = 16
	button_pressed.content_margin_top = 8
	button_pressed.content_margin_bottom = 8
	theme.set_stylebox("pressed", "Button", button_pressed)

	# Disabled state
	var button_disabled := StyleBoxFlat.new()
	button_disabled.bg_color = Color(0.15, 0.45, 0.6, 1.0)  # ThemeColors.PRIMARY_DISABLED
	button_disabled.set_corner_radius_all(4)
	button_disabled.content_margin_left = 16
	button_disabled.content_margin_right = 16
	button_disabled.content_margin_top = 8
	button_disabled.content_margin_bottom = 8
	theme.set_stylebox("disabled", "Button", button_disabled)

	# Focus state
	var button_focus := StyleBoxFlat.new()
	button_focus.bg_color = Color(0.2, 0.6, 0.8, 1.0)
	button_focus.set_border_width_all(2)
	button_focus.border_color = Color(0.2, 0.6, 0.8, 1.0)  # ThemeColors.BORDER_FOCUS
	button_focus.set_corner_radius_all(4)
	button_focus.content_margin_left = 16
	button_focus.content_margin_right = 16
	button_focus.content_margin_top = 8
	button_focus.content_margin_bottom = 8
	theme.set_stylebox("focus", "Button", button_focus)

	# Button colors
	theme.set_color("font_color", "Button", Color(1.0, 1.0, 1.0, 1.0))  # TEXT_PRIMARY
	theme.set_color("font_hover_color", "Button", Color(1.0, 1.0, 1.0, 1.0))
	theme.set_color("font_pressed_color", "Button", Color(1.0, 1.0, 1.0, 1.0))
	theme.set_color("font_disabled_color", "Button", Color(0.5, 0.5, 0.5, 1.0))  # TEXT_DISABLED

	# ========================================================================
	# LABEL STYLING
	# ========================================================================

	theme.set_color("font_color", "Label", Color(1.0, 1.0, 1.0, 1.0))  # TEXT_PRIMARY

	# ========================================================================
	# OPTION BUTTON (Dropdown)
	# ========================================================================

	var option_normal := StyleBoxFlat.new()
	option_normal.bg_color = Color(0.25, 0.25, 0.25, 0.9)  # ThemeColors.BG_MEDIUM
	option_normal.set_border_width_all(1)
	option_normal.border_color = Color(0.4, 0.4, 0.4, 1.0)
	option_normal.set_corner_radius_all(4)
	option_normal.content_margin_left = 16
	option_normal.content_margin_right = 16
	option_normal.content_margin_top = 8
	option_normal.content_margin_bottom = 8
	theme.set_stylebox("normal", "OptionButton", option_normal)

	var option_hover := StyleBoxFlat.new()
	option_hover.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	option_hover.set_border_width_all(1)
	option_hover.border_color = Color(0.5, 0.5, 0.5, 1.0)
	option_hover.set_corner_radius_all(4)
	option_hover.content_margin_left = 16
	option_hover.content_margin_right = 16
	option_hover.content_margin_top = 8
	option_hover.content_margin_bottom = 8
	theme.set_stylebox("hover", "OptionButton", option_hover)

	theme.set_color("font_color", "OptionButton", Color(1.0, 1.0, 1.0, 1.0))
	theme.set_color("font_hover_color", "OptionButton", Color(1.0, 1.0, 1.0, 1.0))

	# ========================================================================
	# CHECK BUTTON
	# ========================================================================

	var check_normal := StyleBoxFlat.new()
	check_normal.bg_color = Color(0.25, 0.25, 0.25, 0.9)
	check_normal.set_border_width_all(1)
	check_normal.border_color = Color(0.4, 0.4, 0.4, 1.0)
	check_normal.set_corner_radius_all(4)
	check_normal.content_margin_left = 16
	check_normal.content_margin_right = 16
	check_normal.content_margin_top = 8
	check_normal.content_margin_bottom = 8
	theme.set_stylebox("normal", "CheckButton", check_normal)

	var check_hover := StyleBoxFlat.new()
	check_hover.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	check_hover.set_border_width_all(1)
	check_hover.border_color = Color(0.5, 0.5, 0.5, 1.0)
	check_hover.set_corner_radius_all(4)
	check_hover.content_margin_left = 16
	check_hover.content_margin_right = 16
	check_hover.content_margin_top = 8
	check_hover.content_margin_bottom = 8
	theme.set_stylebox("hover", "CheckButton", check_hover)

	theme.set_color("font_color", "CheckButton", Color(1.0, 1.0, 1.0, 1.0))

	# ========================================================================
	# TAB CONTAINER
	# ========================================================================

	# TabContainer panel background
	var tab_panel := StyleBoxFlat.new()
	tab_panel.bg_color = Color(0.15, 0.15, 0.15, 0.95)
	tab_panel.set_border_width_all(1)
	tab_panel.border_color = Color(0.4, 0.4, 0.4, 1.0)
	tab_panel.set_corner_radius_all(4)
	tab_panel.content_margin_left = 8
	tab_panel.content_margin_right = 8
	tab_panel.content_margin_top = 8
	tab_panel.content_margin_bottom = 8
	theme.set_stylebox("panel", "TabContainer", tab_panel)

	# Tab bar background (the area where tab buttons sit)
	var tab_bar_bg := StyleBoxFlat.new()
	tab_bar_bg.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	tab_bar_bg.set_border_width_all(0)
	tab_bar_bg.set_corner_radius_all(4)
	theme.set_stylebox("tabbar_background", "TabContainer", tab_bar_bg)

	# Selected tab
	var tab_selected := StyleBoxFlat.new()
	tab_selected.bg_color = Color(0.2, 0.6, 0.8, 1.0)  # ThemeColors.PRIMARY
	tab_selected.set_corner_radius_all(4)
	tab_selected.content_margin_left = 12
	tab_selected.content_margin_right = 12
	tab_selected.content_margin_top = 6
	tab_selected.content_margin_bottom = 6
	theme.set_stylebox("tab_selected", "TabContainer", tab_selected)

	# Unselected tab
	var tab_unselected := StyleBoxFlat.new()
	tab_unselected.bg_color = Color(0.25, 0.25, 0.25, 0.9)  # ThemeColors.BG_MEDIUM
	tab_unselected.set_corner_radius_all(4)
	tab_unselected.content_margin_left = 12
	tab_unselected.content_margin_right = 12
	tab_unselected.content_margin_top = 6
	tab_unselected.content_margin_bottom = 6
	theme.set_stylebox("tab_unselected", "TabContainer", tab_unselected)

	# Tab hover state
	var tab_hover := StyleBoxFlat.new()
	tab_hover.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	tab_hover.set_corner_radius_all(4)
	tab_hover.content_margin_left = 12
	tab_hover.content_margin_right = 12
	tab_hover.content_margin_top = 6
	tab_hover.content_margin_bottom = 6
	theme.set_stylebox("tab_hovered", "TabContainer", tab_hover)

	# Tab disabled state
	var tab_disabled := StyleBoxFlat.new()
	tab_disabled.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	tab_disabled.set_corner_radius_all(4)
	tab_disabled.content_margin_left = 12
	tab_disabled.content_margin_right = 12
	tab_disabled.content_margin_top = 6
	tab_disabled.content_margin_bottom = 6
	theme.set_stylebox("tab_disabled", "TabContainer", tab_disabled)

	# Tab text colors
	theme.set_color("font_selected_color", "TabContainer", Color(1.0, 1.0, 1.0, 1.0))
	theme.set_color("font_unselected_color", "TabContainer", Color(0.85, 0.85, 0.85, 1.0))
	theme.set_color("font_hovered_color", "TabContainer", Color(1.0, 1.0, 1.0, 1.0))
	theme.set_color("font_disabled_color", "TabContainer", Color(0.5, 0.5, 0.5, 1.0))

	# ========================================================================
	# SAVE THEME
	# ========================================================================

	var save_path := "res://themes/base_theme.tres"
	var err := ResourceSaver.save(theme, save_path)

	if err == OK:
		print("✅ Successfully created base_theme.tres at: ", save_path)
		print("Theme includes:")
		print("  - Panel style (dark background, matching old ColorRect)")
		print("  - MarginContainer defaults (50px)")
		print("  - VBoxContainer/HBoxContainer separation (20px)")
		print("  - Button styling (primary colors)")
		print("  - Label, OptionButton, CheckButton styling")
		print("  - TabContainer styling (tabs and panel)")
		print("")
		print("The project should now work correctly!")
	else:
		push_error("❌ Failed to save theme. Error code: " + str(err))
