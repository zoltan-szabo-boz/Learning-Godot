# Godot Development Environment with Headless Testing
# Based on official Godot Docker images

FROM barichello/godot-ci:4.5

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace

# Install fontconfig to fix libfontconfig warning
RUN apt-get update && apt-get install -y libfontconfig1 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV GODOT_VERSION=4.5
ENV DISPLAY=:0

# Default command: run tests
CMD ["godot", "--headless", "--path", "/workspace", "-s", "addons/gut/gut_cmdln.gd", "-gexit"]

# Usage examples:
# Build: docker build -t godot-learning .
# Run tests: docker run --rm godot-learning
# Run validation: docker run --rm godot-learning godot --headless --path /workspace --script res://scripts/validate_project.gd
# Interactive shell: docker run -it --rm godot-learning bash
