@echo off
REM Verifies that all required addons are installed
echo Checking addon setup...
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --script setup_addons.gd
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Setup complete! You can start developing.
) else (
    echo.
    echo Please install missing addons before continuing.
)
pause
