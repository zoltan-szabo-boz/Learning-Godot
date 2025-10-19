# Editor Tools Guide

This guide explains the editor tools system and how to use and create editor scripts for the Boz Godot Framework.

## Overview

Editor tools are special scripts that run only in the Godot Editor to perform setup, generation, and maintenance tasks. They are **not** part of the game logic and never execute during gameplay.

## Purpose

Editor tools help with:
- **Initial Setup** - Generate required resources for the project
- **Resource Generation** - Create themes, fonts, atlases automatically
- **Validation** - Check project integrity and configuration
- **Maintenance** - Update or regenerate project assets
- **Automation** - Batch processing and repetitive tasks

## Location

All editor tools are located in:
```
scripts/editor_tools/
```

This separates them from game logic scripts in the main `scripts/` directory.

## Available Tools

### setup_base_theme.gd

**What it does:** Generates `themes/base_theme.tres` with comprehensive styling matching the framework's ThemeColors and ThemeConstants.

**When to use:**
- First time setting up the project
- After accidentally deleting or corrupting base_theme.tres
- To reset the theme to framework defaults

**How to run:**
1. Open Godot Editor
2. Navigate to `scripts/editor_tools/setup_base_theme.gd`
3. Click the file
4. Menu: **File → Run**
5. Check output for success message
6. Reload Godot project

**Output:**
- Creates `themes/base_theme.tres`
- Includes Panel, Button, Label, and all UI control styles
- Sets default margins (50px) and spacing (20px)
- Applies ThemeColors palette

## Running Editor Tools

### Method 1: Via Editor UI (Recommended)

1. **Open Godot Editor** with your project
2. **Navigate to the tool:**
   - Go to FileSystem panel
   - Find `scripts/editor_tools/[tool_name].gd`
3. **Click the script file**
   - Single-click to select it
4. **Run the tool:**
   - Menu: **File → Run**
   - Or right-click → **Run**
5. **Check the Output panel:**
   - View results and any error messages
   - Look for success confirmation

### Method 2: Via Command Line

```bash
# Run in headless mode
godot --headless --script "res://scripts/editor_tools/setup_base_theme.gd" --quit

# Run with editor (for tools that need editor features)
godot --script "res://scripts/editor_tools/setup_base_theme.gd"
```

**Note:** Some tools may require the full editor environment and won't work in headless mode.

## Creating Your Own Editor Tools

### Basic Template

```gdscript
@tool
extends EditorScript

## [Tool Name] - [One-line description]
##
## [Detailed description of what this tool does and why]
##
## Usage:
##   1. [Step-by-step instructions]
##   2. [for running the tool]
##
## Output:
##   - [What files/resources are created]
##   - [What gets modified]

func _run():
	print("=== [Tool Name] Starting ===")

	# Your tool logic here
	var result := do_something()

	if result:
		print("✅ [Tool Name] completed successfully!")
		print("Created: [list what was created]")
	else:
		push_error("❌ [Tool Name] failed!")

func do_something() -> bool:
	# Implementation
	return true
```

### Requirements

1. **Must use `@tool` annotation** at the top of the file
2. **Must extend `EditorScript`**
3. **Must implement `_run()` function** - this is the entry point
4. **Should have clear documentation** in docstring format

### Best Practices

#### 1. Clear Output
Always provide clear feedback:
```gdscript
print("=== Setup Base Theme ===")
print("Creating theme resource...")
print("✅ Successfully saved: res://themes/base_theme.tres")
```

Use emoji for visual feedback:
- ✅ Success
- ❌ Error
- ⚠️ Warning
- 🔧 Action in progress
- 📝 Information

#### 2. Error Handling
Always check for errors:
```gdscript
var err := ResourceSaver.save(resource, path)
if err != OK:
	push_error("Failed to save resource. Error code: " + str(err))
	return false
```

#### 3. Validate Before Action
Check preconditions:
```gdscript
if not DirAccess.dir_exists_absolute("res://themes"):
	push_error("themes/ directory does not exist!")
	return false

if FileAccess.file_exists(output_path):
	push_warning("File already exists, will be overwritten: " + output_path)
```

#### 4. Idempotent Operations
Make tools safe to run multiple times:
```gdscript
# Safe to run multiple times
if FileAccess.file_exists(path):
	print("⚠️  Resource already exists, recreating...")

# Always create a fresh resource
var theme := Theme.new()
ResourceSaver.save(theme, path)
```

#### 5. Documentation
Document thoroughly:
```gdscript
## Setup Localization Files
##
## This tool generates translation template files for all supported languages.
## It scans the project for translation keys and creates empty CSV files.
##
## Usage:
##   1. Run this script via File → Run
##   2. Check translations/ folder for generated files
##   3. Fill in translations for each language
##
## Output:
##   - translations/en.csv
##   - translations/de.csv
##   - translations/hu.csv
##   - translations/ja.csv
##
## Note: Existing files will be backed up before regeneration.
```

### Example: Resource Generator

