# Boz Godot Framework

A professional Godot 4.5 framework configured with GL Compatibility rendering. Provides a robust foundation for game development with comprehensive systems including localization, event management, dynamic tooltips, file handling, and more.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Onboarding Setup](#onboarding-setup)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Building](#building)
- [Project Structure](#project-structure)
- [Dependency Management & Docker](#dependency-management--docker)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- **Godot 4.5** or later
- **Visual Studio Code**
- **Git** (for version control)

## Onboarding Setup

### 1. Install Godot Engine

1. Download Godot 4.5+ from [godotengine.org](https://godotengine.org/download)
2. Extract to a known location (e.g., `D:\Godot\Godot_v4.5.1-stable_win64.exe`)
3. No installation required - Godot is portable

### 2. Install VS Code Extension

1. Open VS Code
2. Install the **godot-tools** extension:
   - Press `Ctrl+Shift+X` to open Extensions
   - Search for "godot-tools" by geequlim
   - Click Install
3. Reload VS Code if prompted

### 3. Configure VS Code

The project already includes `.vscode/` configuration files:

- **settings.json** - Configures Godot paths and LSP connection
- **launch.json** - Debug configurations for F5 launching
- **extensions.json** - Recommends required extensions

**Important**: Verify the Godot path in `.vscode/settings.json` matches your installation:

```json
"godotTools.editorPath.godot4": "d:\\Godot\\Godot_v4.5.1-stable_win64.exe"
```

### 4. Start the Language Server

1. Open the Godot Editor
2. Open this project: `File > Open Project` → select project folder
3. Go to `Editor > Editor Settings > Network > Language Server`
4. Ensure **Remote Port** is set to `6050` (default: 6005)
5. Ensure **Use Thread** is enabled
6. Restart Godot editor

The language server must be running for VS Code features to work (autocomplete, debugging, etc.).

### 5. Verify Connection

1. Open a `.gd` file in VS Code
2. You should see:
   - Syntax highlighting
   - Autocomplete suggestions
   - No connection errors in bottom status bar

If connection fails, see [Troubleshooting](#troubleshooting).

## Development Workflow

### Editing Files

**Edit these files directly in VS Code:**

- `scripts/*.gd` - GDScript logic files
- `scenes/*.tscn` - Godot scene files (text format)
- `themes/*.tres` - Godot resource files (text format)

**Godot editor auto-reloads** changes when you save in VS Code.

### Running & Debugging

**Keep Godot editor open** while developing (for LSP server).

#### Debug Configurations (F5)

Press `F5` or click Run > Start Debugging, then select:

1. **Launch in Godot Editor** (default)

   - Runs the main scene (`res://scenes/main_menu.tscn`)
   - Use for general testing

2. **Launch Current Scene**

   - Runs whatever scene file you have open in VS Code
   - Use for testing specific scenes

3. **Headless Server**
   - Runs without graphics window
   - Use for server logic or automated testing

#### Debug Controls

| Key             | Action                     |
| --------------- | -------------------------- |
| `F5`            | Start debugging / Continue |
| `Shift+F5`      | Stop debugging             |
| `Ctrl+Shift+F5` | Restart debugging          |
| `F9`            | Toggle breakpoint          |
| `F10`           | Step over                  |
| `F11`           | Step into                  |
| `Shift+F11`     | Step out                   |

#### Breakpoints

1. Click left of line number in VS Code to set breakpoint
2. Run with `F5`
3. Execution pauses at breakpoint
4. Inspect variables in Debug panel
5. Use step controls to navigate code

### Alternative: Run in Godot Editor

If you prefer running from Godot:

- `F5` - Run project (main scene)
- `F6` - Run current scene
- `F8` - Stop

## Testing

### Manual Testing

Run the game and verify:

- Main menu displays with title "Tanuld meg a Godót!"
- Start button launches game scene
- Options button is disabled (not implemented)
- Quit button exits application
- Back button in game returns to main menu

### Automated Validation

Run the validation script to check project integrity:

```bash
# Windows
validate.bat

# Manual validation
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --path "D:\Godot\boz-godot-framework" --script res://scripts/validate_project.gd
```

The script checks:

- Required scene files exist
- Required script files exist
- Exit code 0 = passed, 1 = failed

### Unit Testing with GUT

This project includes GUT (Godot Unit Test) framework for automated testing.

#### Running Tests in Godot Editor

1. Open Godot Editor with this project
2. Open the GUT panel (usually at bottom of editor)
3. Click "Run All" to run all tests
4. Or select specific test file and click "Run"

#### Running Tests from Command Line

```bash
# Run all tests
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --path "D:\Godot\boz-godot-framework" -s addons/gut/gut_cmdln.gd

# Run specific test
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --path "D:\Godot\boz-godot-framework" -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_calculator.gd
```

#### Included Tests

The project includes example tests in `tests/`:

- **test_calculator.gd** - Unit tests for pure logic (Calculator class)
  - Tests addition, subtraction, multiplication, division
  - Tests edge cases like division by zero
  - Tests helper functions (is_even, is_positive)

- **test_main_menu.gd** - Integration tests for main menu scene
  - Tests scene loading
  - Tests button existence and states
  - Tests UI elements (title, buttons)

- **test_game.gd** - Integration tests for game scene
  - Tests scene loading
  - Tests back button functionality
  - Tests scene elements

#### Writing New Tests

Create test files in `tests/` directory following this pattern:

```gdscript
extends GutTest

# Setup runs before each test
func before_each():
    # Setup code here
    pass

# Test functions must start with "test_"
func test_something():
    assert_eq(2 + 2, 4, "Math should work")
    assert_true(true, "This should pass")
    assert_not_null(Node.new(), "Nodes should be created")
```

Common GUT assertions:
- `assert_eq(got, expected, message)` - Values are equal
- `assert_ne(got, expected, message)` - Values are not equal
- `assert_true(condition, message)` - Condition is true
- `assert_false(condition, message)` - Condition is false
- `assert_null(value, message)` - Value is null
- `assert_not_null(value, message)` - Value is not null
- `assert_gt(got, expected, message)` - Greater than
- `assert_lt(got, expected, message)` - Less than
- `assert_almost_eq(got, expected, error, message)` - Approximately equal (for floats)

## Building

### Export for Distribution

This is a learning project without export templates configured. To build for distribution:

1. **Install Export Templates**

   - Open Godot Editor
   - `Editor > Manage Export Templates`
   - Download for your Godot version

2. **Configure Export Preset**

   - `Project > Export`
   - Add preset (Windows Desktop, Linux, etc.)
   - Configure settings (name, icon, etc.)

3. **Export Project**
   - Select preset
   - Click "Export Project"
   - Choose output location
   - Creates standalone executable

### Quick Export Commands

After export presets are configured:

```bash
# Export Windows build
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --export-release "Windows Desktop" "builds/windows/game.exe"

# Export Linux build
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --export-release "Linux/X11" "builds/linux/game.x86_64"
```

### Development Build Testing

For testing without full export:

```bash
# Run headless
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --path "D:\Godot\boz-godot-framework"

# Run specific scene
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --path "D:\Godot\boz-godot-framework" res://scenes/game.tscn

# Run and quit after 100 frames
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --path "D:\Godot\boz-godot-framework" --quit-after 100
```

## Project Structure

```
boz-godot-framework/
├── .godot/                 # Editor cache (gitignored)
├── .vscode/                # VS Code configuration
│   ├── settings.json       # Godot paths, LSP config
│   ├── launch.json         # Debug configurations
│   └── extensions.json     # Recommended extensions
├── addons/                 # Third-party plugins
│   └── gut/                # GUT testing framework
├── scenes/                 # Godot scene files
│   ├── main_menu.tscn      # Main menu (entry point)
│   └── game.tscn           # Game scene
├── scripts/                # GDScript files
│   ├── main_menu.gd        # Main menu controller
│   ├── game.gd             # Game scene controller
│   ├── calculator.gd       # Calculator utility (example)
│   └── validate_project.gd # Validation script
├── tests/                  # GUT test files
│   ├── test_calculator.gd  # Unit tests for Calculator
│   ├── test_main_menu.gd   # Integration tests for main menu
│   └── test_game.gd        # Integration tests for game scene
├── themes/                 # UI themes
│   └── main_menu.tres      # Main menu theme
├── .gutconfig.json         # GUT test runner configuration
├── CLAUDE.md               # AI assistant guidelines
├── project.godot           # Godot project configuration
├── README.md               # This file
├── run_tests.bat           # Run all GUT tests (Windows)
└── validate.bat            # Validation script (Windows)
```

### Key Files

- **project.godot** - Project configuration, main scene setting
- **scenes/main_menu.tscn** - Entry point (set as main scene)
- **scripts/main_menu.gd** - Controls Start/Options/Quit buttons
- **scripts/game.gd** - Game scene with back button navigation

### Scene Navigation

Scene transitions use `get_tree().change_scene_to_file()`:

- Main menu → Game: `res://scenes/game.tscn` (scripts/main_menu.gd:10)
- Game → Main menu: `res://scenes/main_menu.tscn` (scripts/game.gd:4)

## Dependency Management & Docker

This project includes comprehensive tooling for reproducible development environments.

### Addon Management

**Current approach: Addons are committed to git**

Why?
- ✅ Zero setup after `git clone`
- ✅ Guaranteed version consistency
- ✅ Godot has no official package manager (unlike npm)

Verify addon setup:
```bash
setup_check.bat
```

### Dependency Tracking

We maintain `addons.json` (similar to package.json) that documents:
- Required addons and versions
- Installation sources (AssetLib, GitHub)
- Godot version requirements

### Docker Support

For CI/CD and headless testing:

```bash
# Build Docker image
docker build -t bozs-godot-framework .

# Run tests in container
docker-compose run --rm test

# Run validation in container
docker-compose run --rm validate

# Interactive shell
docker-compose run --rm shell
```

**Note**: Docker is for headless testing/CI. For visual development, use local Godot Editor.

### VS Code Dev Containers

For isolated development:
1. Install "Dev Containers" extension
2. `Ctrl+Shift+P` → "Reopen in Container"
3. VS Code rebuilds with Godot pre-installed

**See [DEVELOPMENT.md](DEVELOPMENT.md) for complete details** on:
- Alternative addon management strategies (git submodules, gd-plug)
- Complete Docker workflow
- CI/CD integration examples (GitHub Actions, GitLab CI)
- Version pinning best practices

## Troubleshooting

### VS Code can't connect to Godot

**Symptoms**: No autocomplete, "Language server not connected" error

**Solution**:

1. Check Godot editor is running with project open
2. Verify LSP port matches in both places:
   - Godot: `Editor > Editor Settings > Network > Language Server > Remote Port`
   - VS Code: `.vscode/settings.json` → `godot_tools.gdscript_lsp_server_port`
3. Restart Godot editor
4. Reload VS Code window (`Ctrl+Shift+P` → "Reload Window")
5. Check port is listening:
   ```bash
   netstat -an | findstr "6050"
   ```

### F5 debugging doesn't work

**Solution**:

1. Ensure Godot editor is running (LSP server must be active)
2. Check Godot path in `.vscode/settings.json`
3. Try running from Godot editor first (`F5` in Godot)
4. Check Output panel in VS Code for errors

### Syntax errors in .tscn or .tres files

**Solution**:

- These are Godot's text-based formats with specific structure
- Avoid manual editing of node IDs, UIDs, and connections
- Use Godot editor for scene structure changes
- VS Code is best for script logic in `.gd` files

### Changes not reflecting in game

**Solution**:

1. Save the file in VS Code (`Ctrl+S`)
2. Godot should auto-reload
3. If not, restart the scene in Godot (`F6`)
4. For scene file changes, may need to close and reopen scene in Godot

## Additional Resources

- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot VS Code Extension](https://github.com/godotengine/godot-vscode-plugin)
- [GUT Testing Framework](https://github.com/bitwes/Gut)

## License

This is a learning project. Feel free to use and modify as needed.
