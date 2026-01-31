#!/bin/sh

# 1. Create directories
mkdir -p /app/data/plugins /app/data/savedata

# 2. Populate plugins if host folder is empty
if [ ! "$(ls -A /app/data/plugins 2>/dev/null)" ]; then
    echo "First run: Copying official plugins..."
    cp -r /app/plugins_backup/* /app/data/plugins/
fi

# 3. Handle config.ini (Copy to workdir, don't link)
if [ ! -f /app/data/config.ini ]; then
    echo "Creating initial config.ini..."
    # Create a basic config so SDVX doesn't crash on 'join'
    echo "[sdvx]\nenabled=true" > /app/data/config.ini
fi
cp /app/data/config.ini /app/config.ini

# 4. Link plugins and savedata
rm -rf /app/plugins /app/savedata
ln -s /app/data/plugins /app/plugins
ln -s /app/data/savedata /app/savedata

# 5. FIX PERMISSIONS (Crucial for DB errors)
# This ensures the internal 'node' user can write the .db file
chmod -R 777 /app/data

# 6. Start Asphyxia
echo "Starting Asphyxia Core v1.60a..."
# We run the binary. When it stops, we save the config back.
./asphyxia-core-armv7 -d /app/savedata

# Sync config back to Pi so changes persist
cp /app/config.ini /app/data/config.ini