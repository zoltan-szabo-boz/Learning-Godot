# Development Environment Setup

This document covers dependency management, reproducible environments, and best practices for developing this Godot project.

## Table of Contents

- [Addon Management](#addon-management)
- [Dependency Tracking](#dependency-tracking)
- [Reproducible Environments](#reproducible-environments)
- [CI/CD Integration](#cicd-integration)

## Addon Management

### Should You Commit Addons?

**Current approach: YES, commit addons to git**

#### Rationale

- **No official package manager**: Unlike npm/pip/cargo, Godot doesn't have a standardized dependency manager
- **Version consistency**: Ensures everyone uses the same addon versions
- **Zero setup**: Project works immediately after `git clone`
- **Small size**: Development addons like GUT are relatively small (~1-5MB)

#### Alternative Approaches

If you prefer NOT to commit addons:

1. **Document in README** (manual installation)
2. **Use `addons.json`** (see below)
3. **Git submodules** (for GitHub-hosted addons)
4. **Community tools** (gd-plug, gdpm - see below)

### Installed Addons

Current addons in this project:

| Addon | Version | Purpose                | Source                                                         |
| ----- | ------- | ---------------------- | -------------------------------------------------------------- |
| GUT   | 9.x     | Unit testing framework | [AssetLib #54](https://godotengine.org/asset-library/asset/54) |

### Setup Verification

Run the setup check script to verify all addons are installed:

```bash
# Windows
setup_check.bat

# Manual check
"d:\Godot\Godot_v4.5.1-stable_win64.exe" --headless --script setup_addons.gd
```

## Dependency Tracking

### addons.json - Project Manifest

We maintain `addons.json` as a package.json equivalent:

```json
{
  "name": "learning-godot",
  "godot_version": "4.5.1",
  "addons": [
    {
      "name": "gut",
      "version": "9.3.0",
      "source": "assetlib",
      "asset_id": "54"
    }
  ]
}
```

This file serves as:

- Documentation of required addons
- Version tracking
- Installation reference for new developers

### Community Dependency Managers

While not used in this project, these community tools exist:

#### 1. gd-plug (Plugin Manager)

GitHub: [imjp94/gd-plug](https://github.com/imjp94/gd-plug)

```gdscript
# plug.gd
plug("bitwes/Gut", {tag = "v9.3.0"})
```

```bash
# Install plugins
godot --no-window -s plug.gd install
```

#### 2. gdpm (Godot Package Manager)

GitHub: [you-win/gdpm](https://github.com/you-win/gdpm)

```bash
# Install gdpm
npm install -g gdpm

# Add dependency
gdpm add gut

# Install all dependencies
gdpm install
```

#### 3. Git Submodules

For addons hosted on GitHub:

```bash
# Add as submodule
git submodule add https://github.com/bitwes/Gut.git addons/gut

# Clone project with submodules
git clone --recursive <repo-url>

# Update submodules
git submodule update --init --recursive
```

### Our Recommendation

For this learning project: **Commit addons directly**

- Simplest approach
- No extra tools required
- Works with Godot's AssetLib workflow

For larger team projects: Consider **gd-plug** or **git submodules**

## Reproducible Environments

### 1. Docker (CI/CD & Headless Testing)

#### Dockerfile

We provide a `Dockerfile` based on official Godot CI images:

```bash
# Build image
docker build -t godot-learning .

# Run tests
docker run --rm godot-learning

# Run validation
docker run --rm godot-learning godot --headless --path /workspace --script res://scripts/validate_project.gd

# Interactive shell
docker run -it --rm godot-learning bash
```

#### Docker Compose

Use `docker-compose.yml` for easier workflow:

```bash
# Run tests
docker-compose run godot-test

# Run validation
docker-compose run godot-validate

# Interactive development
docker-compose run godot-shell
```

**Note**: Docker is primarily for:

- CI/CD pipelines
- Headless testing
- Automated builds
- Server deployment

For local development with Godot Editor, Docker is less practical (GUI apps).

### 2. VS Code Dev Containers

For VS Code users, we provide `.devcontainer/devcontainer.json`:

**To use:**

1. Install "Dev Containers" extension in VS Code
2. Press `Ctrl+Shift+P` → "Reopen in Container"
3. VS Code rebuilds inside Docker with Godot installed

**Benefits:**

- Isolated environment
- Consistent across team
- Pre-configured VS Code settings
- Works on any platform (Windows/Mac/Linux)

**Limitations:**

- Headless only (no Godot Editor GUI)
- Best for code editing + CLI testing
- Still need local Godot Editor for visual work

### 3. Godot Portable (Lightweight Alternative)

Godot itself is portable (no installation required):

**Setup:**

1. Download Godot binary to project folder or known location
2. Document path in README
3. Everyone uses same version

**Project structure:**

```
project/
├── .godot-version        # Track version
├── godot-bin/
│   └── godot.exe         # Optional: commit portable binary (70-100MB)
└── your-project/
```

**Pros:**

- Simple, no Docker required
- Works with Godot Editor (full GUI)
- Cross-platform (Windows/Mac/Linux builds)

**Cons:**

- ~100MB binary to commit (optional)
- Manual version management

### 4. Version Pinning

Create `.godot-version` file:

```bash
echo "4.5.1" > .godot-version
```

Script to check version:

```gdscript
# check_version.gd
extends SceneTree

func _init():
    var required = "4.5.1"
    var current = Engine.get_version_info()
    var current_str = "%s.%s.%s" % [current.major, current.minor, current.patch]

    if current_str != required:
        push_error("Wrong Godot version! Required: %s, Got: %s" % [required, current_str])
        quit(1)
    else:
        print("Godot version OK: %s" % current_str)
        quit(0)
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.5

    steps:
      - uses: actions/checkout@v3

      - name: Verify setup
        run: godot --headless --script setup_addons.gd

      - name: Run validation
        run: godot --headless --path . --script res://scripts/validate_project.gd

      - name: Run tests
        run: godot --headless --path . -s addons/gut/gut_cmdln.gd
```

### GitLab CI Example

```yaml
# .gitlab-ci.yml
image: barichello/godot-ci:4.5

stages:
  - test
  - build

test:
  stage: test
  script:
    - godot --headless --script setup_addons.gd
    - godot --headless --path . --script res://scripts/validate_project.gd
    - godot --headless --path . -s addons/gut/gut_cmdln.gd

build:
  stage: build
  script:
    - godot --headless --export-release "Linux/X11" builds/game.x86_64
  artifacts:
    paths:
      - builds/
```

## Best Practices Summary

### For This Learning Project

✅ **Use:**

- Commit addons directly
- `addons.json` for documentation
- `setup_check.bat` for verification
- Docker for CI/CD only

❌ **Skip:**

- Complex dependency managers
- Dev containers for local work (use native Godot Editor)

### For Team Projects

✅ **Consider:**

- gd-plug or git submodules
- Docker for CI/CD
- Version pinning with `.godot-version`
- Automated testing in CI

### For Production Projects

✅ **Must have:**

- CI/CD with automated testing
- Version pinning
- Export template versioning
- Deployment automation with Docker

## Troubleshooting

### Missing Addons After Clone

```bash
# Check what's missing
setup_check.bat

# If addons aren't committed:
# 1. Check addons.json for requirements
# 2. Install via Godot Editor > AssetLib
# 3. Or use gd-plug/git submodules
```

### Docker Issues

```bash
# Can't run Godot Editor in Docker
# Solution: Use Docker for headless only, local Godot for visual work

# Permission errors
# Solution: Check volume mounts and user permissions

# Image not found
# Solution: Pull manually: docker pull barichello/godot-ci:4.5
```

### Version Mismatches

```bash
# Team using different Godot versions
# Solution: Create .godot-version file and check in CI
```

### GUT Addon Errors (GutErrorTracker not found)

If you see errors like:
```
SCRIPT ERROR: Parse Error: Could not resolve class "GutErrorTracker"
```

This indicates a version mismatch between Godot and the GUT addon:

**Diagnosis:**
1. Check project.godot for configured Godot version
2. Check Dockerfile for Docker image version
3. Verify they match

**Solution:**
```bash
# Rebuild Docker image after version update
docker-compose build

# Or rebuild manually
docker build -t godot-learning .

# Then run tests again
docker-compose run godot-test
```

**Note:** This project requires Godot 4.5 to match project.godot configuration.

## Additional Resources

- [Godot Docker Images](https://github.com/abarichello/godot-ci)
- [gd-plug Plugin Manager](https://github.com/imjp94/gd-plug)
- [Godot Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/index.html)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
