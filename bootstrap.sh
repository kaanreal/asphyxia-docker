#!/bin/sh
set -e

# ==========================================
# Asphyxia Docker Bootstrap
# Strategy: "Portable Install in Volume"
# 
# We copy the executable into the persistence directory (/data)
# so it runs alongside its config and plugins relative to CWD.
# This ensures 100% compatibility with the application's
# path resolution logic while keeping data persistent.
# ==========================================

# Core paths
readonly INSTALL_DIR="/usr/local/share/asphyxia"
readonly DATA_DIR="/data"

# Data paths (Persistent)
readonly CONFIG_FILE="${DATA_DIR}/config.ini"
readonly PLUGINS_DIR="${DATA_DIR}/plugins"
readonly SAVEDATA_DIR="${DATA_DIR}/savedata"
readonly EXEC_FILE="${DATA_DIR}/asphyxia-core"

# Template paths
readonly DEFAULT_CONFIG_FILE="${INSTALL_DIR}/config_default.ini"
readonly DEFAULT_PLUGINS_DIR="${INSTALL_DIR}/plugins_default"

log() {
    echo "[Entrypoint] $*" >&2
}

setup_data_dir() {
    # 1. Structure Setup
    if [ ! -d "${DATA_DIR}" ]; then
        log "Initializing data directory..."
    fi
    mkdir -p "${DATA_DIR}" "${PLUGINS_DIR}" "${SAVEDATA_DIR}"
    
    # 2. Config Setup
    if [ ! -f "${CONFIG_FILE}" ]; then
        if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
            log "Initializing config.ini from defaults..."
            cp "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}"
        else
            log "WARNING: Default config not found. Creating minimal config."
            echo "[core]" > "${CONFIG_FILE}"
            echo "target=s" >> "${CONFIG_FILE}"
        fi
    fi

    # 3. Plugins Setup
    # Only populate if empty to avoid overwriting user changes
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ]; then
             log "Initializing default plugins..."
             cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        fi
    fi

    # 4. Executable Setup (Update on boot)
    # We copy the binary to /data every startup to ensure the version 
    # matches the Docker image, while allowing it to run locally.
    local source_exec
    source_exec=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    
    if [ ! -x "${source_exec}" ]; then
        echo "CRITICAL ERROR: Original executable not found in ${INSTALL_DIR}" >&2
        exit 1
    fi
    
    # Always overwrite the binary in /data to match the image version
    cp -f "${source_exec}" "${EXEC_FILE}"
    chmod +x "${EXEC_FILE}"

    # 5. Permissions Fix
    # Ensure the container user (root) can read/write, but also helpful for mapped volumes
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
}

main() {
    setup_data_dir
    
    # Switch to data directory as Working Directory
    cd "${DATA_DIR}"
    
    log "Starting Asphyxia Core..."
    exec ./asphyxia-core --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
