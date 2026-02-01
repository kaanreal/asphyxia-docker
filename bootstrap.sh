#!/bin/sh

# Core paths
readonly INSTALL_DIR="/usr/local/share/asphyxia"
readonly DATA_DIR="/data"

# Data paths (Persistent)
readonly CONFIG_FILE="${DATA_DIR}/config.ini"
readonly PLUGINS_DIR="${DATA_DIR}/plugins"
readonly SAVEDATA_DIR="${DATA_DIR}/savedata"
# Binary in data
readonly EXEC_FILE="${DATA_DIR}/asphyxia-core"

# Template paths
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
     if [ ! -f "${CONFIG_FILE}" ]; then
        log "WARNING: Creating fresh config.ini."
        echo "[core]" > "${CONFIG_FILE}"
        echo "target=s" >> "${CONFIG_FILE}"
    fi

    # 2. Plugins Setup
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ]; then
             log "No plugins found; copying default plugins..."
             cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        fi
    fi

    # 3. Executable Setup (Copy to Data)
    # We copy the binary to /data so checks for CWD plugins/db work natively
    local source_exec
    source_exec=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    [ -x "${source_exec}" ] || die "Original executable not found in ${INSTALL_DIR}"
    
    log "Copying binary to data directory for native execution..."
    cp -f "${source_exec}" "${EXEC_FILE}"
    chmod +x "${EXEC_FILE}"

    # 4. Cleanup old symlinks/DBs in data if they interfere?
    # No, we want DBs to be created there.

    log "Fixing permissions..."
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
}

main() {
    log "Starting Asphyxia bootstrap (All-In-Data Strategy)..."
    
    setup_data_dir
    
    cd "${DATA_DIR}" || die "Failed to change to data dir"
    
    log "Running: ./asphyxia-core from ${PWD}"
    
    # Execute the copy in /data
    exec ./asphyxia-core --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
