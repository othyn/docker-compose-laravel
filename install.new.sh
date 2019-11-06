#!/bin/bash
# Installation steps for new project installations
echo "[Docker Compose Laravel: New project installation]"
echo "> Beginning installation!"

# Step 0
# Get the script directory, just so this can be run from anywhere
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$CURRENT_DIR"
echo "> Script directory: '$CURRENT_DIR'"

# Step 1
# Create a new Laravel project at ./src
echo "> Creating a new Laravel project"
laravel new "./src" --force

# Step Done!
# That's it! Magic. 🎉
echo "> Installation complete!"
