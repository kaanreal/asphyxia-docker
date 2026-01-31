#!/bin/sh

# 1. Ensure the data directory structure exists
mkdir -p /app/data/plugins /app/data/savedata

# 2. Populate plugins if host folder is empty
if [ ! "$(ls -A /app/data/plugins 2>/dev/null)" ]; then
    echo "First run: Copying official plugins..."
    cp -r /app/plugins_backup/* /app/data/plugins/
fi

# 3. Handle config.ini (Copy to workdir for better performance)
if [ ! -f /app/data/config.ini ]; then
    echo "Creating initial config.ini..."
    touch /app/data/config.ini
fi
cp /app/data/config.ini /app/config.ini

# 4. Cleanup and Link
# We link the plugins, but for savedata, we use the -d flag later 
# to ensure the binary has direct write access to the volume.
rm -rf /app/plugins /app/savedata
ln -s /app/data/plugins /app/plugins

# 5. Fix permissions for the mapped volume
# This ensures the internal process can write the .db file to savedata
echo "Setting permissions for savedata..."
chmod -R 777 /app/data/savedata

# 6. Start Asphyxia
# -d points the database and user data to the mounted folder
echo "Starting Asphyxia Core v1.60a..."
./asphyxia-core-armv7 -d /app/data/savedata

# 7. Sync config back to Pi after shutdown so WebUI changes persist
cp /app/config.ini /app/data/config.ini