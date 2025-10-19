# Theme System Documentation

This document provides comprehensive documentation for the Boz Godot Framework theme system.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Components](#components)
- [Usage Guide](#usage-guide)
- [Creating the Base Theme](#creating-the-base-theme)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Overview

The theme system provides a centralized approach to managing visual consistency across your entire project. Instead of hardcoding colors, fonts, and spacing values throughout your scenes, you define them once and reference them everywhere.

### Benefits

- **Consistency**: All UI elements follow the same design language
- **Maintainability**: Change colors/fonts in one place, update everywhere
- **Scalability**: Easy to add dark mode, color schemes, or accessibility options
- **Professionalism**: Clean, organized code without magic numbers
- **Flexibility**: Override specific elements while maintaining global defaults

## Architecture

The theme system consists of three main components:

```
Theme System
├── ThemeColors (scripts/theme/theme_colors.gd)
│   └── Color palette constants and utility functions
├── ThemeConstants (scripts/theme/theme_constants.gd)
│   └── Spacing, sizing, and layout constants
└── Theme Resources (themes/)
    ├── fonts/ - Font resources (header, body, ui)
    └── base_theme.tres - Main theme resource
```

### Design Philosophy

1. **Script-based constants** for values that may need runtime access or calculations
2. **Resource-based themes** for Godot's built-in theme system integration
3. **Single source of truth** - define once, use everywhere
4. **Type safety** - constants prevent typos and provide autocomplete

## Components

### 1. ThemeColors (`scripts/theme/theme_colors.gd`)

Defines all colors used in the framework.

#### Color Categories

**Primary Colors**: Main brand/accent colors
```gdscript
ThemeColors.PRIMARY
ThemeColors.PRIMARY_HOVER
ThemeColors.PRIMARY_PRESSED
ThemeColors.PRIMARY_DISABLED
```

**Secondary Colors**: Less prominent UI elements
```gdscript
ThemeColors.SECONDARY
ThemeColors.SECONDARY_HOVER
ThemeColors.SECONDARY_PRESSED
```

**Background Colors**: Panels, overlays, modals
```gdscript
ThemeColors.BG_DARK         # 0.15, 0.15, 0.15, 0.85
ThemeColors.BG_MEDIUM       # 0.25, 0.25, 0.25, 0.90
ThemeColors.BG_LIGHT        # 0.35, 0.35, 0.35, 0.95
ThemeColors.BG_OVERLAY      # 0.05, 0.05, 0.05, 0.95
ThemeColors.BG_TRANSPARENT  # 0.0, 0.0, 0.0, 0.5
```

**Text Colors**: Different text hierarchies
```gdscript
ThemeColors.TEXT_PRIMARY    # Main text
ThemeColors.TEXT_SECONDARY  # Less important text
ThemeColors.TEXT_TERTIARY   # Hints and subtle text
ThemeColors.TEXT_DISABLED   # Disabled elements
ThemeColors.TEXT_INVERTED   # For light backgrounds
```

**Status Colors**: Feedback and state indicators
```gdscript
ThemeColors.SUCCESS         # Green - positive actions
ThemeColors.WARNING         # Yellow - caution
ThemeColors.ERROR           # Red - errors/danger
ThemeColors.INFO            # Blue - information
```

**Border Colors**: Outlines and separators
```gdscript
ThemeColors.BORDER
ThemeColors.BORDER_HOVER
ThemeColors.BORDER_FOCUS
ThemeColors.BORDER_SUBTLE
```

#### Utility Functions

**Adjust Alpha**: Change transparency
```gdscript
var semi_transparent := ThemeColors.with_alpha(ThemeColors.PRIMARY, 0.5)
```

**Darken/Lighten**: Adjust brightness
```gdscript
var darker := ThemeColors.darken(ThemeColors.BG_MEDIUM, 0.2)  # 20% darker
var lighter := ThemeColors.lighten(ThemeColors.BG_MEDIUM, 0.3)  # 30% lighter
```

**Blend**: Mix two colors
```gdscript
var mixed := ThemeColors.blend(ThemeColors.PRIMARY, ThemeColors.SECONDARY, 0.5)
```

**Auto-contrast**: Get readable text color
```gdscript
var text_color := ThemeColors.get_contrasting_text_color(background_color)
```

### 2. ThemeConstants (`scripts/theme/theme_constants.gd`)

Defines spacing, sizing, and layout values.

#### Spacing Scale

Consistent spacing system based on 8px grid:
```gdscript
ThemeConstants.SPACING_TINY     # 4px
ThemeConstants.SPACING_SMALL    # 8px
ThemeConstants.SPACING_MEDIUM   # 16px
ThemeConstants.SPACING_LARGE    # 24px
ThemeConstants.SPACING_XLARGE   # 32px
ThemeConstants.SPACING_HUGE     # 48px
```

#### Component Sizes

Standard sizes for UI elements:
```gdscript
# Buttons
ThemeConstants.BUTTON_HEIGHT           # 40px
ThemeConstants.BUTTON_HEIGHT_SMALL     # 32px
ThemeConstants.BUTTON_HEIGHT_LARGE     # 48px
ThemeConstants.BUTTON_WIDTH_MIN        # 100px

# Icons
ThemeConstants.ICON_SIZE_SMALL         # 16px
ThemeConstants.ICON_SIZE_MEDIUM        # 24px
ThemeConstants.ICON_SIZE_LARGE         # 32px
ThemeConstants.ICON_SIZE_XLARGE        # 48px

# Inputs
ThemeConstants.INPUT_HEIGHT            # 36px
ThemeConstants.CHECKBOX_SIZE           # 20px
```

#### Font Sizes

Typographic scale:
```gdscript
ThemeConstants.FONT_SIZE_TINY      # 10px - captions
ThemeConstants.FONT_SIZE_SMALL     # 12px - secondary info
ThemeConstants.FONT_SIZE_BASE      # 14px - body text
ThemeConstants.FONT_SIZE_MEDIUM    # 16px - emphasized text
ThemeConstants.FONT_SIZE_LARGE     # 18px - subheadings
ThemeConstants.FONT_SIZE_XLARGE    # 24px - headings
ThemeConstants.FONT_SIZE_HUGE      # 32px - titles
ThemeConstants.FONT_SIZE_MASSIVE   # 48px - hero text
```

#### Border & Corners

```gdscript
ThemeConstants.BORDER_WIDTH              # 1px
ThemeConstants.BORDER_WIDTH_THICK        # 2px
ThemeConstants.CORNER_RADIUS_SMALL       # 4px - buttons
ThemeConstants.CORNER_RADIUS_MEDIUM      # 8px - panels
ThemeConstants.CORNER_RADIUS_LARGE       # 12px - modals
```

#### Animation Durations

```gdscript
ThemeConstants.ANIM_DURATION_INSTANT     # 0.1s
ThemeConstants.ANIM_DURATION_FAST        # 0.2s
ThemeConstants.ANIM_DURATION_NORMAL      # 0.3s
ThemeConstants.ANIM_DURATION_SLOW        # 0.5s
```

#### Z-Index / Layers

```gdscript
ThemeConstants.LAYER_BACKGROUND   # 0
ThemeConstants.LAYER_CONTENT      # 10
ThemeConstants.LAYER_OVERLAY      # 100
ThemeConstants.LAYER_MODAL        # 1000
ThemeConstants.LAYER_TOP          # 10000
```

#### Responsive Breakpoints

```gdscript
ThemeConstants.BREAKPOINT_MOBILE    # 640px
ThemeConstants.BREAKPOINT_TABLET    # 1024px
ThemeConstants.BREAKPOINT_DESKTOP   # 1280px
ThemeConstants.BREAKPOINT_WIDE      # 1920px
```

### 3. Font Resources

Three font resources for different purposes:

- **`themes/fonts/header.tres`** - Bold fonts for titles (weight: 700, size: 32)
- **`themes/fonts/body.tres`** - Regular fonts for text (weight: 400, size: 14)
- **`themes/fonts/ui.tres`** - Medium fonts for UI (weight: 500, size: 14)

See `themes/fonts/SETUP_FONTS.md` for setup instructions.

### 4. Base Theme Resource

The main theme resource (`themes/base_theme.tres`) that applies styles to all Godot Control nodes.

## Usage Guide

### In GDScript

#### Using Colors

```gdscript
# Create a colored panel
var panel := Panel.new()
var style := StyleBoxFlat.new()
style.bg_color = ThemeColors.BG_DARK
style.border_color = ThemeColors.BORDER
style.border_width_all = ThemeConstants.BORDER_WIDTH
style.corner_radius_all = ThemeConstants.CORNER_RADIUS_MEDIUM
panel.add_theme_stylebox_override("panel", style)

# Create a label with proper text color
var label := Label.new()
label.add_theme_color_override("font_color", ThemeColors.TEXT_PRIMARY)
label.add_theme_font_size_override("font_size", ThemeConstants.FONT_SIZE_LARGE)
```

#### Using Spacing

```gdscript
# Create a margin container with consistent spacing
var margin := MarginContainer.new()
margin.add_theme_constant_override("margin_left", ThemeConstants.SPACING_LARGE)
margin.add_theme_constant_override("margin_top", ThemeConstants.SPACING_LARGE)
margin.add_theme_constant_override("margin_right", ThemeConstants.SPACING_LARGE)
margin.add_theme_constant_override("margin_bottom", ThemeConstants.SPACING_LARGE)

# Create a VBoxContainer with standard gaps
var vbox := VBoxContainer.new()
vbox.add_theme_constant_override("separation", ThemeConstants.SPACING_MEDIUM)
```

#### Dynamic Color Adjustments

```gdscript
# Create hover effect
func _on_button_mouse_entered():
	var darker_bg := ThemeColors.darken(ThemeColors.BG_MEDIUM, 0.1)
	apply_color(darker_bg)

# Fade in/out effect
func fade_in(duration: float):
	var tween := create_tween()
	var transparent := ThemeColors.with_alpha(ThemeColors.BG_DARK, 0.0)
	var opaque := ThemeColors.BG_DARK
	tween.tween_property(panel, "modulate", Color.WHITE, duration)
```

#### Responsive Design

```gdscript
func _ready():
	update_layout()
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	update_layout()

func update_layout():
	var viewport_width := get_viewport().size.x

	if ThemeConstants.is_mobile(viewport_width):
		# Mobile layout
		margin_container.add_theme_constant_override(
			"margin_left",
			ThemeConstants.SPACING_SMALL
		)
	elif ThemeConstants.is_tablet(viewport_width):
		# Tablet layout
		margin_container.add_theme_constant_override(
			"margin_left",
			ThemeConstants.SPACING_MEDIUM
		)
	else:
		# Desktop layout
		margin_container.add_theme_constant_override(
			"margin_left",
			ThemeConstants.SPACING_LARGE
		)
```

### In Scene Editor

While you can still hardcode values in the editor, it's better to:

1. **Use the base theme** for global styles
2. **Create theme overrides** only when necessary
3. **Reference constants in scripts** for dynamic values

#### Applying Base Theme to Scene

Option 1: Set globally in `project.godot`:
```gdscript
[gui]
theme/custom="res://themes/base_theme.tres"
```

Option 2: Apply to scene root:
1. Select root Control node
2. In Inspector → Theme → Theme
3. Load `res://themes/base_theme.tres`

#### Theme Overrides in Editor

When you need custom values:
1. Select a Control node
2. In Inspector → Theme Overrides
3. Override Colors, Fonts, or Constants
4. **Prefer using script constants over hardcoded values**

## Creating the Base Theme

### Step 1: Create Theme Resource

1. In Godot Editor, navigate to `themes/`
2. Right-click → Create New Resource → Theme
3. Save as `base_theme.tres`
4. Double-click to open Theme Editor

### Step 2: Assign Fonts

1. In Theme Editor, expand **Default Font**
2. Drag `themes/fonts/body.tres` to Default Font
3. For specific controls:
   - Button → Fonts → font → Load `ui.tres`
   - Label → Fonts → font → Load `body.tres`
   - (Optional) RichTextLabel → Fonts → normal_font → Load `body.tres`

### Step 3: Configure Colors

You'll need to manually set colors using values from ThemeColors. Here's a mapping:

#### Button
1. Expand Button in Theme Editor
2. Colors:
   - **font_color**: `#FFFFFF` (TEXT_PRIMARY)
   - **font_hover_color**: `#FFFFFF` (TEXT_PRIMARY)
   - **font_pressed_color**: `#FFFFFF` (TEXT_PRIMARY)
   - **font_disabled_color**: `#808080` (TEXT_DISABLED)

3. Styles:
   - **normal**: Create StyleBoxFlat
     - Background Color: `#3399CC` (PRIMARY - rgb(0.2, 0.6, 0.8))
     - Border Width: 0
     - Corner Radius: 4 (CORNER_RADIUS_SMALL)
   - **hover**: Create StyleBoxFlat
     - Background Color: `#4DA6D9` (PRIMARY_HOVER - rgb(0.25, 0.65, 0.85))
   - **pressed**: Create StyleBoxFlat
     - Background Color: `#268CB8` (PRIMARY_PRESSED - rgb(0.15, 0.55, 0.75))
   - **disabled**: Create StyleBoxFlat
     - Background Color: `#265C99` (PRIMARY_DISABLED - rgb(0.15, 0.45, 0.6))

#### Panel
1. Expand Panel in Theme Editor
2. Styles:
   - **panel**: Create StyleBoxFlat
     - Background Color: `#262626D9` (BG_DARK - rgb(0.15, 0.15, 0.15, 0.85))
     - Border Color: `#666666` (BORDER)
     - Border Width: 1
     - Corner Radius: 8 (CORNER_RADIUS_MEDIUM)

#### Label
1. Expand Label in Theme Editor
2. Colors:
   - **font_color**: `#FFFFFF` (TEXT_PRIMARY)
   - **font_shadow_color**: `#00000080` (with_alpha(BLACK, 0.5))

#### LineEdit (Input Fields)
1. Expand LineEdit in Theme Editor
2. Colors:
   - **font_color**: `#FFFFFF` (TEXT_PRIMARY)
   - **font_placeholder_color**: `#999999` (TEXT_TERTIARY)
3. Styles:
   - **normal**: StyleBoxFlat
     - Background: `#404040E6` (BG_MEDIUM)
     - Border Color: `#666666` (BORDER)
     - Border Width: 1
     - Corner Radius: 4
   - **focus**: StyleBoxFlat
     - Background: `#404040E6` (BG_MEDIUM)
     - Border Color: `#3399CC` (BORDER_FOCUS / PRIMARY)
     - Border Width: 2
     - Corner Radius: 4

#### Additional Controls

Continue this pattern for:
- CheckBox
- OptionButton
- TextEdit
- ProgressBar
- ScrollBar
- TabContainer
- MenuBar
- PopupMenu

### Step 4: Configure Constants

Set spacing and sizing constants:

#### MarginContainer
- margin_left: 16
- margin_right: 16
- margin_top: 16
- margin_bottom: 16

#### VBoxContainer / HBoxContainer
- separation: 16

#### Button
- h_separation: 8 (space between icon and text)

#### ScrollContainer
- separation: 16

### Step 5: Save and Test

1. Save the theme
2. Apply to a test scene
3. Verify all controls look consistent

## Best Practices

### DO:

✅ **Use constants instead of magic numbers**
```gdscript
# Good
label.add_theme_font_size_override("font_size", ThemeConstants.FONT_SIZE_LARGE)

# Bad
label.add_theme_font_size_override("font_size", 18)
```

✅ **Use color utilities for variations**
```gdscript
# Good - maintains consistency
var hover_color := ThemeColors.lighten(ThemeColors.PRIMARY, 0.1)

# Bad - arbitrary values
var hover_color := Color(0.34, 0.72, 0.91)
```

✅ **Apply theme at root level**
```gdscript
# Apply theme to scene root
@onready var root: Control = $"."

func _ready():
	root.theme = preload("res://themes/base_theme.tres")
```

✅ **Create custom StyleBox in code for complex styles**
```gdscript
func create_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeColors.PRIMARY
	style.border_color = ThemeColors.BORDER
	style.border_width_all = ThemeConstants.BORDER_WIDTH
	style.corner_radius_all = ThemeConstants.CORNER_RADIUS_SMALL
	return style
```

### DON'T:

❌ **Don't hardcode colors in scenes**
```gdscript
# Bad
color = Color(0.15, 0.15, 0.15, 0.85)

# Good
color = ThemeColors.BG_DARK
```

❌ **Don't use inconsistent spacing**
```gdscript
# Bad - random values
margin_left = 17
margin_top = 23

# Good - consistent scale
margin_left = ThemeConstants.SPACING_MEDIUM
margin_top = ThemeConstants.SPACING_LARGE
```

❌ **Don't create multiple theme files unnecessarily**
- Start with one base theme
- Only create variants (dark/light) when actually needed

❌ **Don't override theme in multiple places**
- Apply theme once at root level
- Use theme_overrides sparingly for exceptions

### Code Organization

Recommended structure for theme-related code:

```gdscript
extends Control

# Theme references (cached)
var _primary_color: Color = ThemeColors.PRIMARY
var _spacing: int = ThemeConstants.SPACING_MEDIUM

func _ready():
	_apply_theme()

func _apply_theme():
	# Apply theme styles
	add_theme_color_override("font_color", _primary_color)
	add_theme_constant_override("separation", _spacing)
```

## Examples

### Example 1: Themed Button

```gdscript
extends Button

func _ready():
	# Apply theme
	custom_minimum_size.y = ThemeConstants.BUTTON_HEIGHT

	# Create custom style
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = ThemeColors.PRIMARY
	normal_style.corner_radius_all = ThemeConstants.CORNER_RADIUS_SMALL
	add_theme_stylebox_override("normal", normal_style)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = ThemeColors.PRIMARY_HOVER
	hover_style.corner_radius_all = ThemeConstants.CORNER_RADIUS_SMALL
	add_theme_stylebox_override("hover", hover_style)

	# Text color
	add_theme_color_override("font_color", ThemeColors.TEXT_PRIMARY)
	add_theme_font_size_override("font_size", ThemeConstants.FONT_SIZE_BASE)
```

### Example 2: Themed Panel with Margin

```gdscript
extends Panel

func _ready():
	# Panel style
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeColors.BG_DARK
	style.border_color = ThemeColors.BORDER
	style.border_width_all = ThemeConstants.BORDER_WIDTH
	style.corner_radius_all = ThemeConstants.CORNER_RADIUS_MEDIUM
	add_theme_stylebox_override("panel", style)

# Add child margin container
func add_content(content: Control):
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", ThemeConstants.SPACING_LARGE)
	margin.add_theme_constant_override("margin_top", ThemeConstants.SPACING_LARGE)
	margin.add_theme_constant_override("margin_right", ThemeConstants.SPACING_LARGE)
	margin.add_theme_constant_override("margin_bottom", ThemeConstants.SPACING_LARGE)
	add_child(margin)
	margin.add_child(content)
```

### Example 3: Status-Colored Label

```gdscript
extends Label

enum Status { SUCCESS, WARNING, ERROR, INFO }

@export var status: Status = Status.INFO

func _ready():
	update_status_color()

func update_status_color():
	var color: Color
	match status:
		Status.SUCCESS:
			color = ThemeColors.SUCCESS
		Status.WARNING:
			color = ThemeColors.WARNING
		Status.ERROR:
			color = ThemeColors.ERROR
		Status.INFO:
			color = ThemeColors.INFO

	add_theme_color_override("font_color", color)
	add_theme_font_size_override("font_size", ThemeConstants.FONT_SIZE_MEDIUM)
```

### Example 4: Responsive Container

```gdscript
extends MarginContainer

func _ready():
	get_viewport().size_changed.connect(_on_viewport_resized)
	_update_margins()

func _on_viewport_resized():
	_update_margins()

func _update_margins():
	var viewport_width := get_viewport().size.x
	var spacing := ThemeConstants.get_responsive_spacing(viewport_width)

	add_theme_constant_override("margin_left", spacing)
	add_theme_constant_override("margin_top", spacing)
	add_theme_constant_override("margin_right", spacing)
	add_theme_constant_override("margin_bottom", spacing)
```

## Troubleshooting

### Colors don't match between script and editor

**Problem**: Colors defined in ThemeColors don't match what you see in editor.

**Solution**: When creating StyleBox resources in the editor, you must manually convert the color values:
- ThemeColors uses 0.0-1.0 range
- Editor color picker shows 0-255 range
- Use formula: `editor_value = theme_value * 255`
- Example: `Color(0.2, 0.6, 0.8)` = RGB(51, 153, 204) = `#3399CC`

### Theme not applying to child nodes

**Problem**: Theme set on parent but children don't inherit styles.

**Solution**:
1. Make sure theme is set on root Control node, not Container
2. Check if children have explicit theme_overrides blocking inheritance
3. Verify the theme resource is loaded correctly

### Inconsistent spacing between scenes

**Problem**: Different scenes have different spacing even though using theme.

**Solution**:
- Spacing constants from ThemeConstants require manual application
- Either use base_theme.tres OR apply constants in code
- Don't mix both approaches without coordination

### Fonts not loading

**Problem**: Font resources show as missing or default font is used.

**Solution**:
1. Check font resources exist in `themes/fonts/`
2. Verify fonts are properly imported (check .import files)
3. Make sure theme references correct font paths
4. Try reimporting fonts: Select font → Import tab → Reimport

### Theme changes not reflecting

**Problem**: Modified theme but changes don't appear in game.

**Solution**:
1. Save theme resource after editing
2. Reload the scene
3. If using global theme, restart Godot editor
4. Check if local theme_overrides are blocking changes

## Next Steps

Now that you have the theme system set up:

1. **Create the base theme** following the guide above
2. **Apply theme globally** in project.godot or per-scene
3. **Refactor existing scenes** to use theme constants
4. **(Optional) Implement ThemeManager** for runtime theme switching
5. **(Optional) Create theme variants** (dark mode, light mode, etc.)

See `CLAUDE.md` for integration guidelines and best practices.
