class_name ThemeColors
extends RefCounted

## Theme Color Palette
##
## Centralized color definitions for the entire framework.
## Use these constants instead of hardcoding colors in scenes.
##
## Example:
##   var my_label := Label.new()
##   my_label.add_theme_color_override("font_color", ThemeColors.TEXT_PRIMARY)
##
## For theme resources, reference these values when creating styles in the editor.

# ============================================================================
# PRIMARY COLORS
# ============================================================================

## Main brand/accent color - used for primary actions and highlights
const PRIMARY: Color = Color(0.2, 0.6, 0.8)

## Primary color on hover state
const PRIMARY_HOVER: Color = Color(0.25, 0.65, 0.85)

## Primary color on pressed/active state
const PRIMARY_PRESSED: Color = Color(0.15, 0.55, 0.75)

## Primary color for disabled state
const PRIMARY_DISABLED: Color = Color(0.15, 0.45, 0.6)

# ============================================================================
# SECONDARY COLORS
# ============================================================================

## Secondary UI color - less prominent actions
const SECONDARY: Color = Color(0.4, 0.4, 0.4)

## Secondary color on hover state
const SECONDARY_HOVER: Color = Color(0.5, 0.5, 0.5)

## Secondary color on pressed/active state
const SECONDARY_PRESSED: Color = Color(0.3, 0.3, 0.3)

## Secondary color for disabled state
const SECONDARY_DISABLED: Color = Color(0.25, 0.25, 0.25)

# ============================================================================
# BACKGROUND COLORS
# ============================================================================

## Dark background - main panels and overlays
const BG_DARK: Color = Color(0.15, 0.15, 0.15, 0.85)

## Medium background - secondary panels
const BG_MEDIUM: Color = Color(0.25, 0.25, 0.25, 0.9)

## Light background - tertiary panels and cards
const BG_LIGHT: Color = Color(0.35, 0.35, 0.35, 0.95)

## Very dark background - modals and full overlays
const BG_OVERLAY: Color = Color(0.05, 0.05, 0.05, 0.95)

## Transparent dark - for subtle overlays
const BG_TRANSPARENT: Color = Color(0.0, 0.0, 0.0, 0.5)

# ============================================================================
# TEXT COLORS
# ============================================================================

## Primary text color - main readable text
const TEXT_PRIMARY: Color = Color(1.0, 1.0, 1.0, 1.0)

## Secondary text color - less prominent text
const TEXT_SECONDARY: Color = Color(0.8, 0.8, 0.8, 1.0)

## Tertiary text color - hints and subtle text
const TEXT_TERTIARY: Color = Color(0.6, 0.6, 0.6, 1.0)

## Disabled text color - inactive elements
const TEXT_DISABLED: Color = Color(0.5, 0.5, 0.5, 1.0)

## Inverted text - for use on light backgrounds
const TEXT_INVERTED: Color = Color(0.1, 0.1, 0.1, 1.0)

# ============================================================================
# STATUS COLORS
# ============================================================================

## Success/positive state
const SUCCESS: Color = Color(0.3, 0.8, 0.3, 1.0)

## Success hover state
const SUCCESS_HOVER: Color = Color(0.35, 0.85, 0.35, 1.0)

## Warning/caution state
const WARNING: Color = Color(0.9, 0.7, 0.2, 1.0)

## Warning hover state
const WARNING_HOVER: Color = Color(0.95, 0.75, 0.25, 1.0)

## Error/danger state
const ERROR: Color = Color(0.9, 0.3, 0.3, 1.0)

## Error hover state
const ERROR_HOVER: Color = Color(0.95, 0.35, 0.35, 1.0)

## Info/neutral state
const INFO: Color = Color(0.4, 0.7, 0.9, 1.0)

## Info hover state
const INFO_HOVER: Color = Color(0.45, 0.75, 0.95, 1.0)

# ============================================================================
# BORDER COLORS
# ============================================================================

## Standard border color
const BORDER: Color = Color(0.4, 0.4, 0.4, 1.0)

## Border on hover
const BORDER_HOVER: Color = Color(0.5, 0.5, 0.5, 1.0)

## Border on focus
const BORDER_FOCUS: Color = Color(0.2, 0.6, 0.8, 1.0)

## Subtle border/separator
const BORDER_SUBTLE: Color = Color(0.3, 0.3, 0.3, 1.0)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

## Returns a color with modified alpha channel
## Example: ThemeColors.with_alpha(ThemeColors.PRIMARY, 0.5)
static func with_alpha(color: Color, alpha: float) -> Color:
	var c := color
	c.a = clamp(alpha, 0.0, 1.0)
	return c


## Darkens a color by a percentage (0.0 to 1.0)
## Example: ThemeColors.darken(ThemeColors.PRIMARY, 0.2) # 20% darker
static func darken(color: Color, amount: float) -> Color:
	amount = clamp(amount, 0.0, 1.0)
	return Color(
		color.r * (1.0 - amount),
		color.g * (1.0 - amount),
		color.b * (1.0 - amount),
		color.a
	)


## Lightens a color by a percentage (0.0 to 1.0)
## Example: ThemeColors.lighten(ThemeColors.PRIMARY, 0.2) # 20% lighter
static func lighten(color: Color, amount: float) -> Color:
	amount = clamp(amount, 0.0, 1.0)
	return Color(
		color.r + (1.0 - color.r) * amount,
		color.g + (1.0 - color.g) * amount,
		color.b + (1.0 - color.b) * amount,
		color.a
	)


## Blends two colors together
## weight: 0.0 = fully color_a, 1.0 = fully color_b
static func blend(color_a: Color, color_b: Color, weight: float) -> Color:
	weight = clamp(weight, 0.0, 1.0)
	return color_a.lerp(color_b, weight)


## Returns a color suitable for text that will be displayed on the given background
## Automatically chooses between light and dark text for optimal contrast
static func get_contrasting_text_color(background: Color) -> Color:
	var luminance: float = (
		0.299 * background.r + 0.587 * background.g + 0.114 * background.b
	)
	return TEXT_PRIMARY if luminance < 0.5 else TEXT_INVERTED
