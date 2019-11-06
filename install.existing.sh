#!/bin/bash
# Installation steps for existing project installations
echo "[Docker Compose Laravel: Existing project installation]"
echo "> Beginning installation!"

# Step 0
# Get the script directory, just so this can be run from anywhere
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$CURRENT_DIR"
echo "> Script directory set to '$CURRENT_DIR'."

# Step 1
# Create that .env file!
ENV_DIR="./.env"
ENV_EXAMPLE_DIR="${ENV_DIR}.example"
if [[ -f "$ENV_DIR" ]]; then
    echo "> Not copying '$ENV_EXAMPLE_DIR', as '$ENV_DIR' already exists."
else
    echo "> Copying '$ENV_EXAMPLE_DIR' to '$ENV_DIR'."
    cp "$ENV_EXAMPLE_DIR" "$ENV_DIR"
fi

# Step 2
# Create a symlink to the parent directory, just so you can run
# the docker-compose commands from project root. A little quality
# of life addition.
DOCKER_DIR="docker/docker-compose.yml"
DOCKER_SYMLINK_DIR="./../docker-compose.yml"
if [[ -L "$DOCKER_SYMLINK_DIR" ]]; then
    echo "> Removing existing symlink at '$DOCKER_SYMLINK_DIR'."
    rm "$DOCKER_SYMLINK_DIR"
fi
echo "> Symlinking '$DOCKER_DIR' to '$DOCKER_SYMLINK_DIR'."
ln -s "$DOCKER_DIR" "$DOCKER_SYMLINK_DIR"

# Step 3
# Build the Docker images!
echo "> Build the Docker containers."
docker-compose build

# Step Done!
# That's it! Magic. 🎉
echo "> Installation complete!"
