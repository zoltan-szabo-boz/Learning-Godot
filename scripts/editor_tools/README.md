# Editor Tools

This directory contains EditorScript utilities and tools for setting up, configuring, and maintaining the project. These scripts are **not** part of the game logic and only run in the Godot Editor.

## What Are Editor Tools?

Editor tools are scripts that extend `EditorScript` and use the `@tool` annotation. They:
- Run manually via **File → Run** in the Godot Editor
- Generate or configure project resources
- Automate setup and maintenance tasks
- Do not run during gameplay

## Available Tools

### setup_base_theme.gd

**Purpose:** Generates the `themes/base_theme.tres` resource with comprehensive styling.

**When to Run:**
- First time setting up the project
- After deleting or corrupting base_theme.tres
- To reset theme to framework defaults

**Usage:**
1. In Godot Editor, navigate to `scripts/editor_tools/setup_base_theme.gd`
2. Click the file in FileSystem panel
3. Menu: **File → Run**
4. Check output for "✅ Successfully created base_theme.tres"
5. Close and reopen Godot to reload the theme

**What It Creates:**
- `themes/base_theme.tres` with Panel, Button, Label styling
- Default margins (50px) and spacing (20px)
- Colors matching ThemeColors palette
- All UI control styles for consistent appearance

---

## Creating New Editor Tools

When creating editor tools, follow these conventions:

### File Naming
- Use descriptive snake_case names: `setup_localization.gd`, `generate_icons.gd`
- Prefix with action: `setup_*`, `generate_*`, `validate_*`, `export_*`

### Script Template

```gdscript
@tool
extends EditorScript

## [Tool Name] - [Brief Description]
##
## [Detailed description of what this tool does]
##
## Usage:
##   1. [Step 1]
##   2. [Step 2]
##   3. [etc]

func _run():
	print("[Tool Name] running...")

	# Your tool logic here

	print("✅ [Tool Name] completed successfully!")
```

### Best Practices

1. **Always include `@tool` annotation**
   - Required for EditorScript to run in editor

2. **Use clear print statements**
   - Show progress and results
   - Use emoji for visual feedback: ✅ ❌ ⚠️
   - Print what was created/modified

3. **Error handling**
   - Check for file existence before overwriting
   - Validate paths and resources
   - Use `push_error()` for failures

4. **Document everything**
   - Clear docstring at top of file
   - Usage instructions in comments
   - Expected output and side effects

5. **Make idempotent when possible**
   - Safe to run multiple times
   - Don't break existing setup
   - Warn before overwriting

### Example: Error Handling

```gdscript
func _run():
	var save_path := "res://some/file.tres"

	# Check if file exists
	if FileAccess.file_exists(save_path):
		push_warning("File already exists: " + save_path)
		print("⚠️  Overwriting existing file...")

	# Perform operation
	var err := ResourceSaver.save(resource, save_path)

	if err == OK:
		print("✅ Successfully saved: " + save_path)
	else:
		push_error("❌ Failed to save file. Error code: " + str(err))
		return
```

---

## Common Use Cases

### Resource Generation
- Creating themes, fonts, or other resources
- Generating texture atlases
- Building icon sets

### Project Setup
- Initializing folder structures
- Setting up autoloads
- Configuring project settings

### Data Processing
- Importing external data (JSON, CSV)
- Converting between formats
- Batch processing assets

### Validation
- Checking scene integrity
- Validating translation files
- Verifying resource references

### Build Automation
- Pre-export tasks
- Asset optimization
- Version stamping

---

## Running Editor Tools

### Via Godot Editor UI
1. Open Godot Editor
2. Navigate to the tool script in FileSystem
3. Click on the `.gd` file
4. Menu: **File → Run**
5. Check Output panel for results

### Via Command Line (Headless)
```bash
# Run specific editor script
godot --headless --script "res://scripts/editor_tools/setup_base_theme.gd"

# Run with exit after completion
godot --headless --script "res://scripts/editor_tools/setup_base_theme.gd" -quit
```

**Note:** Some tools may require the full editor (not headless) if they depend on editor-specific functionality.

---

## Troubleshooting

### "Run" option is grayed out
- Make sure script has `@tool` annotation at the top
- Script must extend `EditorScript`
- Click directly on the `.gd` file in FileSystem

### Script runs but nothing happens
- Check Output panel for error messages
- Verify file paths are correct (use `res://`)
- Make sure you have write permissions

### Changes don't appear
- Some resources require editor reload
- Close and reopen Godot project
- Check if resource was actually saved (look in FileSystem)

### Script errors on run
- Check GDScript syntax
- Verify all dependencies are available
- Make sure Godot version is compatible (this project uses 4.5)

---

## File Organization

```
scripts/editor_tools/
├── README.md (this file)
├── setup_base_theme.gd           # Theme generation
├── [future tools here]
```

Keep this folder organized:
- Group related tools in subdirectories if needed
- Update this README when adding new tools
- Remove obsolete tools (or move to `deprecated/`)

---

## Version History

- **v1.0** - Initial structure with setup_base_theme.gd
