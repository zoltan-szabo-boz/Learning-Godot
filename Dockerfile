# Godot Development Environment with Headless Testing
# Based on official Godot Docker images

FROM barichello/godot-ci:4.3

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace

# Install any additional dependencies here (if needed)
# RUN apt-get update && apt-get install -y <package-name>

# Set environment variables
ENV GODOT_VERSION=4.3
ENV DISPLAY=:0

# Default command: run tests
CMD ["godot", "--headless", "--path", "/workspace", "-s", "addons/gut/gut_cmdln.gd"]

# Usage examples:
# Build: docker build -t godot-learning .
# Run tests: docker run --rm godot-learning
# Run validation: docker run --rm godot-learning godot --headless --path /workspace --script res://scripts/validate_project.gd
# Interactive shell: docker run -it --rm godot-learning bash
