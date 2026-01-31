#!/bin/sh

readonly ASPHYXIA_DIR="/data"
readonly CONFIG_FILE="${ASPHYXIA_DIR}/config.ini"
readonly DEFAULT_CONFIG_FILE="/usr/local/share/asphyxia/config_default.ini"
readonly PLUGINS_DIR="${ASPHYXIA_DIR}/plugins"
readonly DEFAULT_PLUGINS_DIR="/usr/local/share/asphyxia/plugins_default"
readonly SAVEDATA_DIR="${ASPHYXIA_DIR}/savedata"
readonly ASPHYXIA_EXEC="/usr/local/share/asphyxia/asphyxia-core"

log() {
    echo "LOG: $*" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

setup_data_dir() {
    log "Setting up data directory..."
    
    # Create data directory structure if it doesn't exist
    mkdir -p "${ASPHYXIA_DIR}"
    mkdir -p "${PLUGINS_DIR}"
    mkdir -p "${SAVEDATA_DIR}"
    
    # Copy default config if no config exists
    if [ ! -f "${CONFIG_FILE}" ]; then
        if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
            log "No config.ini found; copying default config"
            cp "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}"
        else
            log "Warning: No default config found"
        fi
    else
        log "Using existing config.ini"
    fi
    
    # Copy default plugins if plugins directory is empty
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ] && [ -n "$(ls -A "${DEFAULT_PLUGINS_DIR}" 2>/dev/null)" ]; then
            log "No plugins found; copying default plugins"
            cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        else
            log "Warning: No default plugins found"
        fi
    else
        log "Using existing plugins"
    fi
}

build_command_args() {
    local args=""

    # Always use the data directory for savedata
    args="$args -d ${SAVEDATA_DIR}"

    # Build optional arguments from environment variables
    [ -n "${ASPHYXIA_LISTENING_PORT:-}" ] && args="$args --port $ASPHYXIA_LISTENING_PORT"
    [ -n "${ASPHYXIA_BINDING_HOST:-}" ] && args="$args --bind $ASPHYXIA_BINDING_HOST"
    [ -n "${ASPHYXIA_MATCHING_PORT:-}" ] && args="$args --matching-port $ASPHYXIA_MATCHING_PORT"
    [ -n "${ASPHYXIA_DEV_MODE:-}" ] && args="$args --dev"
    [ -n "${ASPHYXIA_PING_IP:-}" ] && args="$args --ping-addr $ASPHYXIA_PING_IP"

    echo "$args"
}

main() {
    log "Starting Asphyxia bootstrap..."
    
    [ -x "${ASPHYXIA_EXEC}" ] || die "Asphyxia executable not found or not executable: ${ASPHYXIA_EXEC}"
    
    setup_data_dir

    local cmd_args
    cmd_args=$(build_command_args)

    log "Running: ${ASPHYXIA_EXEC} ${cmd_args}"
    cd "${ASPHYXIA_DIR}" || die "Failed to change to data directory"
    exec ${ASPHYXIA_EXEC} ${cmd_args}
}

main "$@"
