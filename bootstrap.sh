#!/bin/sh

# Core paths
readonly INSTALL_DIR="/usr/local/share/asphyxia"
readonly DATA_DIR="/data"

# Data paths (Persistent)
readonly CONFIG_FILE="${DATA_DIR}/config.ini"
readonly PLUGINS_DIR="${DATA_DIR}/plugins"
readonly SAVEDATA_DIR="${DATA_DIR}/savedata"

# Template paths (Inside image)
readonly DEFAULT_CONFIG_FILE="${INSTALL_DIR}/config_default.ini"
readonly DEFAULT_PLUGINS_DIR="${INSTALL_DIR}/plugins_default"

log() {
    echo "LOG: $*" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

setup_data_dir() {
    log "Setting up data directory..."
    mkdir -p "${DATA_DIR}" "${PLUGINS_DIR}" "${SAVEDATA_DIR}"
    
    # 1. Config Setup
    if [ ! -f "${CONFIG_FILE}" ]; then
        if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
            log "No config.ini found; copying default config"
            cp "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}"
        fi
    fi
    
    # 2. Plugins Setup
    # Double check if plugins directory is "empty"
    # We check if specific plugins folder is populated.
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ]; then
             log "No plugins found; copying default plugins..."
             # The zip structure is usually plugins-stable -> [plugin1, plugin2]
             # My Dockerfile moves them to plugins_default/
             # So plugins_default has: plugin1/, plugin2/
             # We want: /data/plugins/plugin1/
             cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        fi
    fi

    # 3. Permissions Fix (Aggressive)
    log "Fixing permissions..."
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
}

main() {
    log "Starting Asphyxia bootstrap Check..."
    
    local exec_path
    exec_path=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    [ -x "${exec_path}" ] || die "Executable not found in ${INSTALL_DIR}"
    
    setup_data_dir
    
    # SYMLINK Config to default location if missing?
    # Asphyxia core defaults to reading config.ini in CWD.
    # Our CWD is /data.
    # config.ini should be in /data.
    
    log "Files in data dir:"
    ls -l "${DATA_DIR}" >&2
    log "Plugins in plugins dir:"
    ls -l "${PLUGINS_DIR}" >&2

    log "Running: ${exec_path}"
    cd "${DATA_DIR}" || die "Failed to change to data dir"
    
    exec ${exec_path} --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
