# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 learning project configured with GL Compatibility rendering. The project supports multiple languages (English and Hungarian) through a localization system.

**Development Approach:** This project follows Test-Driven Development (TDD) principles. All systems should have basic tests written upon implementation to ensure functionality and prevent regressions.

## Project Structure

- `scenes/` - Godot scene files (.tscn)
  - `main_menu.tscn` - Main entry point (set as main scene in project.godot)
  - `game.tscn` - Game scene with navigation back to main menu
- `scripts/` - GDScript files (.gd)
  - `main_menu.gd` - Controls Start/Options/Quit buttons and language selection
  - `game.gd` - Game scene controller with back navigation
  - `file_manager.gd` - Singleton for filesystem abstraction (console-ready)
  - `config_manager.gd` - Singleton for game settings persistence
  - `localization_manager.gd` - Singleton for language management
- `themes/` - Godot theme resources (.tres)
  - `main_menu.tres` - UI theme with italic SystemFont and custom button styling
- `translations/` - Localization files
  - `translations.csv` - Translation keys for all UI text (en, hu)
- `tests/` - Automated test files using GUT framework
- `Dockerfile` - Docker image definition for headless testing
- `docker-compose.yml` - Docker services: test, validate, shell

## Scene Navigation

The project uses `get_tree().change_scene_to_file()` for scene transitions:
- Main menu → Game: `res://scenes/game.tscn` (scripts/main_menu.gd:16)
- Game → Main menu: `res://scenes/main_menu.tscn` (scripts/game.gd:4)

## Core Systems

### FileManager (scripts/file_manager.gd)
Filesystem abstraction layer designed for console compatibility:
- Mount/unmount support for console platforms
- Write queue with auto-flush timer (5 second interval)
- Batched writes to reduce I/O operations
- Config file read/write methods
- Platform detection (currently supports PC, ready for PS/Xbox/Switch)
- Singleton accessible via `FileManager` global

### ConfigManager (scripts/config_manager.gd)
Manages game settings and persists them via FileManager:
- Resolution settings (1920x1080, 1280x720, 1600x900, 1366x768, 1024x768)
- Fullscreen mode toggle
- Settings stored in `user://config.cfg`
- Auto-loads and applies settings on startup
- Singleton accessible via `ConfigManager` global

### LocalizationManager (scripts/localization_manager.gd)
Handles multi-language support using Godot's TranslationServer:
- Supports English (en) and Hungarian (hu)
- Auto-detects system language on first run
- Persists language preference via FileManager
- Uses CSV translation files (translations/translations.csv)
- Emits `language_changed` signal for runtime updates
- Singleton accessible via `LocalizationManager` global

## Localization System

The project uses Godot's built-in localization with CSV translation files:

### Adding Translatable Text
1. **In scenes (.tscn)**: Set text properties to UPPERCASE keys (e.g., `text = "BUTTON_START_GAME"`)
2. **In scripts (.gd)**: Use `tr("KEY")` function for dynamic text (e.g., `print(tr("MESSAGE_STARTING_GAME"))`)
3. **Add keys to CSV**: Update `translations/translations.csv` with key and translations

### Translation Keys Convention
- Use UPPERCASE for all keys (e.g., `GAME_TITLE`, `BUTTON_OPTIONS`)
- Prefix categories: `BUTTON_*`, `LABEL_*`, `MESSAGE_*`, `TOOLTIP_*`, `LANGUAGE_*`
- Scene elements auto-translate on language change
- Use string formatting with tr() for dynamic values: `tr("MESSAGE_RESOLUTION_CHANGED") % [width, height]`

## Testing Framework

This project uses GUT (Godot Unit Test) for automated testing. All core systems should have corresponding test files.

### Test Structure

- `tests/` - Test files directory
  - `test_*.gd` - Test files (extend GutTest)
- `addons/gut/` - GUT testing framework

### Running Tests

**In Godot Editor:**
1. Open the GUT panel (bottom panel tabs)
2. Click "Run All" to execute all tests
3. View results in the panel

**Via Docker:**

The project includes Docker support for headless testing and CI/CD:

```bash
# Run all tests
docker-compose run test

# Run project validation
docker-compose run validate

# Open interactive shell for debugging
docker-compose run shell
```

**Docker Setup:**
- Uses `barichello/godot-ci:4.5` base image
- Tests run via GUT command-line interface (`addons/gut/gut_cmdln.gd`)
- Project mounted at `/workspace` in container
- Headless mode for CI/CD compatibility

### Writing Tests

Follow these conventions when writing tests:

1. **File Naming:** `test_<system_name>.gd` (e.g., `test_localization_manager.gd`)

2. **Test Structure:**
```gdscript
extends GutTest

# Setup runs before each test
func before_each():
    # Initialize test fixtures
    pass

# Teardown runs after each test
func after_each():
    # Clean up test fixtures
    pass

# Test functions must start with 'test_'
func test_something():
    assert_eq(actual, expected, "Descriptive message")
```

3. **Common Assertions:**
   - `assert_eq(a, b, msg)` - Assert equal
   - `assert_ne(a, b, msg)` - Assert not equal
   - `assert_true(condition, msg)` - Assert true
   - `assert_false(condition, msg)` - Assert false
   - `assert_not_null(value, msg)` - Assert not null
   - `assert_gt(a, b, msg)` - Assert greater than
   - `assert_signal_emitted(object, signal_name, msg)` - Assert signal was emitted

4. **Testing Singletons:**
   - Access autoload singletons directly: `LocalizationManager`, `ConfigManager`, `FileManager`
   - Remember to restore state in `after_each()` to prevent test pollution

5. **Testing Scenes:**
   - Preload scene: `var scene = preload("res://scenes/main_menu.tscn")`
   - Instantiate: `var instance = scene.instantiate()`
   - Add to tree: `add_child(instance)`
   - Clean up: `instance.queue_free()` in `after_each()`

6. **Async Testing:**
   - Use `await get_tree().process_frame` for operations that need a frame
   - Use `await` for signals or timeouts

### TDD Guidelines

When implementing new features:

1. **Write tests first** (when practical) or **immediately after** implementation
2. **Test core functionality:**
   - Initialization and default states
   - Public API methods
   - Edge cases and error handling
   - Signal emissions
   - State persistence (for systems using FileManager)
3. **Keep tests simple and focused** - one concept per test
4. **Use descriptive test names** - `test_language_change_emits_signal()` not `test_1()`
5. **Don't test implementation details** - test behavior, not internal structure

### Existing Test Coverage

- ✅ `test_calculator.gd` - Calculator utility tests
- ✅ `test_game.gd` - Game scene tests
- ✅ `test_main_menu.gd` - Main menu scene and UI tests
- ✅ `test_localization_manager.gd` - Localization system tests

### Test Coverage Targets

All core systems should have tests covering:
- **FileManager:** File operations, mount/unmount, queue/flush, platform detection
- **ConfigManager:** Settings load/save, resolution changes, fullscreen toggle
- **LocalizationManager:** Language switching, translation key lookup, persistence (✅ Implemented)

## Running the Project

This project must be opened and run through the Godot 4.5 editor. Use the editor's play button or F5 to run the project.

## File Editing Notes

- `.tscn` and `.tres` files are Godot's text-based scene/resource format - edit with care as they contain UIDs and node relationships
- The `.godot/` directory contains editor cache and metadata - excluded from git
- GDScript files use tabs for indentation
- Scene connections use signal bindings (e.g., `[connection signal="pressed" from="..." to="..." method="..."]`)
