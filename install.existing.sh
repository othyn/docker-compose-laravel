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
# Build the Docker images!
echo "> Build the Docker containers."
docker-compose build

# Step Done!
# That's it! Magic. 🎉
echo "> Installation complete!"
