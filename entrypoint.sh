#!/bin/sh

# Paths for the Raspberry Pi setup
readonly APP_DIR="/app"
readonly DATA_DIR="/app/data" # This is your mounted volume
readonly PLUGINS_DIR="${APP_DIR}/plugins"
readonly PLUGINS_BACKUP="${APP_DIR}/plugins_backup"
readonly SAVEDATA_DIR="${DATA_DIR}/savedata"
readonly CONFIG_FILE="${APP_DIR}/config.ini"
readonly CUSTOM_CONFIG="${DATA_DIR}/config.ini"

log() {
    echo "[LOG] $*" >&2
}

# 1. Setup Configuration
setup_config() {
    log "Setting up configuration..."
    if [ -f "${CUSTOM_CONFIG}" ]; then
        log "Custom config.ini found in data volume."
        ln -sf "${CUSTOM_CONFIG}" "${CONFIG_FILE}"
    else
        log "No custom config found. Creating default..."
        touch "${CUSTOM_CONFIG}"
        ln -sf "${CUSTOM_CONFIG}" "${CONFIG_FILE}"
    fi
}

# 2. Setup Plugins (Merge or Replace)
setup_plugins() {
    log "Setting up plugins..."
    # Ensure the internal plugins directory exists and is empty
    mkdir -p "${PLUGINS_DIR}"
    rm -rf "${PLUGINS_DIR:?}"/*

    if [ -d "${DATA_DIR}/plugins" ]; then
        if [ -n "${ASPHYXIA_PLUGIN_REPLACE}" ]; then
            log "ASPHYXIA_PLUGIN_REPLACE is set. Skipping default plugins."
        else
            log "Merging default plugins with custom plugins..."
            cp -r "${PLUGINS_BACKUP}"/* "${PLUGINS_DIR}/" 2>/dev/null
        fi
        # Copy custom plugins over the defaults
        cp -r "${DATA_DIR}/plugins"/* "${PLUGINS_DIR}/" 2>/dev/null
    else
        log "No custom plugins folder found. Using defaults only."
        cp -r "${PLUGINS_BACKUP}"/* "${PLUGINS_DIR}/" 2>/dev/null
    fi
}

# 3. Build Command Arguments
build_args() {
    local args=""
    
    # Force use the data volume for savedata/DB
    mkdir -p "${SAVEDATA_DIR}"
    args="-d ${SAVEDATA_DIR}"

    # Add environment variable overrides
    [ -n "${ASPHYXIA_LISTENING_PORT}" ] && args="$args -p $ASPHYXIA_LISTENING_PORT"
    [ -n "${ASPHYXIA_BINDING_HOST}" ]   && args="$args -b $ASPHYXIA_BINDING_HOST"
    [ -n "${ASPHYXIA_MATCHING_PORT}" ]  && args="$args -m $ASPHYXIA_MATCHING_PORT"
    
    echo "$args"
}

# Main Execution
log "Starting Asphyxia Bootstrap for ARMv7..."

setup_config
setup_plugins

# Set permissions for the data volume to prevent DB errors
chmod -R 777 "${DATA_DIR}"

ARGS=$(build_args)
log "Running: ./asphyxia-core-armv7 $ARGS"

exec ./asphyxia-core-armv7 $ARGS