# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 learning project configured with GL Compatibility rendering. The project uses Hungarian language UI elements (e.g., "Tanuld meg a Godót!" title in main menu).

## Project Structure

- `scenes/` - Godot scene files (.tscn)
  - `main_menu.tscn` - Main entry point (set as main scene in project.godot)
  - `game.tscn` - Game scene with navigation back to main menu
- `scripts/` - GDScript files (.gd)
  - `main_menu.gd` - Controls Start/Options/Quit buttons
  - `game.gd` - Game scene controller with back navigation
- `themes/` - Godot theme resources (.tres)
  - `main_menu.tres` - UI theme with italic SystemFont and custom button styling

## Scene Navigation

The project uses `get_tree().change_scene_to_file()` for scene transitions:
- Main menu → Game: `res://scenes/game.tscn` (scripts/main_menu.gd:10)
- Game → Main menu: `res://scenes/main_menu.tscn` (scripts/game.gd:4)

Main menu has a disabled "Options" button that is not yet implemented.

## Running the Project

This project must be opened and run through the Godot 4.5 editor. Use the editor's play button or F5 to run the project. There are no command-line build or test commands configured for this learning project.

## File Editing Notes

- `.tscn` and `.tres` files are Godot's text-based scene/resource format - edit with care as they contain UIDs and node relationships
- The `.godot/` directory contains editor cache and metadata - excluded from git
- GDScript files use tabs for indentation
- Scene connections use signal bindings (e.g., `[connection signal="pressed" from="..." to="..." method="..."]`)
