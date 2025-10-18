@echo off
REM Validates the Godot project for errors
echo Checking Godot project for errors...
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --path "%~dp0" --script res://scripts/validate_project.gd
