#!/bin/sh

readonly ASPHYXIA_DIR="/app"
readonly CONFIG_FILE="${ASPHYXIA_DIR}/config.ini"
readonly CUSTOM_DIR="/app/data"
readonly CUSTOM_CONFIG="${CUSTOM_DIR}/config.ini"
readonly CUSTOM_SAVE_DIR="${CUSTOM_DIR}/savedata"
readonly PLUGINS_DIR="${ASPHYXIA_DIR}/plugins"
readonly DEFAULT_PLUGINS_DIR="${ASPHYXIA_DIR}/plugins_default"

log() { echo "LOG: $*" >&2; }
die() { echo "ERROR: $*" >&2; exit 1; }

setup_config() {
    log "Setting up configuration..."
    if [ ! -f "${CUSTOM_CONFIG}" ]; then
        log "Custom config.ini not found; creating initial file."
        printf "[core]\n  port = 8083\n  bind = \"0.0.0.0\"\n" > "${CUSTOM_CONFIG}"
    fi
    ln -sf "${CUSTOM_CONFIG}" "${CONFIG_FILE}" || die "Failed to symlink config"
}

setup_plugins() {
    log "Setting up plugins..."
    mkdir -p "${PLUGINS_DIR}"
    rm -rf "${PLUGINS_DIR:?}"/* || die "Failed to clean plugins directory"

    # Add official stable plugins unless replacement is requested
    if [ -z "${ASPHYXIA_PLUGIN_REPLACE}" ]; then
        log "Adding official stable plugins..."
        cp -r "${DEFAULT_PLUGINS_DIR}"/* "${PLUGINS_DIR}/" || die "Failed to copy defaults"
    fi

    # Add custom plugins from Pi volume if they exist
    if [ -d "${CUSTOM_DIR}/plugins" ] && [ "$(ls -A "${CUSTOM_DIR}/plugins")" ]; then
        log "Merging custom plugins from volume..."
        cp -r "${CUSTOM_DIR}/plugins"/* "${PLUGINS_DIR}/" || die "Failed to copy custom plugins"
    fi
}

build_command_args() {
    local args="-d ${CUSTOM_SAVE_DIR}"
    mkdir -p "${CUSTOM_SAVE_DIR}"

    # Environment variable overrides
    [ -n "${ASPHYXIA_LISTENING_PORT}" ] && args="$args -p $ASPHYXIA_LISTENING_PORT"
    [ -n "${ASPHYXIA_BINDING_HOST}" ]   && args="$args -b $ASPHYXIA_BINDING_HOST"
    [ -n "${ASPHYXIA_MATCHING_PORT}" ]  && args="$args -m $ASPHYXIA_MATCHING_PORT"
    
    echo "$args"
}

main() {
    setup_config
    setup_plugins
    
    # Ensure the Pi volume is writable for the database
    chmod -R 777 "${CUSTOM_DIR}"

    local cmd_args
    cmd_args=$(build_command_args)
    readonly ASPHYXIA_EXEC="${ASPHYXIA_DIR}/asphyxia-core-armv7"
    
    log "Running: ${ASPHYXIA_EXEC} ${cmd_args}"
    exec ${ASPHYXIA_EXEC} ${cmd_args}
}

main "$@"