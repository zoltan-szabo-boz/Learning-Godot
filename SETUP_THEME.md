# Setup Base Theme - Quick Fix

The project won't start because `base_theme.tres` needs to be created with the proper styling.

## Run This Now:

1. **Open Godot Editor** with this project
2. **Navigate to the setup script:**
   - In FileSystem panel: `scripts/setup_base_theme.gd`
3. **Run the script:**
   - Click on `setup_base_theme.gd`
   - Go to menu: **File → Run**
   - Click **Run**
4. **Check the output:**
   - Should see: "✅ Successfully created base_theme.tres"
5. **Close and reopen the project** (to reload the theme)
6. **Run the main scene** (F5)

## What This Does:

The script creates `themes/base_theme.tres` with:
- ✅ Panel styling (dark background matching the old ColorRect)
- ✅ Default margins (50px - matching what was removed)
- ✅ Default spacing (20px - matching what was removed)
- ✅ Button styles (primary colors from ThemeColors)
- ✅ All other UI element styles

## If You Get Errors:

**Error: "Run" option is grayed out**
- Make sure the script file has `@tool` at the top (it does)
- Make sure you clicked on the .gd file in FileSystem

**Error: "Cannot save resource"**
- Make sure `themes/` folder exists
- Check file permissions

**Error: Script runs but theme doesn't apply**
- Close and reopen Godot project
- Check that `project.godot` has: `theme/custom="res://themes/base_theme.tres"`

## Verification:

After running the script and restarting:
- Main menu should load without errors
- Panels should have dark backgrounds
- Buttons should be styled (blue primary color)
- Spacing should look correct

## Alternative: Manual Creation

If the script doesn't work, you can create the theme manually:

1. In Godot Editor, go to `themes/` folder
2. Right-click → **Create New Resource → Theme**
3. Save as `base_theme.tres`
4. Double-click to open Theme Editor
5. Configure Panel, Button, Label styles manually
6. Match the colors from `scripts/theme/theme_colors.gd`

See `docs/theme_system.md` for detailed manual setup instructions.
