#!/bin/bash
# Installation steps for existing project installations
echo "[Docker Compose Laravel: Existing project installation]"
echo "> Beginning installation!"

# Step 0
# Get the script directory, just so this can be run from anywhere
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$CURRENT_DIR"
echo "> Script directory: '$CURRENT_DIR'"

# Step 1
# Create that .env file!
echo "> Copying './.env.example' to './.env'"
cp "./.env.example" "./.env"

# Step 2
# Create a symlink to the parent directory, just so you can run
# the docker-compose commands from project root. A little quality
# of life addition.
echo "> Symlinking './docker-compose.yml' to './../docker-compose.yml'"
ln -s "./docker-compose.yml" "./../docker-compose.yml"

# Step Done!
# That's it! Magic. 🎉
echo "> Installation complete!"