```gdscript
@tool
extends EditorScript

## Generate Icon Atlas
##
## Combines all icons from assets/icons/ into a single texture atlas
## for optimized rendering and easier management.
##
## Usage:
##   1. Place icon PNG files in assets/icons/
##   2. Run this script
##   3. Atlas will be generated at themes/icon_atlas.tres

func _run():
	print("=== Generate Icon Atlas ===")

	var icons_path := "res://assets/icons"
	var output_path := "res://themes/icon_atlas.tres"

	# Validate input directory
	if not DirAccess.dir_exists_absolute(icons_path):
		push_error("Icons directory not found: " + icons_path)
		return

	# Scan for icons
	print("🔍 Scanning for icons...")
	var icons := _scan_icons(icons_path)

	if icons.is_empty():
		push_warning("⚠️  No icons found in " + icons_path)
		return

	print("📝 Found " + str(icons.size()) + " icons")

	# Generate atlas
	print("🔧 Generating atlas...")
	var atlas := _create_atlas(icons)

	# Save
	var err := ResourceSaver.save(atlas, output_path)
	if err != OK:
		push_error("❌ Failed to save atlas. Error: " + str(err))
		return

	print("✅ Successfully created: " + output_path)
	print("   Atlas contains " + str(icons.size()) + " icons")

func _scan_icons(path: String) -> Array[String]:
	var icons: Array[String] = []
	var dir := DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if file_name.ends_with(".png"):
				icons.append(path + "/" + file_name)
			file_name = dir.get_next()

		dir.list_dir_end()

	return icons

func _create_atlas(icons: Array[String]) -> Resource:
	# Implementation here
	return Resource.new()
```

## Naming Conventions

### File Names
Use descriptive snake_case names with action prefixes:

- `setup_*` - Initial setup/configuration
  - `setup_base_theme.gd`
  - `setup_project_structure.gd`

- `generate_*` - Resource generation
  - `generate_icons.gd`
  - `generate_translations.gd`

- `validate_*` - Validation and checking
  - `validate_scenes.gd`
  - `validate_translations.gd`

- `export_*` - Data export
  - `export_localization_keys.gd`
  - `export_asset_list.gd`

- `import_*` - Data import
  - `import_translations.gd`
  - `import_sprite_sheets.gd`

### Function Names
Follow GDScript conventions:
- Use snake_case for all functions
- Prefix private functions with `_`
- Use clear, descriptive verbs

```gdscript
# Public functions
func run_tool():
func validate_input():
func create_resource():

# Private helpers
func _scan_directory():
func _process_file():
func _save_result():
```

## Organization

### Current Structure
```
scripts/editor_tools/
├── README.md
└── setup_base_theme.gd
```

### As You Add Tools
Group related tools:
```
scripts/editor_tools/
├── README.md
├── setup/
│   ├── setup_base_theme.gd
│   ├── setup_localization.gd
│   └── setup_project_structure.gd
├── generators/
│   ├── generate_icons.gd
│   ├── generate_sprite_atlas.gd
│   └── generate_translations.gd
├── validators/
│   ├── validate_scenes.gd
│   └── validate_resources.gd
└── utils/
    └── editor_helpers.gd
```

## Troubleshooting

### "Run" Option Grayed Out

**Cause:** Script missing `@tool` or not extending EditorScript

**Solution:**
```gdscript
# Must have both of these
@tool
extends EditorScript
```

### Script Runs But Nothing Happens

**Causes:**
1. Silent errors (check Output panel)
2. Wrong file paths
3. Missing dependencies

**Solutions:**
- Check Output panel for error messages
- Verify all paths use `res://` prefix
- Add print statements to debug
- Check file permissions

### Changes Don't Appear

**Causes:**
1. Editor caching
2. Resource not reloaded
3. File not actually saved

**Solutions:**
- Close and reopen Godot project
- Check FileSystem to verify file exists
- Check file timestamps
- Clear editor cache (delete `.godot/` folder while editor is closed)

### Tool Fails in Headless Mode

**Cause:** Tool uses editor-specific features

**Solution:**
- Run with full editor instead of headless
- Or refactor tool to not depend on editor features
- Document that tool requires full editor

## Integration with CI/CD

Editor tools can be integrated into CI/CD pipelines:

```yaml
# .github/workflows/generate-resources.yml
name: Generate Resources

on:
  push:
    paths:
      - 'assets/**'

jobs:
  generate:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.5

    steps:
      - uses: actions/checkout@v3

      - name: Generate icon atlas
        run: |
          godot --headless --script res://scripts/editor_tools/generate_icons.gd --quit

      - name: Commit generated files
        run: |
          git config user.name "CI Bot"
          git config user.email "ci@example.com"
          git add themes/
          git commit -m "chore: regenerate icon atlas" || echo "No changes"
          git push
```

## Best Practices Summary

✅ **DO:**
- Use `@tool` and extend `EditorScript`
- Provide clear output with emoji indicators
- Validate all inputs and preconditions
- Handle errors gracefully
- Document thoroughly
- Make tools idempotent
- Test in both editor and headless mode

❌ **DON'T:**
- Mix editor tools with game logic
- Leave tools in broken state
- Overwrite files without warning
- Use hardcoded paths (use `res://`)
- Forget error handling
- Skip documentation

## Future Enhancements

Potential tools to add:
- **Translation validator** - Check for missing keys
- **Asset optimizer** - Compress images and audio
- **Scene validator** - Verify all scenes load correctly
- **Dependency checker** - List all resource dependencies
- **Export profiler** - Analyze export sizes
- **Documentation generator** - Auto-generate API docs

## Additional Resources

- **Editor Tools Location:** `scripts/editor_tools/`
- **Editor Tools README:** `scripts/editor_tools/README.md`
- **Godot EditorScript Docs:** https://docs.godotengine.org/en/stable/classes/class_editorscript.html
- **This Project's Guide:** `docs/editor_tools_guide.md` (this file)
