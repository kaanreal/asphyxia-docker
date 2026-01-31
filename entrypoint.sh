#!/bin/sh

# 1. Ensure the data directory structure exists on the host (Raspberry Pi)
mkdir -p /app/data/plugins /app/data/savedata

# 2. If the host plugins folder is empty, populate it from backup
if [ ! "$(ls -A /app/data/plugins 2>/dev/null)" ]; then
    echo "First run detected: Copying official plugins to host storage..."
    cp -r /app/plugins_backup/* /app/data/plugins/
fi

# 3. Create initial config.ini if missing
if [ ! -f /app/data/config.ini ]; then
    echo "Creating initial config.ini..."
    touch /app/data/config.ini
fi

# 4. REMOVE any existing folders/links so we don't get nested errors
rm -rf /app/plugins /app/savedata /app/config.ini

# 5. LINK the host folders to the locations Asphyxia expects
# This makes Asphyxia think the folders are in its root directory
ln -s /app/data/plugins /app/plugins
ln -s /app/data/savedata /app/savedata
ln -s /app/data/config.ini /app/config.ini

# 6. Start Asphyxia Core
# We only use -d for savedata (this one actually works in Asphyxia)
# The plugins will be found via the symlink we just made
echo "Starting Asphyxia Core v1.60a..."
exec ./asphyxia-core-armv7 -d /app/savedata