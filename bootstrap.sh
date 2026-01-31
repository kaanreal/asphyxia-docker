#!/bin/sh

readonly ASPHYXIA_DIR="/data"
readonly CONFIG_FILE="${ASPHYXIA_DIR}/config.ini"
readonly DEFAULT_CONFIG_FILE="/usr/local/share/asphyxia/config_default.ini"
readonly PLUGINS_DIR="${ASPHYXIA_DIR}/plugins"
readonly DEFAULT_PLUGINS_DIR="/usr/local/share/asphyxia/plugins_default"
readonly SAVEDATA_DIR="${ASPHYXIA_DIR}/savedata"
readonly INSTALL_DIR="/usr/local/share/asphyxia"

log() {
    echo "LOG: $*" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

setup_data_dir() {
    log "Setting up data directory..."
    mkdir -p "${ASPHYXIA_DIR}" "${PLUGINS_DIR}" "${SAVEDATA_DIR}"
    
    if [ ! -f "${CONFIG_FILE}" ]; then
        if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
            log "No config.ini found; copying default config"
            cp    "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}"
        fi
    fi
    
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ]; then
             log "No plugins found; copying default plugins..."
             # Use verbose copy to show what's happening
             cp -rv "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        fi
    fi

    # Ensure the user can edit these files on the host (permissions fix)
    log "Fixing permissions..."
    chmod -R 777 "${ASPHYXIA_DIR}" 2>/dev/null || true
}

build_command_args() {
    local args="-d ${SAVEDATA_DIR}"
    [ -n "${ASPHYXIA_LISTENING_PORT:-}" ] && args="$args --port $ASPHYXIA_LISTENING_PORT"
    [ -n "${ASPHYXIA_BINDING_HOST:-}" ] && args="$args --bind $ASPHYXIA_BINDING_HOST"
    [ -n "${ASPHYXIA_MATCHING_PORT:-}" ] && args="$args --matching-port $ASPHYXIA_MATCHING_PORT"
    [ -n "${ASPHYXIA_DEV_MODE:-}" ] && args="$args --dev"
    echo "$args"
}

main() {
    log "Starting Asphyxia bootstrap..."
    
    # Auto-detect binary name
    local exec_path
    exec_path=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    
    [ -x "${exec_path}" ] || die "Executable not found in ${INSTALL_DIR}"
    
    setup_data_dir

    local cmd_args
    cmd_args=$(build_command_args)

    log "Running: ${exec_path} ${cmd_args}"
    cd "${ASPHYXIA_DIR}" || die "Failed to change to data dir"
    exec ${exec_path} ${cmd_args}
}

main "$@"
