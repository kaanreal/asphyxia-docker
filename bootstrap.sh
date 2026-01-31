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
    
    # Debug: List Install Dir
    log "Install Dir Contents:"
    ls -l "${INSTALL_DIR}" >&2
    
    # 1. Config Setup
    if [ ! -f "${CONFIG_FILE}" ]; then
        if [ -f "${DEFAULT_CONFIG_FILE}" ]; then
            log "No config.ini found; copying default config"
            cp "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}"
        else
            log "WARNING: config_default.ini not found! Checking for config.ini..."
            if [ -f "${INSTALL_DIR}/config.ini" ]; then
                 cp "${INSTALL_DIR}/config.ini" "${CONFIG_FILE}"
                 log "Copied config.ini instead."
            fi
        fi
    fi
    
    # 2. Plugins Setup
    if [ -z "$(ls -A "${PLUGINS_DIR}" 2>/dev/null)" ]; then
        if [ -d "${DEFAULT_PLUGINS_DIR}" ]; then
             log "No plugins found; copying default plugins..."
             cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}"/
        fi
    fi

    # 3. Permissions Fix
    log "Fixing permissions..."
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
    
    # 4. SYMLINK FIX (Vital for binary finding files)
    # Some binaries look relative to THEMSELVES, not CWD.
    # We symlink the /data content back to /usr/local/share/asphyxia
    log "Symlinking data to install dir..."
    ln -sf "${CONFIG_FILE}" "${INSTALL_DIR}/config.ini" || true
    ln -sf "${PLUGINS_DIR}" "${INSTALL_DIR}/plugins" || true
    # Remove existing savedata in install dir if it exists and link
    rm -rf "${INSTALL_DIR}/savedata"
    ln -sf "${SAVEDATA_DIR}" "${INSTALL_DIR}/savedata" || true
}

main() {
    log "Starting Asphyxia bootstrap (Symlink Strategy)..."
    
    local exec_path
    exec_path=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    [ -x "${exec_path}" ] || die "Executable not found in ${INSTALL_DIR}"
    
    setup_data_dir
    
    log "Files in data dir:"
    ls -l "${DATA_DIR}" >&2

    log "Location: ${exec_path}"
    
    # Run from DATA_DIR, but now with symlinks in place, it should work either way.
    cd "${DATA_DIR}" || die "Failed to change to data dir"
    
    exec ${exec_path} --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
