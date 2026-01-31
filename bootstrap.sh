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
    # Create a basic config if completely missing
    if [ ! -f "${CONFIG_FILE}" ]; then
        log "WARNING: No config found anywhere. Creating minimal config."
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

    log "Fixing permissions..."
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
    
    # 3. SYMLINK FIX
    # We remove the local 'plugins' folder in INSTALL_DIR if it's an empty directory
    # so we can symlink it. 
    # Docker unzip might have created an empty 'plugins' dir.
    if [ -d "${INSTALL_DIR}/plugins" ] && [ ! -L "${INSTALL_DIR}/plugins" ]; then
        log "Removing empty plugins dir in install location to make room for symlink..."
        rm -rf "${INSTALL_DIR}/plugins"
    fi

    log "Symlinking data to install dir..."
    ln -sf "${CONFIG_FILE}" "${INSTALL_DIR}/config.ini" || true
    ln -sf "${PLUGINS_DIR}" "${INSTALL_DIR}/plugins" || true
    
    rm -rf "${INSTALL_DIR}/savedata"
    ln -sf "${SAVEDATA_DIR}" "${INSTALL_DIR}/savedata" || true
}

main() {
    log "Starting Asphyxia bootstrap (Run-From-Install Strategy)..."
    
    local exec_path
    exec_path=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    [ -x "${exec_path}" ] || die "Executable not found in ${INSTALL_DIR}"
    
    setup_data_dir
    
    # Debug info
    log "Verifying Install Dir Symlinks:"
    ls -l "${INSTALL_DIR}" >&2

    # Change to INSTALL_DIR so Asphyxia sees "plugins" and "config.ini" locally
    cd "${INSTALL_DIR}" || die "Failed to change to install dir"
    
    log "Running: ./${exec_path##*/} from ${PWD}"
    
    exec "${exec_path}" --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
