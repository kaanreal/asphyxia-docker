#!/bin/sh

# Core paths
readonly INSTALL_DIR="/usr/local/share/asphyxia"
readonly DATA_DIR="/data"

# Data paths (Persistent)
readonly CONFIG_FILE="${DATA_DIR}/config.ini"
readonly PLUGINS_DIR="${DATA_DIR}/plugins"
readonly SAVEDATA_DIR="${DATA_DIR}/savedata"

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

    # 3. Dynamic Database Persistence
    # Asphyxia creates [plugin].db in CWD. We want them in /data.
    # We pre-create and symlink them.
    
    # Core DB
    if [ ! -f "${DATA_DIR}/core.db" ]; then touch "${DATA_DIR}/core.db"; fi
    chmod 666 "${DATA_DIR}/core.db"
    ln -sf "${DATA_DIR}/core.db" "${INSTALL_DIR}/core.db"
    
    # Plugin DBs
    log "Linking plugin databases..."
    for plugin_path in "${PLUGINS_DIR}"/*; do
        if [ -d "$plugin_path" ]; then
            plugin_name=$(basename "$plugin_path")
            db_target="${DATA_DIR}/${plugin_name}.db"
            
            # Create file if missing
            if [ ! -f "${db_target}" ]; then 
                log "Creating DB for ${plugin_name}"
                touch "${db_target}"
            fi
            
            chmod 666 "${db_target}"
            # Symlink to Install Dir
            ln -sf "${db_target}" "${INSTALL_DIR}/${plugin_name}.db"
        fi
    done

    # 4. Permissions Fix
    log "Fixing permissions..."
    chmod -R 777 "${DATA_DIR}" 2>/dev/null || true
    
    # 5. SYMLINK FIX (Plugins/Config)
    if [ -d "${INSTALL_DIR}/plugins" ] && [ ! -L "${INSTALL_DIR}/plugins" ]; then
        rm -rf "${INSTALL_DIR}/plugins"
    fi

    ln -sf "${CONFIG_FILE}" "${INSTALL_DIR}/config.ini" || true
    ln -sf "${PLUGINS_DIR}" "${INSTALL_DIR}/plugins" || true
    
    rm -rf "${INSTALL_DIR}/savedata"
    ln -sf "${SAVEDATA_DIR}" "${INSTALL_DIR}/savedata" || true
}

main() {
    log "Starting Asphyxia bootstrap (Dynamic DB Link)..."
    
    local exec_path
    exec_path=$(find "${INSTALL_DIR}" -maxdepth 1 -name "asphyxia-core*" -type f -not -name "*.ini" | head -n 1)
    [ -x "${exec_path}" ] || die "Executable not found in ${INSTALL_DIR}"
    
    setup_data_dir
    
    cd "${INSTALL_DIR}" || die "Failed to change to install dir"
    
    log "Running: ./${exec_path##*/} from ${PWD}"
    
    exec "${exec_path}" --savedata-dir "${SAVEDATA_DIR}"
}

main "$@"
