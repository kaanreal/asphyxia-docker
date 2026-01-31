#!/bin/sh

# Ensure the data directory structure exists on the host (Raspberry Pi)
mkdir -p /app/data/plugins /app/data/savedata

# If the plugins folder on the host is empty, populate it with official plugins
if [ ! "$(ls -A /app/data/plugins 2>/dev/null)" ]; then
    echo "First run detected: Copying official plugins to host storage..."
    cp -r /app/plugins_backup/* /app/data/plugins/
fi

# Create an initial config.ini if it doesn't exist on the host
if [ ! -f /app/data/config.ini ]; then
    echo "Creating initial config.ini..."
    touch /app/data/config.ini
fi

# Synchronize host config to the working directory
cp /app/data/config.ini /app/config.ini

# Start Asphyxia Core. 
# We explicitly point to the mounted directories to avoid symlink issues.
echo "Starting Asphyxia Core v1.60a..."
exec ./asphyxia-core-armv7