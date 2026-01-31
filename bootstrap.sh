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
    # We check if plugins directory is effectively empty
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ]; then
             log "No plugins found; copying default plugins..."
             # Copy CONTENTS of default plugins to the plugins directory
             cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        fi
    fi

    # 3. Permissions Fix
    log "Fixing permissions..."
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
}

main() {
    log "Starting Asphyxia bootstrap..."
    
    # Auto-detect binary name
    local exec_path
    exec_path=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    [ -x "${exec_path}" ] || die "Executable not found in ${INSTALL_DIR}"
    
    setup_data_dir

    log "Running: ${exec_path}"
    
    # IMPORTANT: Asphyxia looks for plugins relative to CWD.
    # We must be in /data for it to find 'plugins' folder there.
    cd "${DATA_DIR}" || die "Failed to change to data dir"
    
    # We run the binary directly.
    # We do NOT pass -d because if we are in /data, it uses ./savedata by default if config says so,
    # OR we pass explicitly.
    # The config.ini usually points to savedata.
    # But let's be explicit with savedata dir.
    
    exec ${exec_path} --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
