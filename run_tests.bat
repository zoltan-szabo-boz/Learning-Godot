@echo off
REM Runs all GUT tests from command line
echo Running GUT tests...
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --path "%~dp0" -s addons/gut/gut_cmdln.gd
