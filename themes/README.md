# Theme System Quick Reference

This directory contains the theme resources for the Boz Godot Framework.

## Quick Start

### 1. Setup Fonts (First Time Only)

```bash
# Follow the guide to create font resources
See: fonts/SETUP_FONTS.md
```

Options:
- **Quickest**: Use SystemFont (no files needed)
- **Custom**: Import your own .ttf/.otf files

### 2. Create Base Theme

1. In Godot Editor, navigate to `themes/`
2. Right-click → Create New Resource → Theme
3. Save as `base_theme.tres`
4. Configure colors, fonts, and styles per documentation

See: `docs/theme_system.md` - Section "Creating the Base Theme"

### 3. Apply Theme

**Option A - Global (Recommended):**
Add to `project.godot`:
```gdscript
[gui]
theme/custom="res://themes/base_theme.tres"
```

**Option B - Per Scene:**
Set theme on root Control node in Inspector

## Color Palette Reference

Use `ThemeColors` constants in your scripts:

```gdscript
# Primary colors
ThemeColors.PRIMARY            # #3399CC (rgb 0.2, 0.6, 0.8)
ThemeColors.PRIMARY_HOVER      # #4DA6D9
ThemeColors.PRIMARY_PRESSED    # #268CB8

# Backgrounds
ThemeColors.BG_DARK            # rgba(0.15, 0.15, 0.15, 0.85)
ThemeColors.BG_MEDIUM          # rgba(0.25, 0.25, 0.25, 0.90)
ThemeColors.BG_LIGHT           # rgba(0.35, 0.35, 0.35, 0.95)

# Text
ThemeColors.TEXT_PRIMARY       # White
ThemeColors.TEXT_SECONDARY     # Light gray
ThemeColors.TEXT_DISABLED      # Gray

# Status
ThemeColors.SUCCESS            # Green
ThemeColors.WARNING            # Yellow
ThemeColors.ERROR              # Red
ThemeColors.INFO               # Blue
```

## Spacing Reference

Use `ThemeConstants` for consistent spacing:

```gdscript
# Spacing (8px grid)
ThemeConstants.SPACING_TINY     # 4px
ThemeConstants.SPACING_SMALL    # 8px
ThemeConstants.SPACING_MEDIUM   # 16px (default)
ThemeConstants.SPACING_LARGE    # 24px
ThemeConstants.SPACING_XLARGE   # 32px
ThemeConstants.SPACING_HUGE     # 48px

# Font sizes
ThemeConstants.FONT_SIZE_BASE   # 14px
ThemeConstants.FONT_SIZE_LARGE  # 18px
ThemeConstants.FONT_SIZE_XLARGE # 24px

# Corner radius
ThemeConstants.CORNER_RADIUS_SMALL   # 4px - buttons
ThemeConstants.CORNER_RADIUS_MEDIUM  # 8px - panels
ThemeConstants.CORNER_RADIUS_LARGE   # 12px - modals
```

## Usage Examples

### Example 1: Styled Button

```gdscript
extends Button

func _ready():
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeColors.PRIMARY
	style.corner_radius_all = ThemeConstants.CORNER_RADIUS_SMALL
	add_theme_stylebox_override("normal", style)

	add_theme_color_override("font_color", ThemeColors.TEXT_PRIMARY)
```

### Example 2: Themed Panel

```gdscript
extends Panel

func _ready():
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeColors.BG_DARK
	style.border_color = ThemeColors.BORDER
	style.border_width_all = ThemeConstants.BORDER_WIDTH
	style.corner_radius_all = ThemeConstants.CORNER_RADIUS_MEDIUM
	add_theme_stylebox_override("panel", style)
```

### Example 3: Consistent Margins

```gdscript
extends MarginContainer

func _ready():
	add_theme_constant_override("margin_left", ThemeConstants.SPACING_LARGE)
	add_theme_constant_override("margin_top", ThemeConstants.SPACING_LARGE)
	add_theme_constant_override("margin_right", ThemeConstants.SPACING_LARGE)
	add_theme_constant_override("margin_bottom", ThemeConstants.SPACING_LARGE)
```

## File Structure

```
themes/
├── README.md (this file)
├── fonts/
│   ├── SETUP_FONTS.md          # Font setup guide
│   ├── header.tres             # Bold font for titles
│   ├── body.tres               # Regular font for text
│   └── ui.tres                 # Medium font for UI
├── base_theme.tres             # Main theme (to be created)
└── main_menu.tres              # Legacy theme
```

## Color Utilities

```gdscript
# Adjust transparency
var transparent := ThemeColors.with_alpha(ThemeColors.PRIMARY, 0.5)

# Darken/lighten
var darker := ThemeColors.darken(ThemeColors.BG_MEDIUM, 0.2)
var lighter := ThemeColors.lighten(ThemeColors.BG_MEDIUM, 0.3)

# Blend colors
var mixed := ThemeColors.blend(ThemeColors.PRIMARY, ThemeColors.SECONDARY, 0.5)

# Auto-contrast text
var text_color := ThemeColors.get_contrasting_text_color(background_color)
```

## Best Practices

✅ **DO:**
- Use ThemeColors constants instead of hardcoded Color values
- Use ThemeConstants for spacing instead of magic numbers
- Apply theme at scene root level
- Create StyleBox programmatically with constants

❌ **DON'T:**
- Hardcode colors like `Color(0.2, 0.6, 0.8)`
- Use arbitrary spacing like `margin = 17`
- Override theme in multiple places
- Mix themed and non-themed approaches

## Documentation

- **Complete Guide**: `docs/theme_system.md`
- **Font Setup**: `themes/fonts/SETUP_FONTS.md`
- **Code Reference**:
  - `scripts/theme/theme_colors.gd`
  - `scripts/theme/theme_constants.gd`

## Next Steps

1. ✅ Theme system components created
2. ⏳ Create font resources (see `fonts/SETUP_FONTS.md`)
3. ⏳ Create `base_theme.tres` (see `docs/theme_system.md`)
4. ⏳ Apply theme globally or per-scene
5. ⏳ Refactor existing scenes to use theme system
6. ⏳ (Optional) Create ThemeManager singleton for runtime switching
7. ⏳ (Optional) Create theme variants (dark/light modes)
