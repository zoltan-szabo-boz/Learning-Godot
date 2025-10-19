class_name ThemeConstants
extends RefCounted

## Theme Constants
##
## Centralized spacing, sizing, and layout constants for the entire framework.
## Use these values to maintain consistent spacing and sizing across all UI.
##
## Example:
##   var margin := MarginContainer.new()
##   margin.add_theme_constant_override("margin_left", ThemeConstants.SPACING_LARGE)

# ============================================================================
# SPACING - Margins, Padding, Gaps
# ============================================================================

## Extra small spacing - 4px - subtle gaps
const SPACING_TINY: int = 4

## Small spacing - 8px - compact layouts
const SPACING_SMALL: int = 8

## Medium spacing - 16px - standard gaps
const SPACING_MEDIUM: int = 16

## Large spacing - 24px - section separation
const SPACING_LARGE: int = 24

## Extra large spacing - 32px - major sections
const SPACING_XLARGE: int = 32

## Huge spacing - 48px - page-level separation
const SPACING_HUGE: int = 48

# ============================================================================
# COMPONENT SIZES
# ============================================================================

## Button height - standard
const BUTTON_HEIGHT: int = 40

## Button height - small
const BUTTON_HEIGHT_SMALL: int = 32

## Button height - large
const BUTTON_HEIGHT_LARGE: int = 48

## Minimum button width
const BUTTON_WIDTH_MIN: int = 100

## Icon size - small
const ICON_SIZE_SMALL: int = 16

## Icon size - medium
const ICON_SIZE_MEDIUM: int = 24

## Icon size - large
const ICON_SIZE_LARGE: int = 32

## Icon size - extra large (menu icons, etc.)
const ICON_SIZE_XLARGE: int = 48

## Input field height
const INPUT_HEIGHT: int = 36

## Checkbox/radio size
const CHECKBOX_SIZE: int = 20

## Panel minimum width
const PANEL_WIDTH_MIN: int = 300

## Panel minimum height
const PANEL_HEIGHT_MIN: int = 200

## Sidebar width
const SIDEBAR_WIDTH: int = 280

# ============================================================================
# BORDER & CORNER RADIUS
# ============================================================================

## Border width - standard
const BORDER_WIDTH: int = 1

## Border width - thick
const BORDER_WIDTH_THICK: int = 2

## Corner radius - small (buttons, inputs)
const CORNER_RADIUS_SMALL: int = 4

## Corner radius - medium (panels, cards)
const CORNER_RADIUS_MEDIUM: int = 8

## Corner radius - large (modals, dialogs)
const CORNER_RADIUS_LARGE: int = 12

## Corner radius - extra large (special elements)
const CORNER_RADIUS_XLARGE: int = 16

# ============================================================================
# FONT SIZES
# ============================================================================

## Extra small text - 10px - captions, fine print
const FONT_SIZE_TINY: int = 10

## Small text - 12px - secondary info
const FONT_SIZE_SMALL: int = 12

## Base text - 14px - standard body text
const FONT_SIZE_BASE: int = 14

## Medium text - 16px - emphasized body text
const FONT_SIZE_MEDIUM: int = 16

## Large text - 18px - subheadings
const FONT_SIZE_LARGE: int = 18

## Extra large text - 24px - headings
const FONT_SIZE_XLARGE: int = 24

## Huge text - 32px - main titles
const FONT_SIZE_HUGE: int = 32

## Massive text - 48px - hero text
const FONT_SIZE_MASSIVE: int = 48

# ============================================================================
# SHADOWS & ELEVATION
# ============================================================================

## Shadow blur - subtle
const SHADOW_BLUR_SUBTLE: int = 4

## Shadow blur - standard
const SHADOW_BLUR_NORMAL: int = 8

## Shadow blur - prominent
const SHADOW_BLUR_STRONG: int = 16

## Shadow offset - standard
const SHADOW_OFFSET: Vector2 = Vector2(0, 2)

## Shadow offset - strong
const SHADOW_OFFSET_STRONG: Vector2 = Vector2(0, 4)

# ============================================================================
# ANIMATION DURATIONS (seconds)
# ============================================================================

## Very fast animation - 0.1s - instant feedback
const ANIM_DURATION_INSTANT: float = 0.1

## Fast animation - 0.2s - quick transitions
const ANIM_DURATION_FAST: float = 0.2

## Normal animation - 0.3s - standard transitions
const ANIM_DURATION_NORMAL: float = 0.3

## Slow animation - 0.5s - emphasized transitions
const ANIM_DURATION_SLOW: float = 0.5

## Very slow animation - 0.8s - dramatic transitions
const ANIM_DURATION_VERY_SLOW: float = 0.8

# ============================================================================
# Z-INDEX / LAYERS
# ============================================================================

## Background layer
const LAYER_BACKGROUND: int = 0

## Content layer
const LAYER_CONTENT: int = 10

## Overlay layer (tooltips, dropdowns)
const LAYER_OVERLAY: int = 100

## Modal layer (dialogs)
const LAYER_MODAL: int = 1000

## Top layer (notifications, system messages)
const LAYER_TOP: int = 10000

# ============================================================================
# BREAKPOINTS (for responsive design)
# ============================================================================

## Mobile breakpoint
const BREAKPOINT_MOBILE: int = 640

## Tablet breakpoint
const BREAKPOINT_TABLET: int = 1024

## Desktop breakpoint
const BREAKPOINT_DESKTOP: int = 1280

## Wide desktop breakpoint
const BREAKPOINT_WIDE: int = 1920

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

## Returns spacing value based on scale factor
## Example: ThemeConstants.get_spacing(ThemeConstants.SPACING_MEDIUM, 1.5) # 24px
static func get_spacing(base_spacing: int, scale: float = 1.0) -> int:
	return int(base_spacing * scale)


## Returns appropriate spacing for current viewport width (responsive)
static func get_responsive_spacing(viewport_width: int) -> int:
	if viewport_width < BREAKPOINT_MOBILE:
		return SPACING_SMALL
	elif viewport_width < BREAKPOINT_TABLET:
		return SPACING_MEDIUM
	else:
		return SPACING_LARGE


## Returns appropriate font size for current viewport width (responsive)
static func get_responsive_font_size(viewport_width: int) -> int:
	if viewport_width < BREAKPOINT_MOBILE:
		return FONT_SIZE_SMALL
	elif viewport_width < BREAKPOINT_TABLET:
		return FONT_SIZE_BASE
	else:
		return FONT_SIZE_MEDIUM


## Checks if current viewport is mobile size
static func is_mobile(viewport_width: int) -> bool:
	return viewport_width < BREAKPOINT_MOBILE


## Checks if current viewport is tablet size
static func is_tablet(viewport_width: int) -> bool:
	return viewport_width >= BREAKPOINT_MOBILE and viewport_width < BREAKPOINT_DESKTOP


## Checks if current viewport is desktop size
static func is_desktop(viewport_width: int) -> bool:
	return viewport_width >= BREAKPOINT_DESKTOP
