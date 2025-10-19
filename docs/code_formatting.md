# Code Formatting Guide

## Overview

This project uses consistent code formatting for GDScript files to maintain readability and prevent merge conflicts.

## Automatic Formatting in VSCode

The project is configured to automatically format GDScript files on save.

### Setup

1. **Install the Godot Tools Extension**
   - Open VSCode
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "godot-tools" by geequlim
   - Install it
   - (The project will prompt you to install this extension automatically)

2. **Verify Configuration**
   - The `.vscode/settings.json` file already configures:
     - Default formatter: `geequlim.godot-tools`
     - Format on save: enabled
     - Tab size: 4 spaces (using tabs, not spaces)

3. **Format Configuration**
   - The `.gdformat` file in the project root defines formatting rules:
     - Indentation: Tabs
     - Tab size: 4 spaces
     - Max line length: 100 characters

### Manual Formatting

To manually format a file:
- **Windows/Linux**: `Shift+Alt+F`
- **Mac**: `Shift+Option+F`
- Or: Right-click → "Format Document"

## Formatting Rules

### Indentation
```gdscript
# ✅ Good: Use tabs
func my_function():
	if condition:
		do_something()
	else:
		do_something_else()

# ❌ Bad: Don't use spaces
func my_function():
    if condition:
        do_something()
```

### Line Length
Keep lines under 100 characters when possible:
```gdscript
# ✅ Good: Break long lines
var tooltip_text = tr("TOOLTIP_LONG_DESCRIPTION") % [
	player_name,
	player_level,
	player_health
]

# ❌ Bad: Too long
var tooltip_text = tr("TOOLTIP_LONG_DESCRIPTION") % [player_name, player_level, player_health, player_mana, player_stamina]
```

### Spacing
```gdscript
# ✅ Good: Consistent spacing
func calculate(a: int, b: int) -> int:
	return a + b

var result: int = 42
var array: Array = [1, 2, 3]

# ❌ Bad: Inconsistent spacing
func calculate(a:int,b:int)->int:
	return a+b

var result:int=42
var array:Array=[1,2,3]
```

### Comments
```gdscript
# ✅ Good: Space after #
# This is a comment
func my_function():
	pass  # Inline comment

# ❌ Bad: No space after #
#This is a comment
func my_function():
	pass#Inline comment
```

## GDScript Style Guide

Follow Godot's official GDScript style guide:
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

### Key Points

1. **Naming Conventions**
   - Files: `snake_case.gd`
   - Classes: `PascalCase`
   - Functions: `snake_case`
   - Variables: `snake_case`
   - Constants: `CONSTANT_CASE`
   - Signals: `snake_case`

2. **Type Hints**
   Always use type hints:
   ```gdscript
   var health: int = 100
   var player_name: String = "Hero"

   func calculate_damage(base: int, multiplier: float) -> int:
       return int(base * multiplier)
   ```

3. **Documentation**
   Document public functions:
   ```gdscript
   ## Calculates the damage dealt to an enemy.
   ##
   ## Takes base damage and applies various multipliers based on
   ## player stats and enemy resistances.
   ##
   ## Returns the final damage value as an integer.
   func calculate_damage(base: int) -> int:
       return base * damage_multiplier
   ```

4. **Signal Declarations**
   Document signals and put them at the top:
   ```gdscript
   extends Node

   ## Emitted when the player's health changes.
   signal health_changed(new_health: int)

   ## Emitted when the player dies.
   signal player_died
   ```

5. **Exports**
   Use exports for designer-friendly values:
   ```gdscript
   @export var max_health: int = 100
   @export var move_speed: float = 5.0
   @export_range(0, 1) var damage_reduction: float = 0.5
   ```

## EditorConfig

The project uses the `.gdformat` file for configuration. This ensures consistent formatting across all editors and CI/CD pipelines.

## CI/CD Integration

For future CI/CD setup, you can use `gdformat` command-line tool:

```bash
# Install gdtoolkit
pip install gdtoolkit

# Check formatting (dry run)
gdformat --check scripts/

# Format all files
gdformat scripts/

# Format specific file
gdformat scripts/main_menu.gd
```

## Troubleshooting

### Formatter Not Working

1. **Check Extension Installation**
   - Ensure "godot-tools" extension is installed and enabled

2. **Check Godot Tools Configuration**
   - Open settings (Ctrl+,)
   - Search for "godot"
   - Verify "Godot Tools: Editor Path" points to your Godot executable

3. **Reload VSCode**
   - Press Ctrl+Shift+P
   - Type "Reload Window"
   - Select "Developer: Reload Window"

4. **Check LSP Server**
   - The Godot editor must be running for the LSP (Language Server Protocol) to work
   - Start Godot editor with your project open
   - The formatter relies on Godot's built-in LSP server

### Mixed Indentation Errors

If you get indentation errors:
1. Open the file
2. Press Ctrl+Shift+P
3. Type "Convert Indentation"
4. Select "Convert Indentation to Tabs"
5. Save the file

## Command Palette Commands

Useful VSCode commands for GDScript:
- `Format Document` - Format entire file
- `Format Selection` - Format selected code
- `Convert Indentation to Tabs` - Fix spacing issues
- `Trim Trailing Whitespace` - Clean up line endings

## Best Practices

1. **Format Before Committing**
   - Run formatter before each git commit
   - Ensures consistent code style in version control

2. **Enable Format on Save**
   - Already enabled in project settings
   - Automatically formats when you save

3. **Use Consistent Style**
   - Follow the project's established patterns
   - When in doubt, check similar existing code

4. **Don't Fight the Formatter**
   - Trust the formatter's decisions
   - Adjust code to work with formatter, not against it
