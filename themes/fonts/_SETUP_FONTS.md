# Font Setup Guide

This guide explains how to create the font resources for the Boz Godot Framework theme system.

## Font Structure

The framework uses three main font types:

1. **header.tres** - Large, bold fonts for titles and headings
2. **body.tres** - Standard fonts for body text and descriptions
3. **ui.tres** - Fonts optimized for UI elements (buttons, labels, inputs)

## Option 1: Using System Fonts (Quickest)

System fonts don't require font files and work across platforms.

### Create header.tres (Header Font)

1. In Godot Editor, navigate to `themes/fonts/`
2. Right-click → Create New Resource → SystemFont
3. Configure:
   - **Font Names**: Add "Arial", "Helvetica", "sans-serif" (fallbacks)
   - **Font Weight**: 700 (Bold)
   - **Font Size**: 32
   - **Antialiasing**: Enabled
4. Save as `header.tres`

### Create body.tres (Body Font)

1. Right-click → Create New Resource → SystemFont
2. Configure:
   - **Font Names**: Add "Arial", "Helvetica", "sans-serif"
   - **Font Weight**: 400 (Normal)
   - **Font Size**: 14
   - **Antialiasing**: Enabled
3. Save as `body.tres`

### Create ui.tres (UI Font)

1. Right-click → Create New Resource → SystemFont
2. Configure:
   - **Font Names**: Add "Arial", "Helvetica", "sans-serif"
   - **Font Weight**: 500 (Medium)
   - **Font Size**: 14
   - **Antialiasing**: Enabled
4. Save as `ui.tres`

## Option 2: Using Custom Font Files (More Control)

If you have custom .ttf or .otf font files:

### 1. Add Font Files

Place your font files in `themes/fonts/`:

```
themes/fonts/
├── MyFont-Regular.ttf
├── MyFont-Bold.ttf
└── MyFont-Medium.ttf
```

### 2. Create FontFile Resources

#### For header.tres:

1. In Godot, drag `MyFont-Bold.ttf` into `themes/fonts/`
2. Click the font file in FileSystem
3. In Import tab, configure:
   - **Preload Configurations**: Add size 32, 24, 18
   - **Antialiasing**: Enabled
   - **Subpixel Positioning**: Enabled
4. Click "Reimport"
5. Right-click font → "Save as..." → `header.tres`

#### For body.tres:

1. Drag `MyFont-Regular.ttf` into `themes/fonts/`
2. Configure import:
   - **Preload Configurations**: Add size 14, 12
   - **Antialiasing**: Enabled
3. Reimport and save as `body.tres`

#### For ui.tres:

1. Drag `MyFont-Medium.ttf` into `themes/fonts/`
2. Configure import:
   - **Preload Configurations**: Add size 14, 16
   - **Antialiasing**: Enabled
   - **Hinting**: Full (better for UI)
3. Reimport and save as `ui.tres`

## Option 3: Using FontVariation (Advanced)

For fine-tuned control with a single font file:

1. Create a base FontFile from your .ttf
2. Create FontVariation resources that reference the base
3. Adjust weight, stretch, and spacing per variation

### Example: Create header.tres as FontVariation

1. Right-click → Create New Resource → FontVariation
2. Set **Base Font** to your base FontFile
3. Configure:
   - **Variation OpenType**: Set weight to 700
   - **Spacing Glyph**: 1 (slightly increased spacing)
4. Save as `header.tres`

## Quick Setup Script (SystemFont)

For the fastest setup, use SystemFonts. Run this in Godot's script editor:

```gdscript
@tool
extends EditorScript

func _run():
	var fonts_dir := "res://themes/fonts/"

	# Create header font
	var header := SystemFont.new()
	header.font_names = PackedStringArray(["Arial", "Helvetica", "sans-serif"])
	header.font_weight = 700
	header.antialiasing = TextServer.FONT_ANTIALIASING_LCD
	ResourceSaver.save(header, fonts_dir + "header.tres")

	# Create body font
	var body := SystemFont.new()
	body.font_names = PackedStringArray(["Arial", "Helvetica", "sans-serif"])
	body.font_weight = 400
	body.antialiasing = TextServer.FONT_ANTIALIASING_LCD
	ResourceSaver.save(body, fonts_dir + "body.tres")

	# Create UI font
	var ui := SystemFont.new()
	ui.font_names = PackedStringArray(["Arial", "Helvetica", "sans-serif"])
	ui.font_weight = 500
	ui.antialiasing = TextServer.FONT_ANTIALIASING_LCD
	ResourceSaver.save(ui, fonts_dir + "ui.tres")

	print("Fonts created successfully!")
```

## Recommended Free Fonts

If you want to use custom fonts, here are some excellent free options:

### For Headers:
- **Roboto Bold** - Modern, geometric
- **Montserrat Bold** - Clean, professional
- **Poppins Bold** - Friendly, rounded

### For Body:
- **Roboto Regular** - Highly readable
- **Open Sans Regular** - Versatile, neutral
- **Inter Regular** - Optimized for screens

### For UI:
- **Roboto Medium** - Clear, consistent
- **IBM Plex Sans Medium** - Technical, clean

Download from [Google Fonts](https://fonts.google.com) or [Font Library](https://fontlibrary.org)

## Testing Your Fonts

After creating fonts, test them:

1. Open `scenes/main_menu.tscn`
2. Select any Label node
3. In Inspector → Theme Overrides → Fonts
4. Choose "Load" and select one of your font resources
5. Verify it displays correctly

## Next Steps

Once fonts are created, proceed to:
1. Create the base theme (`themes/base_theme.tres`)
2. Assign these fonts to the theme
3. Apply theme globally in project settings

See `docs/theme_system.md` for complete documentation.
