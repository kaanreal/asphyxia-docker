#!/bin/sh

# Paths
readonly DATA_DIR="/app/data"
readonly PLUGINS_WORK_DIR="/app/plugins"
readonly PLUGINS_BACKUP="/app/plugins_backup"
readonly CONFIG_FILE="/app/config.ini"

log() {
    echo "[LOG] $*" >&2
}

# 1. Prepare Workspace
log "Preparing directories..."
mkdir -p "$DATA_DIR/plugins" "$DATA_DIR/savedata" "$PLUGINS_WORK_DIR"

# 2. Setup Config
if [ -f "$DATA_DIR/config.ini" ]; then
    log "Using custom config.ini from volume."
    cp "$DATA_DIR/config.ini" "$CONFIG_FILE"
else
    log "No config.ini found, creating default."
    touch "$CONFIG_FILE"
fi

# 3. Setup Plugins (The Sync Logic)
log "Syncing plugins..."
# Clear the working directory to avoid old version conflicts
rm -rf "${PLUGINS_WORK_DIR:?}"/*

# First, fill with backup plugins (unless REPLACE is set)
if [ -z "$ASPHYXIA_PLUGIN_REPLACE" ]; then
    log "Loading official plugins..."
    cp -r "$PLUGINS_BACKUP"/* "$PLUGINS_WORK_DIR/" 2>/dev/null
fi

# Second, copy custom plugins from the Pi volume
if [ "$(ls -A "$DATA_DIR/plugins" 2>/dev/null)" ]; then
    log "Loading custom plugins from volume..."
    cp -r "$DATA_DIR/plugins"/* "$PLUGINS_WORK_DIR/" 2>/dev/null
fi

# 4. Final Permissions Fix
chmod -R 777 "$DATA_DIR" "$PLUGINS_WORK_DIR" "$CONFIG_FILE"

# 5. Start Asphyxia
# We use -d to point to the savedata in the volume
log "Starting Asphyxia Core v1.60a..."
exec ./asphyxia-core-armv7 -d "$DATA_DIR/savedata"